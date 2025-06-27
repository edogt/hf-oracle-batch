# Ejemplos de Uso Realistas - HF Oracle Batch

> **📖 [View English version](REALISTIC_USAGE_EXAMPLES.md)**

## Descripción General

Este documento presenta ejemplos prácticos del sistema HF Oracle Batch, mostrando cómo implementar cadenas de procesos batch complejas con ejecución en serie y paralelo.

**⚠️ IMPORTANTE**: Los ejemplos están basados en la API real del sistema. Para obtener la documentación completa de cada paquete, consulta las especificaciones en el directorio `packages/`.

## Esquema de Ejemplo: Sistema de Reportes Financieros

### Cadena: REPORTES_FINANCIEROS_MENSUALES
- **Descripción**: Genera reportes financieros completos al final de cada mes
- **Frecuencia**: Mensual (primer día del mes siguiente)
- **Procesos**: 4 procesos principales

### Proceso 1: PREPARACION_DATOS (Ejecución en serie)
**Actividades**:
1. `VALIDAR_DATOS_CONTABLES` - Valida integridad de datos contables
2. `CALCULAR_BALANCES` - Calcula balances de cuentas
3. `CONSOLIDAR_EMPRESAS` - Consolida datos de múltiples empresas

### Proceso 2: GENERACION_REPORTES (Ejecución en paralelo)
**Actividades**:
1. `GENERAR_BALANCE_GENERAL` - Genera balance general
2. `GENERAR_ESTADO_RESULTADOS` - Genera estado de resultados
3. `GENERAR_FLUJO_EFECTIVO` - Genera flujo de efectivo
4. `GENERAR_NOTAS_FINANCIERAS` - Genera notas a estados financieros

### Proceso 3: VALIDACION_REPORTES (Ejecución en serie)
**Actividades**:
1. `VALIDAR_CONSISTENCIA` - Valida consistencia entre reportes
2. `VERIFICAR_TOTALES` - Verifica totales y subtotales
3. `GENERAR_CERTIFICACION` - Genera certificación de reportes

### Proceso 4: DISTRIBUCION_REPORTES (Ejecución en paralelo)
**Actividades**:
1. `ENVIAR_GERENCIA` - Envía reportes a gerencia
2. `ENVIAR_AUDITORIA` - Envía reportes a auditoría externa
3. `PUBLICAR_PORTAL` - Publica reportes en portal corporativo
4. `ARCHIVAR_HISTORICO` - Archiva reportes históricos

## Código de Implementación

### 1. Definición de Actividades

```sql
-- Actividades del Proceso 1: PREPARACION_DATOS
DECLARE
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
BEGIN
  -- Actividad: Validar datos contables
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Validar Datos Contables',
    p_action => 'PCK_FINANCIAL_REPORTS.validate_accounting_data',
    p_code => 'VALIDAR_DATOS_CONTABLES',
    p_description => 'Valida la integridad y consistencia de los datos contables',
    p_parameters => '{"timeout": 300, "validation_level": "strict"}'
  );
  
  -- Actividad: Calcular balances
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Calcular Balances',
    p_action => 'PCK_FINANCIAL_REPORTS.calculate_account_balances',
    p_code => 'CALCULAR_BALANCES',
    p_description => 'Calcula balances de todas las cuentas contables',
    p_parameters => '{"timeout": 600, "include_subaccounts": true}'
  );
  
  -- Actividad: Consolidar empresas
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Consolidar Empresas',
    p_action => 'PCK_FINANCIAL_REPORTS.consolidate_companies',
    p_code => 'CONSOLIDAR_EMPRESAS',
    p_description => 'Consolida datos de múltiples empresas subsidiarias',
    p_parameters => '{"timeout": 900, "consolidation_method": "full"}'
  );
END;
/

-- Actividades del Proceso 2: GENERACION_REPORTES
DECLARE
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
BEGIN
  -- Actividad: Generar balance general
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Generar Balance General',
    p_action => 'PCK_FINANCIAL_REPORTS.generate_balance_sheet',
    p_code => 'GENERAR_BALANCE_GENERAL',
    p_description => 'Genera el balance general consolidado',
    p_parameters => '{"timeout": 1200, "format": "PDF", "include_charts": true}'
  );
  
  -- Actividad: Generar estado de resultados
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Generar Estado de Resultados',
    p_action => 'PCK_FINANCIAL_REPORTS.generate_income_statement',
    p_code => 'GENERAR_ESTADO_RESULTADOS',
    p_description => 'Genera el estado de resultados consolidado',
    p_parameters => '{"timeout": 900, "format": "PDF", "include_charts": true}'
  );
  
  -- Actividad: Generar flujo de efectivo
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Generar Flujo de Efectivo',
    p_action => 'PCK_FINANCIAL_REPORTS.generate_cash_flow',
    p_code => 'GENERAR_FLUJO_EFECTIVO',
    p_description => 'Genera el estado de flujo de efectivo',
    p_parameters => '{"timeout": 1500, "format": "PDF", "include_charts": true}'
  );
  
  -- Actividad: Generar notas financieras
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Generar Notas Financieras',
    p_action => 'PCK_FINANCIAL_REPORTS.generate_financial_notes',
    p_code => 'GENERAR_NOTAS_FINANCIERAS',
    p_description => 'Genera las notas a los estados financieros',
    p_parameters => '{"timeout": 1800, "format": "PDF", "include_legal_text": true}'
  );
END;
/
```

