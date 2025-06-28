# Ejemplos de Uso Realistas - HF Oracle Batch

> **📖 [Ver versión en inglés](REALISTIC_USAGE_EXAMPLES.md)**

## Descripción General

Este documento presenta ejemplos prácticos del sistema HF Oracle Batch, mostrando cómo implementar cadenas de procesos batch complejas con **captura automática de parámetros** y configuración mínima.

**⚠️ IMPORTANTE**: Los ejemplos aprovechan las capacidades de **introspección automática de parámetros** del sistema. El package `PCK_BATCH_UTILS` captura automáticamente todos los parámetros de los procedimientos, eliminando la definición manual de parámetros.

## Esquema de Ejemplo: Sistema de Reportes Financieros

### Cadena: MONTHLY_FINANCIAL_REPORTS
- **Descripción**: Genera reportes financieros completos al final de cada mes
- **Frecuencia**: Mensual (primer día del mes siguiente)
- **Procesos**: 4 procesos principales

### Proceso 1: DATA_PREPARATION (Ejecución serial)
**Actividades**:
1. `VALIDATE_ACCOUNTING_DATA` - Valida integridad de datos contables
2. `CALCULATE_BALANCES` - Calcula balances de cuentas
3. `CONSOLIDATE_COMPANIES` - Consolida datos de múltiples empresas

### Proceso 2: REPORT_GENERATION (Ejecución paralela)
**Actividades**:
1. `GENERATE_BALANCE_SHEET` - Genera balance general
2. `GENERATE_INCOME_STATEMENT` - Genera estado de resultados
3. `GENERATE_CASH_FLOW` - Genera estado de flujo de efectivo
4. `GENERATE_FINANCIAL_NOTES` - Genera notas a estados financieros

### Proceso 3: REPORT_VALIDATION (Ejecución serial)
**Actividades**:
1. `VALIDATE_CONSISTENCY` - Valida consistencia entre reportes
2. `VERIFY_TOTALS` - Verifica totales y subtotales
3. `GENERATE_CERTIFICATION` - Genera certificación de reportes

### Proceso 4: REPORT_DISTRIBUTION (Ejecución paralela)
**Actividades**:
1. `SEND_TO_MANAGEMENT` - Envía reportes a gerencia
2. `SEND_TO_AUDIT` - Envía reportes a auditoría externa
3. `PUBLISH_TO_PORTAL` - Publica reportes en portal corporativo
4. `ARCHIVE_HISTORICAL` - Archiva reportes históricos

## Código de Implementación

### 1. Definición de Actividades (con Captura Automática de Parámetros)

```sql
-- Actividades del Proceso 1: DATA_PREPARATION
BEGIN
  -- Actividad: Validar datos contables
  -- Los parámetros se capturan automáticamente de PCK_FINANCIAL_REPORTS.validate_accounting_data
  PCK_BATCH_UTILS.createActivity(
    code => 'VALIDATE_ACCOUNTING_DATA',
    name => 'Validate Accounting Data',
    action => 'PCK_FINANCIAL_REPORTS.validate_accounting_data',
    description => 'Validates the integrity and consistency of accounting data'
  );
  
  -- Actividad: Calcular balances
  -- Los parámetros se capturan automáticamente de PCK_FINANCIAL_REPORTS.calculate_account_balances
  PCK_BATCH_UTILS.createActivity(
    code => 'CALCULATE_BALANCES',
    name => 'Calculate Balances',
    action => 'PCK_FINANCIAL_REPORTS.calculate_account_balances',
    description => 'Calculates balances for all accounting accounts'
  );
  
  -- Actividad: Consolidar empresas
  -- Los parámetros se capturan automáticamente de PCK_FINANCIAL_REPORTS.consolidate_companies
  PCK_BATCH_UTILS.createActivity(
    code => 'CONSOLIDATE_COMPANIES',
    name => 'Consolidate Companies',
    action => 'PCK_FINANCIAL_REPORTS.consolidate_companies',
    description => 'Consolidates data from multiple subsidiary companies'
  );
END;
/

-- Actividades del Proceso 2: REPORT_GENERATION
BEGIN
  -- Actividad: Generar balance general
  -- Los parámetros se capturan automáticamente de PCK_FINANCIAL_REPORTS.generate_balance_sheet
  PCK_BATCH_UTILS.createActivity(
    code => 'GENERATE_BALANCE_SHEET',
    name => 'Generate Balance Sheet',
    action => 'PCK_FINANCIAL_REPORTS.generate_balance_sheet',
    description => 'Generates the consolidated balance sheet'
  );
  
  -- Actividad: Generar estado de resultados
  -- Los parámetros se capturan automáticamente de PCK_FINANCIAL_REPORTS.generate_income_statement
  PCK_BATCH_UTILS.createActivity(
    code => 'GENERATE_INCOME_STATEMENT',
    name => 'Generate Income Statement',
    action => 'PCK_FINANCIAL_REPORTS.generate_income_statement',
    description => 'Generates the consolidated income statement'
  );
  
  -- Actividad: Generar estado de flujo de efectivo
  -- Los parámetros se capturan automáticamente de PCK_FINANCIAL_REPORTS.generate_cash_flow
  PCK_BATCH_UTILS.createActivity(
    code => 'GENERATE_CASH_FLOW',
    name => 'Generate Cash Flow Statement',
    action => 'PCK_FINANCIAL_REPORTS.generate_cash_flow',
    description => 'Generates the cash flow statement'
  );
  
  -- Actividad: Generar notas financieras
  -- Los parámetros se capturan automáticamente de PCK_FINANCIAL_REPORTS.generate_financial_notes
  PCK_BATCH_UTILS.createActivity(
    code => 'GENERATE_FINANCIAL_NOTES',
    name => 'Generate Financial Notes',
    action => 'PCK_FINANCIAL_REPORTS.generate_financial_notes',
    description => 'Generates notes to financial statements'
  );
END;
/
```