### 2. Definición de Procesos

```sql
-- Proceso 1: PREPARACION_DATOS (Ejecución en serie)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  v_process_record := PCK_BATCH_MGR_CHAINS.create_process(
    p_name => 'Preparación de Datos',
    p_code => 'PREPARACION_DATOS',
    p_description => 'Prepara y valida todos los datos necesarios para los reportes',
    p_config => '{"execution_mode": "sequential", "timeout": 1800, "retry_count": 2}',
    p_chain => 'REPORTES_FINANCIEROS_MENSUALES',
    p_order => '1'
  );
END;
/

-- Proceso 2: GENERACION_REPORTES (Ejecución en paralelo)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  v_process_record := PCK_BATCH_MGR_CHAINS.create_process(
    p_name => 'Generación de Reportes',
    p_code => 'GENERACION_REPORTES',
    p_description => 'Genera todos los reportes financieros en paralelo',
    p_config => '{"execution_mode": "parallel", "max_parallel_jobs": 4, "timeout": 3600}',
    p_chain => 'REPORTES_FINANCIEROS_MENSUALES',
    p_order => '2'
  );
END;
/

-- Proceso 3: VALIDACION_REPORTES (Ejecución en serie)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  v_process_record := PCK_BATCH_MGR_CHAINS.create_process(
    p_name => 'Validación de Reportes',
    p_code => 'VALIDACION_REPORTES',
    p_description => 'Valida y certifica todos los reportes generados',
    p_config => '{"execution_mode": "sequential", "timeout": 900, "validation_strict": true}',
    p_chain => 'REPORTES_FINANCIEROS_MENSUALES',
    p_order => '3'
  );
END;
/

-- Proceso 4: DISTRIBUCION_REPORTES (Ejecución en paralelo)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  v_process_record := PCK_BATCH_MGR_CHAINS.create_process(
    p_name => 'Distribución de Reportes',
    p_code => 'DISTRIBUCION_REPORTES',
    p_description => 'Distribuye los reportes a todos los destinatarios',
    p_config => '{"execution_mode": "parallel", "max_parallel_jobs": 4, "timeout": 600}',
    p_chain => 'REPORTES_FINANCIEROS_MENSUALES',
    p_order => '4'
  );
END;
/
```

### 3. Definición de Cadena

```sql
-- Crear la cadena principal
DECLARE
  v_chain_record BATCH_CHAINS%ROWTYPE;
BEGIN
  v_chain_record := PCK_BATCH_MGR_CHAINS.create_chain(
    p_name => 'Reportes Financieros Mensuales',
    p_code => 'REPORTES_FINANCIEROS_MENSUALES',
    p_description => 'Cadena completa para generación de reportes financieros mensuales',
    p_config => '{"timeout": 7200, "retry_count": 3, "notification_email": "admin@acme.com"}'
  );
END;
/
```

### 4. Asociación de Actividades a Procesos

```sql
-- Asociar actividades al Proceso 1: PREPARACION_DATOS (en serie)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
  v_proc_activ_record BATCH_PROCESS_ACTIVITIES%ROWTYPE;
BEGIN
  -- Obtener proceso y actividades existentes
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'PREPARACION_DATOS';
  
  -- Agregar actividad 1: Validar datos contables
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'VALIDAR_DATOS_CONTABLES';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Validar Datos Contables',
    p_config => '{"order": 1, "timeout": 300}',
    p_predecessors => '{}'
  );
  
  -- Agregar actividad 2: Calcular balances (depende de validación)
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'CALCULAR_BALANCES';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Calcular Balances',
    p_config => '{"order": 2, "timeout": 600}',
    p_predecessors => '["VALIDAR_DATOS_CONTABLES"]'
  );
  
  -- Agregar actividad 3: Consolidar empresas (depende de cálculo)
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'CONSOLIDAR_EMPRESAS';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Consolidar Empresas',
    p_config => '{"order": 3, "timeout": 900}',
    p_predecessors => '["CALCULAR_BALANCES"]'
  );
END;
/

-- Asociar actividades al Proceso 2: GENERACION_REPORTES (en paralelo)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
  v_proc_activ_record BATCH_PROCESS_ACTIVITIES%ROWTYPE;
BEGIN
  -- Obtener proceso existente
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'GENERACION_REPORTES';
  
  -- Agregar actividades en paralelo (todas con el mismo orden)
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'GENERAR_BALANCE_GENERAL';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Generar Balance General',
    p_config => '{"order": 1, "timeout": 1200}',
    p_predecessors => '{}'
  );
  
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'GENERAR_ESTADO_RESULTADOS';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Generar Estado de Resultados',
    p_config => '{"order": 1, "timeout": 900}',
    p_predecessors => '{}'
  );
  
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'GENERAR_FLUJO_EFECTIVO';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Generar Flujo de Efectivo',
    p_config => '{"order": 1, "timeout": 1500}',
    p_predecessors => '{}'
  );
  
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'GENERAR_NOTAS_FINANCIERAS';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Generar Notas Financieras',
    p_config => '{"order": 1, "timeout": 1800}',
    p_predecessors => '{}'
  );
END;
/
```

### 5. Asociación de Procesos a Cadena

```sql
-- Asociar procesos a la cadena con dependencias
DECLARE
  v_chain_record BATCH_CHAINS%ROWTYPE;
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  -- Obtener cadena existente
  SELECT * INTO v_chain_record FROM BATCH_CHAINS WHERE code = 'REPORTES_FINANCIEROS_MENSUALES';
  
  -- Agregar Proceso 1: PREPARACION_DATOS (sin predecesores)
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'PREPARACION_DATOS';
  PCK_BATCH_MGR_CHAINS.add_process_to_chain(
    p_chain => v_chain_record,
    p_process => v_process_record,
    p_predecesors => '{}',
    comments => 'Primer proceso: preparación de datos'
  );
  
  -- Agregar Proceso 2: GENERACION_REPORTES (depende de PREPARACION_DATOS)
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'GENERACION_REPORTES';
  PCK_BATCH_MGR_CHAINS.add_process_to_chain(
    p_chain => v_chain_record,
    p_process => v_process_record,
    p_predecesors => '["PREPARACION_DATOS"]',
    comments => 'Segundo proceso: generación de reportes (depende de preparación)'
  );
  
  -- Agregar Proceso 3: VALIDACION_REPORTES (depende de GENERACION_REPORTES)
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'VALIDACION_REPORTES';
  PCK_BATCH_MGR_CHAINS.add_process_to_chain(
    p_chain => v_chain_record,
    p_process => v_process_record,
    p_predecesors => '["GENERACION_REPORTES"]',
    comments => 'Tercer proceso: validación de reportes (depende de generación)'
  );
  
  -- Agregar Proceso 4: DISTRIBUCION_REPORTES (depende de VALIDACION_REPORTES)
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'DISTRIBUCION_REPORTES';
  PCK_BATCH_MGR_CHAINS.add_process_to_chain(
    p_chain => v_chain_record,
    p_process => v_process_record,
    p_predecesors => '["VALIDACION_REPORTES"]',
    comments => 'Cuarto proceso: distribución de reportes (depende de validación)'
  );
END;
/
```

### 6. Ejecución de la Cadena

```sql
-- Ejecutar la cadena manualmente
DECLARE
  v_chain_exec_id NUMBER;
BEGIN
  -- Registrar inicio de ejecución de la cadena
  v_chain_exec_id := PCK_BATCH_MANAGER.chain_execution_register(
    chain_code => 'REPORTES_FINANCIEROS_MENSUALES',
    execution_type => 'manual',
    sim_mode => FALSE,
    execution_comments => 'Ejecución manual de reportes financieros - Enero 2024'
  );
  
  -- Ejecutar la cadena con parámetros
  PCK_BATCH_MANAGER.run_chain(
    chain_id => v_chain_exec_id,
    paramsJSON => '{"periodo_reporte": "2024-01", "usuario_ejecucion": "ADMIN", "formato_salida": "PDF"}'
  );
  
  -- Registrar finalización exitosa
  PCK_BATCH_MANAGER.chain_exec_end_register(
    chain_exec_id => v_chain_exec_id,
    end_type => 'finished',
    end_comments => 'Reportes financieros generados exitosamente'
  );
END;
/
```

### 7. Monitoreo y Consultas