### 2. Definición de Procesos

```sql
-- Proceso 1: DATA_PREPARATION (Ejecución serial)
PCK_BATCH_UTILS.createProcess(
  code => 'DATA_PREPARATION',
  name => 'Data Preparation',
  description => 'Prepares and validates all data necessary for reports',
  config => '{"execution_mode": "sequential", "timeout": 1800, "retry_count": 2}',
  chain => 'MONTHLY_FINANCIAL_REPORTS',
  order_num => 1
);

-- Proceso 2: REPORT_GENERATION (Ejecución paralela)
PCK_BATCH_UTILS.createProcess(
  code => 'REPORT_GENERATION',
  name => 'Report Generation',
  description => 'Generates all financial reports in parallel',
  config => '{"execution_mode": "parallel", "max_parallel_jobs": 4, "timeout": 3600}',
  chain => 'MONTHLY_FINANCIAL_REPORTS',
  order_num => 2
);

-- Proceso 3: REPORT_VALIDATION (Ejecución serial)
PCK_BATCH_UTILS.createProcess(
  code => 'REPORT_VALIDATION',
  name => 'Report Validation',
  description => 'Validates and certifies all generated reports',
  config => '{"execution_mode": "sequential", "timeout": 900, "validation_strict": true}',
  chain => 'MONTHLY_FINANCIAL_REPORTS',
  order_num => 3
);

-- Proceso 4: REPORT_DISTRIBUTION (Ejecución paralela)
PCK_BATCH_UTILS.createProcess(
  code => 'REPORT_DISTRIBUTION',
  name => 'Report Distribution',
  description => 'Distributes reports to all recipients',
  config => '{"execution_mode": "parallel", "max_parallel_jobs": 4, "timeout": 600}',
  chain => 'MONTHLY_FINANCIAL_REPORTS',
  order_num => 4
);
```

### 3. Definición de Cadena

```sql
-- Crear la cadena principal
PCK_BATCH_UTILS.createChain(
  code => 'MONTHLY_FINANCIAL_REPORTS',
  name => 'Monthly Financial Reports',
  description => 'Complete chain for monthly financial report generation',
  config => '{"timeout": 7200, "retry_count": 3, "notification_email": "admin@acme.com"}'
);
```

### 4. Asociación de Actividades a Procesos

```sql
-- Asociar actividades al Proceso 1: DATA_PREPARATION (serial)
PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'DATA_PREPARATION',
  activity_code => 'VALIDATE_ACCOUNTING_DATA',
  config => '{"order": 1, "timeout": 300}',
  predecessors => '{}'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'DATA_PREPARATION',
  activity_code => 'CALCULATE_BALANCES',
  config => '{"order": 2, "timeout": 600}',
  predecessors => '["VALIDATE_ACCOUNTING_DATA"]'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'DATA_PREPARATION',
  activity_code => 'CONSOLIDATE_COMPANIES',
  config => '{"order": 3, "timeout": 900}',
  predecessors => '["CALCULATE_BALANCES"]'
);

-- Asociar actividades al Proceso 2: REPORT_GENERATION (paralelo)
PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'REPORT_GENERATION',
  activity_code => 'GENERATE_BALANCE_SHEET',
  config => '{"order": 1, "timeout": 1200}',
  predecessors => '{}'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'REPORT_GENERATION',
  activity_code => 'GENERATE_INCOME_STATEMENT',
  config => '{"order": 1, "timeout": 900}',
  predecessors => '{}'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'REPORT_GENERATION',
  activity_code => 'GENERATE_CASH_FLOW',
  config => '{"order": 1, "timeout": 1500}',
  predecessors => '{}'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'REPORT_GENERATION',
  activity_code => 'GENERATE_FINANCIAL_NOTES',
  config => '{"order": 1, "timeout": 1800}',
  predecessors => '{}'
);
```

### 5. Asociación de Procesos a Cadena

```sql
-- Asociar procesos a la cadena con dependencias
PCK_BATCH_UTILS.addProcessToChain(
  chain_code => 'MONTHLY_FINANCIAL_REPORTS',
  process_code => 'DATA_PREPARATION',
  predecessors => '{}',
  comments => 'First process: data preparation'
);

PCK_BATCH_UTILS.addProcessToChain(
  chain_code => 'MONTHLY_FINANCIAL_REPORTS',
  process_code => 'REPORT_GENERATION',
  predecessors => '["DATA_PREPARATION"]',
  comments => 'Second process: report generation (depends on preparation)'
);

PCK_BATCH_UTILS.addProcessToChain(
  chain_code => 'MONTHLY_FINANCIAL_REPORTS',
  process_code => 'REPORT_VALIDATION',
  predecessors => '["REPORT_GENERATION"]',
  comments => 'Third process: report validation (depends on generation)'
);

PCK_BATCH_UTILS.addProcessToChain(
  chain_code => 'MONTHLY_FINANCIAL_REPORTS',
  process_code => 'REPORT_DISTRIBUTION',
  predecessors => '["REPORT_VALIDATION"]',
  comments => 'Fourth process: report distribution (depends on validation)'
);
```

### 2. **Configuración Simple**

## Estrategia de Desarrollo con Actividades Simuladas

### Fase 1: Desarrollo con Simulación

```sql
-- Crear actividades simuladas para desarrollo
BEGIN
  -- Actividad simulada para validación de datos (duración fija de 5 minutos)
  PCK_BATCH_SIM.activity('VALIDATE_ACCOUNTING_DATA', 300);
  
  -- Actividad simulada para cálculo de balances (duración fija de 10 minutos)
  PCK_BATCH_SIM.activity('CALCULATE_BALANCES', 600);
  
  -- Actividad simulada para consolidación (duración fija de 15 minutos)
  PCK_BATCH_SIM.activity('CONSOLIDATE_COMPANIES', 900);
  
  -- Actividad simulada con duración aleatoria (entre 10-120 segundos)
  PCK_BATCH_SIM.activity('GENERATE_BALANCE_SHEET');
  
  -- Actividad simulada con duración aleatoria
  PCK_BATCH_SIM.activity('GENERATE_INCOME_STATEMENT');
END;
/
```

### Fase 2: Migración a Actividades Reales

```sql
-- Reemplazar actividades simuladas con reales
-- (Esto se hace actualizando las acciones en actividades ya creadas)
DECLARE
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
BEGIN
  -- Actualizar actividad de validación
  v_activity_record := PCK_BATCH_UTILS.getActivityByCode('VALIDATE_ACCOUNTING_DATA');
  v_activity_record.action := 'PCK_FINANCIAL_REPORTS.validate_accounting_data';
  v_activity_record.description := 'Validates the integrity and consistency of accounting data (REAL)';
  PCK_BATCH_UTILS.saveActivity(v_activity_record);
  
  -- Actualizar actividad de cálculo
  v_activity_record := PCK_BATCH_UTILS.getActivityByCode('CALCULATE_BALANCES');
  v_activity_record.action := 'PCK_FINANCIAL_REPORTS.calculate_account_balances';
  v_activity_record.description := 'Calculates balances for all accounting accounts (REAL)';
  PCK_BATCH_UTILS.saveActivity(v_activity_record);
  
  -- Actualizar actividad de consolidación
  v_activity_record := PCK_BATCH_UTILS.getActivityByCode('CONSOLIDATE_COMPANIES');
  v_activity_record.action := 'PCK_FINANCIAL_REPORTS.consolidate_companies';
  v_activity_record.description := 'Consolidates data from multiple subsidiary companies (REAL)';
  PCK_BATCH_UTILS.saveActivity(v_activity_record);
  
  -- Re-capturar parámetros para actividades actualizadas
  PCK_BATCH_UTILS.addActivityParameters(
    PCK_BATCH_UTILS.getActivityByCode('VALIDATE_ACCOUNTING_DATA')
  );
  PCK_BATCH_UTILS.addActivityParameters(
    PCK_BATCH_UTILS.getActivityByCode('CALCULATE_BALANCES')
  );
  PCK_BATCH_UTILS.addActivityParameters(
    PCK_BATCH_UTILS.getActivityByCode('CONSOLIDATE_COMPANIES')
  );
END;
/
```