```sql
-- Ver estado actual de la cadena
SELECT * FROM V_BATCH_CHAIN_EXECUTIONS 
WHERE chain_name = 'REPORTES_FINANCIEROS_MENSUALES'
ORDER BY start_time DESC;

-- Ver actividades en ejecución
SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
WHERE chain_name = 'REPORTES_FINANCIEROS_MENSUALES';

-- Ver último estado de cada proceso
SELECT * FROM V_BATCH_PROCS_LAST_EXECS 
WHERE chain_name = 'REPORTES_FINANCIEROS_MENSUALES';

-- Ver logs detallados
SELECT * FROM V_BATCH_SIMPLE_LOG 
WHERE chain_name = 'REPORTES_FINANCIEROS_MENSUALES'
ORDER BY log_timestamp DESC;

-- Ver jerarquía completa de la cadena
SELECT * FROM V_BATCH_DEFINITION_HIERARCHY 
WHERE chain_name = 'REPORTES_FINANCIEROS_MENSUALES'
ORDER BY level_id, execution_order;
```

## Estrategia de Desarrollo con Actividades Simuladas

### Fase 1: Desarrollo con Simulación

```sql
-- Crear actividades simuladas para desarrollo
BEGIN
  -- Actividad simulada para validación de datos (duración fija de 5 minutos)
  PCK_BATCH_SIM.activity('VALIDAR_DATOS_CONTABLES', 300);
  
  -- Actividad simulada para cálculo de balances (duración fija de 10 minutos)
  PCK_BATCH_SIM.activity('CALCULAR_BALANCES', 600);
  
  -- Actividad simulada para consolidación (duración fija de 15 minutos)
  PCK_BATCH_SIM.activity('CONSOLIDAR_EMPRESAS', 900);
  
  -- Actividad simulada con duración aleatoria (entre 10-120 segundos)
  PCK_BATCH_SIM.activity('GENERAR_BALANCE_GENERAL');
  
  -- Actividad simulada con duración aleatoria
  PCK_BATCH_SIM.activity('GENERAR_ESTADO_RESULTADOS');
END;
/
```

### Fase 2: Migración a Actividades Reales

```sql
-- Reemplazar actividades simuladas por reales
-- (Esto se hace actualizando las acciones en las actividades ya creadas)
DECLARE
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
BEGIN
  -- Actualizar actividad de validación
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'VALIDAR_DATOS_CONTABLES';
  UPDATE BATCH_ACTIVITIES 
  SET action = 'PCK_FINANCIAL_REPORTS.validate_accounting_data',
      description = 'Valida la integridad y consistencia de los datos contables (REAL)'
  WHERE code = 'VALIDAR_DATOS_CONTABLES';
  
  -- Actualizar actividad de cálculo
  UPDATE BATCH_ACTIVITIES 
  SET action = 'PCK_FINANCIAL_REPORTS.calculate_account_balances',
      description = 'Calcula balances de todas las cuentas contables (REAL)'
  WHERE code = 'CALCULAR_BALANCES';
  
  -- Actualizar actividad de consolidación
  UPDATE BATCH_ACTIVITIES 
  SET action = 'PCK_FINANCIAL_REPORTS.consolidate_companies',
      description = 'Consolida datos de múltiples empresas subsidiarias (REAL)'
  WHERE code = 'CONSOLIDAR_EMPRESAS';
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
  WHERE chain_name = 'REPORTES_FINANCIEROS_MENSUALES'
)
ORDER BY process_execution_order, activity_execution_order;
```

## Beneficios del Sistema

1. **Flexibilidad**: Permite ejecución en serie y paralelo según necesidades
2. **Escalabilidad**: Fácil agregar nuevos procesos y actividades
3. **Monitoreo**: Visibilidad completa del estado de ejecución
4. **Mantenibilidad**: Separación clara entre lógica de negocio y orquestación
5. **Confiabilidad**: Manejo robusto de errores y dependencias
6. **Desarrollo**: Estrategia de simulación para desarrollo seguro

Este ejemplo demuestra cómo el sistema HF Oracle Batch puede manejar procesos batch complejos de manera eficiente y confiable.

## Nota sobre compatibilidad de JSON en Oracle

> **Compatibilidad:**
> - El ejemplo principal utiliza `JSON_OBJECT_T` y tipos nativos de Oracle para manipulación de JSON (recomendado para Oracle 19c y versiones superiores).
> - **Si usas Oracle 12c o anterior**, debes utilizar los métodos utilitarios del paquete `PCK_BATCH_TOOLS` incluidos en este sistema, que proveen funciones equivalentes para crear y manipular objetos JSON en PL/SQL.
> - Consulta el código fuente o la documentación interna de `PCK_BATCH_TOOLS` para ver los métodos disponibles: `getJSONFromSimpleMap`, `getSimpleMapFromSimpleJSON`, `getValueFromSimpleJSON`, etc.
</rewritten_file> 