## Monitoreo en Tiempo Real

```sql
-- Monitorear ejecución en tiempo real
SELECT 
  chain_name,
  process_name,
  activity_name,
  status,
  start_time,
  end_time,
  duration_seconds,
  output_message
FROM V_BATCH_ACTIVITY_EXECUTIONS 
WHERE chain_execution_id = (
  SELECT MAX(chain_execution_id) 
  FROM BATCH_CHAIN_EXECUTIONS 
  WHERE chain_name = 'MONTHLY_FINANCIAL_REPORTS'
)
ORDER BY process_execution_order, activity_execution_order;
```

## Ventajas Clave del Sistema

### 1. **Captura Automática de Parámetros**
- No es necesario definir parámetros manualmente
- Los parámetros se capturan automáticamente de las firmas de procedimientos
- Siempre sincronizados con la definición real del procedimiento

### 2. **Configuración Simplificada**
- Configuración mínima requerida
- Enfoque en lógica de negocio, no en infraestructura
- Código limpio y legible

### 3. **Modos de Ejecución Flexibles**
- Soporte para ejecución serial y paralela
- Timeouts y políticas de reintento configurables
- Gestión de dependencias entre actividades y procesos

### 4. **Monitoreo Integral**
- Estado de ejecución en tiempo real
- Logging detallado y seguimiento de errores
- Métricas de rendimiento y análisis

### 5. **Amigable para Desarrollo**
- Modo de simulación para desarrollo seguro
- Migración fácil de simulación a producción
- Control de versiones y gestión de cambios

## Beneficios del Sistema

1. **Productividad**: 90% de reducción en tiempo de configuración debido a la captura automática de parámetros
2. **Confiabilidad**: La sincronización automática elimina errores de configuración
3. **Mantenibilidad**: Los cambios en procedimientos actualizan automáticamente los parámetros
4. **Escalabilidad**: Fácil agregar nuevos procesos y actividades
5. **Monitoreo**: Visibilidad completa del estado de ejecución
6. **Flexibilidad**: Soporta patrones de ejecución serial y paralela

Este ejemplo demuestra cómo el sistema HF Oracle Batch puede manejar procesos batch complejos con configuración mínima y máxima automatización.

## Nota sobre Compatibilidad JSON en Oracle

> **Compatibilidad:**
> - El ejemplo principal usa `JSON_OBJECT_T` y tipos nativos de Oracle para manipulación JSON (recomendado para Oracle 19c y versiones superiores).
> - **Si usas Oracle 12c o versiones anteriores**, debes usar los métodos de utilidad del package `PCK_BATCH_TOOLS` incluido en este sistema, que proporcionan funciones equivalentes para crear y manipular objetos JSON en PL/SQL.
> - Consulta el código fuente o documentación interna de `PCK_BATCH_TOOLS` para métodos disponibles: `getJSONFromSimpleMap`, `getSimpleMapFromSimpleJSON`, `getValueFromSimpleJSON`, etc.

### 6. Ejecución de Cadena

```sql
-- Ejecutar la cadena manualmente
DECLARE
  v_chain_record BATCH_CHAINS%ROWTYPE;
BEGIN
  -- Obtener el registro de la cadena usando la función de utilidad
  v_chain_record := PCK_BATCH_UTILS.getChainByCode('MONTHLY_FINANCIAL_REPORTS');
  
  -- Ejecutar la cadena con parámetros
  -- Nota: run_chain maneja automáticamente el registro de ejecución y finalización
  PCK_BATCH_MANAGER.run_chain(
    chain_id => v_chain_record.id,
    paramsJSON => '{"report_period": "2024-01", "execution_user": "ADMIN", "output_format": "PDF", "EXECUTION_TYPE": "manual"}'
  );
END;
/
``` 