# PCK_BATCH_SIM - Simulation Package Documentation

## 📋 Overview

The `PCK_BATCH_SIM` package provides simulation capabilities for testing batch processes without affecting production data or systems. It allows developers and testers to validate process flows, timing, and error scenarios in a controlled environment.

## 🎯 Key Features

- **Safe Testing Environment**: Simulate activities without production impact
- **Configurable Durations**: Fixed or random duration simulation
- **Comprehensive Logging**: Detailed activity tracking and debugging
- **Realistic Testing**: Random duration generation for realistic scenarios
- **Integration Ready**: Works seamlessly with other batch management packages

## 🚀 Use Cases

### 1. Process Flow Testing
Test complete process chains without affecting production data:
```sql
BEGIN
  -- Simulate ETL process flow
  PCK_BATCH_SIM.activity('EXTRACT_DATA', 30);
  PCK_BATCH_SIM.activity('TRANSFORM_DATA', 60);
  PCK_BATCH_SIM.activity('LOAD_DATA', 45);
END;
/
```

### 2. Performance Testing
Validate timing and performance scenarios:
```sql
BEGIN
  -- Test long-running processes
  PCK_BATCH_SIM.activity('LONG_RUNNING_PROCESS', 90);
  
  -- Test quick processes
  PCK_BATCH_SIM.activity('QUICK_PROCESS', 15);
END;
/
```

### 3. Random Duration Testing
Test with realistic, unpredictable timing:
```sql
BEGIN
  -- Simulate activities with random durations
  PCK_BATCH_SIM.activity('DATA_PROCESSING');
  PCK_BATCH_SIM.activity('VALIDATION_STEP');
  PCK_BATCH_SIM.activity('NOTIFICATION_SEND');
END;
/
```

### 4. Monitoring System Testing
Validate monitoring and alerting systems:
```sql
BEGIN
  -- Simulate activities that trigger monitoring alerts
  PCK_BATCH_SIM.activity('CRITICAL_PROCESS', 120);
  PCK_BATCH_SIM.activity('BACKGROUND_TASK', 30);
END;
/
```

### 5. Training and Demonstration
Safe environment for training and demos:
```sql
BEGIN
  -- Demonstrate process execution
  PCK_BATCH_SIM.activity('DEMO_EXTRACT', 20);
  PCK_BATCH_SIM.activity('DEMO_TRANSFORM', 40);
  PCK_BATCH_SIM.activity('DEMO_LOAD', 25);
END;
/
```

## 📊 Configuration

### Duration Constants
```sql
-- Minimum activity duration (seconds)
MIN_DURATION = 10

-- Maximum activity duration (seconds)  
MAX_DURATION = 120
```

### Duration Behavior
- **Fixed Duration**: Specify exact duration in seconds
- **Random Duration**: Use 0 or omit parameter for random duration
- **Range Clamping**: Durations are automatically clamped to MIN_DURATION-MAX_DURATION range

## 🔧 API Reference

### Procedure: activity

Simulates an activity execution with configurable duration.

#### Syntax
```sql
PCK_BATCH_SIM.activity(
  p_name IN VARCHAR2 DEFAULT 'unknown',
  p_duration IN INT DEFAULT 0
);
```

#### Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `p_name` | VARCHAR2 | 'unknown' | Name of the activity for logging |
| `p_duration` | INT | 0 | Duration in seconds (0 = random) |

#### Behavior
- **p_duration = 0**: Random duration between 10-120 seconds
- **p_duration < 10**: Uses minimum duration (10 seconds)
- **p_duration > 120**: Uses maximum duration (120 seconds)
- **p_duration = 10-120**: Uses specified duration

#### Logging Output
```
Activity started (45 seconds)
Activity ended
```

## 📝 Examples

### Basic Usage
```sql
-- Simple activity simulation
BEGIN
  PCK_BATCH_SIM.activity('TEST_ACTIVITY', 30);
END;
/
```

### Complex Process Simulation
```sql
-- Simulate complete data processing workflow
DECLARE
  v_start_time TIMESTAMP;
BEGIN
  v_start_time := SYSTIMESTAMP;
  
  -- Extract phase
  PCK_BATCH_SIM.activity('EXTRACT_CUSTOMER_DATA', 25);
  PCK_BATCH_SIM.activity('EXTRACT_ORDER_DATA', 30);
  PCK_BATCH_SIM.activity('EXTRACT_PRODUCT_DATA', 20);
  
  -- Transform phase
  PCK_BATCH_SIM.activity('VALIDATE_DATA', 15);
  PCK_BATCH_SIM.activity('TRANSFORM_CUSTOMERS', 40);
  PCK_BATCH_SIM.activity('TRANSFORM_ORDERS', 35);
  PCK_BATCH_SIM.activity('TRANSFORM_PRODUCTS', 25);
  
  -- Load phase
  PCK_BATCH_SIM.activity('LOAD_DIMENSIONS', 30);
  PCK_BATCH_SIM.activity('LOAD_FACTS', 45);
  PCK_BATCH_SIM.activity('UPDATE_INDEXES', 20);
  
  -- Completion
  PCK_BATCH_SIM.activity('SEND_NOTIFICATIONS', 10);
  
  DBMS_OUTPUT.PUT_LINE('Total execution time: ' || 
    EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time)) || ' seconds');
END;
/
```

### Error Scenario Testing
```sql
-- Simulate process with potential timeout scenarios
BEGIN
  -- Normal processing
  PCK_BATCH_SIM.activity('NORMAL_PROCESS', 30);
  
  -- Simulate slow processing (near timeout)
  PCK_BATCH_SIM.activity('SLOW_PROCESS', 110);
  
  -- Simulate very slow processing (timeout scenario)
  PCK_BATCH_SIM.activity('TIMEOUT_PROCESS', 120);
END;
/
```

### Random Duration Testing
```sql
-- Test with unpredictable timing
BEGIN
  FOR i IN 1..5 LOOP
    PCK_BATCH_SIM.activity('RANDOM_PROCESS_' || i);
  END LOOP;
END;
/
```

## 🔍 Monitoring and Debugging

### Real-time Monitoring
```sql
-- Monitor simulation executions
SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
WHERE activity_name LIKE '%SIM%';

-- Check recent simulation logs
SELECT * FROM BATCH_SIMPLE_LOG 
WHERE message LIKE '%started%' 
ORDER BY timestamp DESC;
```

### Performance Analysis
```sql
-- Analyze simulation performance
SELECT 
  activity_name,
  COUNT(*) as execution_count,
  AVG(duration_seconds) as avg_duration,
  MIN(duration_seconds) as min_duration,
  MAX(duration_seconds) as max_duration
FROM (
  SELECT 
    SUBSTR(message, 1, INSTR(message, ' started') - 1) as activity_name,
    TO_NUMBER(REGEXP_SUBSTR(message, '\((\d+) seconds\)', 1, 1, NULL, 1)) as duration_seconds
  FROM BATCH_SIMPLE_LOG 
  WHERE message LIKE '%started%' 
  AND message LIKE '%seconds%'
)
GROUP BY activity_name
ORDER BY avg_duration DESC;
```

## ⚠️ Important Notes

### Security Considerations
- Requires `USR_BATCH_EXEC` or `ROLE_BATCH_MAN` privileges
- Safe for testing environments
- No impact on production data or systems

### Performance Considerations
- Uses `DBMS_LOCK.SLEEP` for actual time delays
- Sleep time may vary slightly due to system scheduling
- All durations are rounded to nearest second

### Best Practices
- Use descriptive activity names for better debugging
- Combine with `PCK_BATCH_MANAGER` for complete process simulation
- Monitor system resources during long simulations
- Clean up old simulation logs periodically

## 🔗 Related Packages

- **PCK_BATCH_MANAGER**: For managing actual batch processes
- **PCK_BATCH_MONITOR**: For monitoring simulation executions
- **PCK_BATCH_MGR_LOG**: For detailed logging capabilities
- **BATCH_LOGGER**: For comprehensive logging functionality

## 📞 Support

For issues or questions related to this package:
- Check the main [README.md](../../README.md) for general information
- Review [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md) for common issues
- Contact: edogt@hotmail.com

---

**PCK_BATCH_SIM** - Professional simulation capabilities for batch processing testing 🚀 

## 🏢 **Ejemplos Realistas de Uso Empresarial / Realistic Business Usage Examples**

### 🇪🇸 **Flujo Completo del Sistema: Cierre de Cajas**

#### **Paso 1: Identificar Actividades (Procesos PL/SQL)**
```sql
-- Actividades típicas para cierre de cajas
-- 1. Validación de transacciones pendientes
-- 2. Cálculo de totales por caja
-- 3. Conciliación bancaria
-- 4. Generación de reportes
-- 5. Envío de notificaciones
```

#### **Paso 2: Definir Actividades en el Sistema**
```sql
-- Definir actividades con sus acciones PL/SQL
BEGIN
  -- Actividad 1: Validar transacciones pendientes
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'VALIDAR_TRANSACCIONES',
    'Validar transacciones pendientes de cierre',
    'PCK_BATCH_SIM.activity(''VALIDAR_TRANSACCIONES'', 30);',
    'Y'
  );

  -- Actividad 2: Calcular totales por caja
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'CALCULAR_TOTALES_CAJA',
    'Calcular totales de efectivo por caja',
    'PCK_BATCH_SIM.activity(''CALCULAR_TOTALES_CAJA'', 45);',
    'Y'
  );

  -- Actividad 3: Conciliación bancaria
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'CONCILIAR_BANCARIA',
    'Conciliar movimientos bancarios',
    'PCK_BATCH_SIM.activity(''CONCILIAR_BANCARIA'', 60);',
    'Y'
  );

  -- Actividad 4: Generar reportes
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'GENERAR_REPORTE_CIERRE',
    'Generar reporte de cierre de cajas',
    'PCK_BATCH_SIM.activity(''GENERAR_REPORTE_CIERRE'', 25);',
    'Y'
  );

  -- Actividad 5: Enviar notificaciones
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'ENVIAR_NOTIFICACIONES',
    'Enviar notificaciones de cierre completado',
    'PCK_BATCH_SIM.activity(''ENVIAR_NOTIFICACIONES'', 10);',
    'Y'
  );
END;
/
```

#### **Paso 3: Organizar en Procesos**
```sql
-- Crear proceso de cierre de cajas
BEGIN
  PCK_BATCH_MANAGER.CREATE_PROCESS(
    p_process_name => 'CIERRE_CAJAS',
    p_description => 'Proceso completo de cierre de cajas diario'
  );

  -- Agregar actividades al proceso
  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CIERRE_CAJAS',
    p_activity_name => 'VALIDAR_TRANSACCIONES',
    p_description => 'Validar transacciones pendientes',
    p_action => 'PCK_BATCH_SIM.activity(''VALIDAR_TRANSACCIONES'', 30);'
  );

  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CIERRE_CAJAS',
    p_activity_name => 'CALCULAR_TOTALES_CAJA',
    p_description => 'Calcular totales de efectivo',
    p_action => 'PCK_BATCH_SIM.activity(''CALCULAR_TOTALES_CAJA'', 45);'
  );

  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CIERRE_CAJAS',
    p_activity_name => 'CONCILIAR_BANCARIA',
    p_description => 'Conciliar movimientos bancarios',
    p_action => 'PCK_BATCH_SIM.activity(''CONCILIAR_BANCARIA'', 60);'
  );

  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CIERRE_CAJAS',
    p_activity_name => 'GENERAR_REPORTE_CIERRE',
    p_description => 'Generar reporte de cierre',
    p_action => 'PCK_BATCH_SIM.activity(''GENERAR_REPORTE_CIERRE'', 25);'
  );

  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CIERRE_CAJAS',
    p_activity_name => 'ENVIAR_NOTIFICACIONES',
    p_description => 'Enviar notificaciones',
    p_action => 'PCK_BATCH_SIM.activity(''ENVIAR_NOTIFICACIONES'', 10);'
  );
END;
/
```

#### **Paso 4: Crear Cadena y Agregar Proceso**
```sql
-- Crear cadena de procesos financieros
BEGIN
  PCK_BATCH_MANAGER.CREATE_CHAIN(
    p_chain_name => 'PROCESOS_FINANCIEROS',
    p_description => 'Cadena de procesos financieros diarios'
  );

  -- Agregar proceso de cierre de cajas a la cadena
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN(
    p_chain_name => 'PROCESOS_FINANCIEROS',
    p_process_name => 'CIERRE_CAJAS',
    p_description => 'Cierre diario de cajas'
  );
END;
/
```

#### **Paso 5: Configurar Reglas y Parámetros**
```sql
-- Configurar reglas condicionales
BEGIN
  INSERT INTO BATCH_CHAIN_PROCESSES (
    CHAIN_NAME,
    PROCESS_NAME,
    CONDITION_RULES,
    DESCRIPTION
  ) VALUES (
    'PROCESOS_FINANCIEROS',
    'CIERRE_CAJAS',
    '{"CONDITION": "SYSDATE >= TRUNC(SYSDATE) + 22/24", "ACTION": "EXECUTE"}',
    'Ejecutar cierre de cajas después de las 10 PM'
  );
END;
/

-- Configurar parámetros de empresa
BEGIN
  INSERT INTO BATCH_COMPANY_PARAMETERS (
    COMPANY_ID,
    PARAMETER_NAME,
    PARAMETER_VALUE,
    DESCRIPTION
  ) VALUES (
    1,
    'CIERRE_CAJAS_HORA_LIMITE',
    '22:00',
    'Hora límite para cierre de cajas'
  );

  INSERT INTO BATCH_COMPANY_PARAMETERS (
    COMPANY_ID,
    PARAMETER_NAME,
    PARAMETER_VALUE,
    DESCRIPTION
  ) VALUES (
    1,
    'DESTINATARIOS_CIERRE_CAJAS',
    'gerente.finanzas@empresa.com,contador@empresa.com',
    'Destinatarios de notificaciones de cierre'
  );
END;
/
```

#### **Paso 6: Programar Ejecución Automática**
```sql
-- Crear job en DBMS_SCHEDULER para ejecución automática
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'JOB_CIERRE_CAJAS_DIARIO',
    job_type => 'PLSQL_BLOCK',
    job_action => 'BEGIN PCK_BATCH_MANAGER.START_CHAIN_EXECUTION(''PROCESOS_FINANCIEROS'', 1); END;',
    start_date => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=22; BYMINUTE=0',
    enabled => TRUE,
    comments => 'Ejecución automática diaria de cierre de cajas'
  );
END;
/
```

#### **Paso 7: Monitorear Ejecución**
```sql
-- Monitorear ejecución en tiempo real
SELECT * FROM V_BATCH_RUNNING_CHAINS 
WHERE chain_name = 'PROCESOS_FINANCIEROS';

SELECT * FROM V_BATCH_RUNNING_PROCESSES 
WHERE process_name = 'CIERRE_CAJAS';

SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
WHERE activity_name LIKE '%CIERRE%';

-- Verificar jobs programados
SELECT job_name, state, next_run_date, last_run_date 
FROM USER_SCHEDULER_JOBS 
WHERE job_name = 'JOB_CIERRE_CAJAS_DIARIO';
```

---

### 🇬🇧 **Complete System Flow: Cash Register Closing**

#### **Step 1: Identify Activities (PL/SQL Processes)**
```sql
-- Typical activities for cash register closing
-- 1. Validate pending transactions
-- 2. Calculate totals by register
-- 3. Bank reconciliation
-- 4. Generate reports
-- 5. Send notifications
```

#### **Step 2: Define Activities in the System**
```sql
-- Define activities with their PL/SQL actions
BEGIN
  -- Activity 1: Validate pending transactions
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'VALIDATE_TRANSACTIONS',
    'Validate pending closing transactions',
    'PCK_BATCH_SIM.activity(''VALIDATE_TRANSACTIONS'', 30);',
    'Y'
  );

  -- Activity 2: Calculate register totals
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'CALCULATE_REGISTER_TOTALS',
    'Calculate cash totals by register',
    'PCK_BATCH_SIM.activity(''CALCULATE_REGISTER_TOTALS'', 45);',
    'Y'
  );

  -- Activity 3: Bank reconciliation
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'BANK_RECONCILIATION',
    'Reconcile bank movements',
    'PCK_BATCH_SIM.activity(''BANK_RECONCILIATION'', 60);',
    'Y'
  );

  -- Activity 4: Generate reports
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'GENERATE_CLOSING_REPORT',
    'Generate cash register closing report',
    'PCK_BATCH_SIM.activity(''GENERATE_CLOSING_REPORT'', 25);',
    'Y'
  );

  -- Activity 5: Send notifications
  INSERT INTO BATCH_ACTIVITIES (
    ACTIVITY_NAME, 
    DESCRIPTION, 
    ACTION,
    IS_ACTIVE
  ) VALUES (
    'SEND_NOTIFICATIONS',
    'Send closing completion notifications',
    'PCK_BATCH_SIM.activity(''SEND_NOTIFICATIONS'', 10);',
    'Y'
  );
END;
/
```

#### **Step 3: Organize into Processes**
```sql
-- Create cash register closing process
BEGIN
  PCK_BATCH_MANAGER.CREATE_PROCESS(
    p_process_name => 'CASH_REGISTER_CLOSING',
    p_description => 'Complete daily cash register closing process'
  );

  -- Add activities to the process
  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CASH_REGISTER_CLOSING',
    p_activity_name => 'VALIDATE_TRANSACTIONS',
    p_description => 'Validate pending transactions',
    p_action => 'PCK_BATCH_SIM.activity(''VALIDATE_TRANSACTIONS'', 30);'
  );

  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CASH_REGISTER_CLOSING',
    p_activity_name => 'CALCULATE_REGISTER_TOTALS',
    p_description => 'Calculate cash totals',
    p_action => 'PCK_BATCH_SIM.activity(''CALCULATE_REGISTER_TOTALS'', 45);'
  );

  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CASH_REGISTER_CLOSING',
    p_activity_name => 'BANK_RECONCILIATION',
    p_description => 'Reconcile bank movements',
    p_action => 'PCK_BATCH_SIM.activity(''BANK_RECONCILIATION'', 60);'
  );

  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CASH_REGISTER_CLOSING',
    p_activity_name => 'GENERATE_CLOSING_REPORT',
    p_description => 'Generate closing report',
    p_action => 'PCK_BATCH_SIM.activity(''GENERATE_CLOSING_REPORT'', 25);'
  );

  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS(
    p_process_name => 'CASH_REGISTER_CLOSING',
    p_activity_name => 'SEND_NOTIFICATIONS',
    p_description => 'Send notifications',
    p_action => 'PCK_BATCH_SIM.activity(''SEND_NOTIFICATIONS'', 10);'
  );
END;
/
```

#### **Step 4: Create Chain and Add Process**
```sql
-- Create financial processes chain
BEGIN
  PCK_BATCH_MANAGER.CREATE_CHAIN(
    p_chain_name => 'FINANCIAL_PROCESSES',
    p_description => 'Daily financial processes chain'
  );

  -- Add cash register closing process to the chain
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN(
    p_chain_name => 'FINANCIAL_PROCESSES',
    p_process_name => 'CASH_REGISTER_CLOSING',
    p_description => 'Daily cash register closing'
  );
END;
/
```

#### **Step 5: Configure Rules and Parameters**
```sql
-- Configure conditional rules
BEGIN
  INSERT INTO BATCH_CHAIN_PROCESSES (
    CHAIN_NAME,
    PROCESS_NAME,
    CONDITION_RULES,
    DESCRIPTION
  ) VALUES (
    'FINANCIAL_PROCESSES',
    'CASH_REGISTER_CLOSING',
    '{"CONDITION": "SYSDATE >= TRUNC(SYSDATE) + 22/24", "ACTION": "EXECUTE"}',
    'Execute cash register closing after 10 PM'
  );
END;
/

-- Configure company parameters
BEGIN
  INSERT INTO BATCH_COMPANY_PARAMETERS (
    COMPANY_ID,
    PARAMETER_NAME,
    PARAMETER_VALUE,
    DESCRIPTION
  ) VALUES (
    1,
    'CASH_CLOSING_TIME_LIMIT',
    '22:00',
    'Time limit for cash register closing'
  );

  INSERT INTO BATCH_COMPANY_PARAMETERS (
    COMPANY_ID,
    PARAMETER_NAME,
    PARAMETER_VALUE,
    DESCRIPTION
  ) VALUES (
    1,
    'CASH_CLOSING_RECIPIENTS',
    'finance.manager@company.com,accountant@company.com',
    'Cash closing notification recipients'
  );
END;
/
```

#### **Step 6: Schedule Automatic Execution**
```sql
-- Create DBMS_SCHEDULER job for automatic execution
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'JOB_DAILY_CASH_CLOSING',
    job_type => 'PLSQL_BLOCK',
    job_action => 'BEGIN PCK_BATCH_MANAGER.START_CHAIN_EXECUTION(''FINANCIAL_PROCESSES'', 1); END;',
    start_date => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=22; BYMINUTE=0',
    enabled => TRUE,
    comments => 'Daily automatic cash register closing execution'
  );
END;
/
```

#### **Step 7: Monitor Execution**
```sql
-- Monitor execution in real-time
SELECT * FROM V_BATCH_RUNNING_CHAINS 
WHERE chain_name = 'FINANCIAL_PROCESSES';

SELECT * FROM V_BATCH_RUNNING_PROCESSES 
WHERE process_name = 'CASH_REGISTER_CLOSING';

SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
WHERE activity_name LIKE '%CLOSING%';

-- Check scheduled jobs
SELECT job_name, state, next_run_date, last_run_date 
FROM USER_SCHEDULER_JOBS 
WHERE job_name = 'JOB_DAILY_CASH_CLOSING';
```

---

## 🏢 **Otros Casos de Uso Empresariales / Other Business Use Cases**

### 🇪🇸 **Generación de Datos para BI**
```sql
-- Cadena: PROCESOS_BI
-- Procesos: EXTRACCION_DATOS, TRANSFORMACION_DATOS, CARGA_DATOS_BI
-- Actividades: Extraer ventas, transformar métricas, cargar dimensiones, actualizar índices

-- Ejemplo de actividad:
PCK_BATCH_SIM.activity('EXTRACCION_VENTAS_DIARIAS', 120);
PCK_BATCH_SIM.activity('TRANSFORMAR_METRICAS_VENTAS', 90);
PCK_BATCH_SIM.activity('CARGAR_DIMENSIONES_BI', 60);
```

### 🇪🇸 **Cálculo de Remuneraciones**
```sql
-- Cadena: PROCESOS_RRHH
-- Procesos: CALCULO_NOMINA, GENERACION_BOLETAS, ENVIO_BANCOS
-- Actividades: Calcular horas, procesar bonos, generar boletas, enviar a bancos

-- Ejemplo de actividad:
PCK_BATCH_SIM.activity('CALCULAR_HORAS_TRABAJADAS', 45);
PCK_BATCH_SIM.activity('PROCESAR_BONOS_INCENTIVOS', 30);
PCK_BATCH_SIM.activity('GENERAR_BOLETAS_PAGO', 75);
```

### 🇪🇸 **Generación de Informes de Gestión**
```sql
-- Cadena: PROCESOS_REPORTES
-- Procesos: CONSOLIDACION_DATOS, GENERACION_REPORTES, DISTRIBUCION
-- Actividades: Consolidar métricas, generar PDFs, enviar por email

-- Ejemplo de actividad:
PCK_BATCH_SIM.activity('CONSOLIDAR_METRICAS_VENTAS', 40);
PCK_BATCH_SIM.activity('GENERAR_REPORTE_PDF', 35);
PCK_BATCH_SIM.activity('ENVIAR_REPORTE_EMAIL', 15);
```

---

## 🌐 Ejemplo de uso típico en cadenas y procesos de simulación / Typical usage in simulation chains and processes

### 🇪🇸 **Definición de una actividad de simulación en una cadena**

Supón que tienes una cadena de simulación y quieres agregar una actividad que simule la validación de datos durante 15 segundos. El campo `action` de la actividad se define así:

```sql
-- Ejemplo de inserción en BATCH_ACTIVITY_PARAMETERS o configuración de actividad
ACTION => "PCK_BATCH_SIM.activity('VALIDATE_DATA', 15);"
```

Luego, al ejecutar la cadena, el sistema llamará automáticamente a esa acción, simulando la actividad.

### 🇬🇧 **Defining a simulation activity in a chain**

Suppose you have a simulation chain and want to add an activity that simulates data validation for 15 seconds. The `action` field of the activity is defined as:

```sql
-- Example of insertion in BATCH_ACTIVITY_PARAMETERS or activity configuration
ACTION => "PCK_BATCH_SIM.activity('VALIDATE_DATA', 15);"
```

When the chain is executed, the system will automatically call that action, simulating the activity.

### 🇪🇸 **Ejemplo completo: Cadena de simulación**

```sql
-- Definir una cadena de simulación con tres actividades
BEGIN
  PCK_BATCH_MANAGER.CREATE_CHAIN('SIMULACION_ETL', 'Cadena de simulación ETL');
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN('SIMULACION_ETL', 'EXTRACCION', 'Extracción de datos');
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN('SIMULACION_ETL', 'TRANSFORMACION', 'Transformación de datos');
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN('SIMULACION_ETL', 'CARGA', 'Carga de datos');

  -- Agregar actividades simuladas a cada proceso
  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS('EXTRACCION', 'EXTRAER_DATOS', 'Simula extracción',
    'PCK_BATCH_SIM.activity(''EXTRAER_DATOS'', 20);');
  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS('TRANSFORMACION', 'VALIDAR_DATOS', 'Simula validación',
    'PCK_BATCH_SIM.activity(''VALIDAR_DATOS'', 15);');
  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS('CARGA', 'CARGAR_DATOS', 'Simula carga',
    'PCK_BATCH_SIM.activity(''CARGAR_DATOS'', 25);');
END;
/

-- Ejecutar la cadena de simulación
DECLARE
  v_exec_id NUMBER;
BEGIN
  v_exec_id := PCK_BATCH_MANAGER.START_CHAIN_EXECUTION('SIMULACION_ETL', 1);
  DBMS_OUTPUT.PUT_LINE('ID de ejecución: ' || v_exec_id);
END;
/
```

## 🇬🇧 **Full Example: Simulation Chain**

```sql
-- Define a simulation chain with three activities
BEGIN
  PCK_BATCH_MANAGER.CREATE_CHAIN('SIMULATION_ETL', 'ETL Simulation Chain');
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN('SIMULATION_ETL', 'EXTRACTION', 'Data extraction');
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN('SIMULATION_ETL', 'TRANSFORMATION', 'Data transformation');
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN('SIMULATION_ETL', 'LOAD', 'Data load');

  -- Add simulated activities to each process
  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS('EXTRACTION', 'EXTRACT_DATA', 'Simulate extraction',
    'PCK_BATCH_SIM.activity(''EXTRACT_DATA'', 20);');
  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS('TRANSFORMATION', 'VALIDATE_DATA', 'Simulate validation',
    'PCK_BATCH_SIM.activity(''VALIDATE_DATA'', 15);');
  PCK_BATCH_MANAGER.ADD_ACTIVITY_TO_PROCESS('LOAD', 'LOAD_DATA', 'Simulate load',
    'PCK_BATCH_SIM.activity(''LOAD_DATA'', 25);');
END;
/

-- Execute the simulation chain
DECLARE
  v_exec_id NUMBER;
BEGIN
  v_exec_id := PCK_BATCH_MANAGER.START_CHAIN_EXECUTION('SIMULATION_ETL', 1);
  DBMS_OUTPUT.PUT_LINE('Execution ID: ' || v_exec_id);
END;
/
```

---

## 📋 (El resto de la documentación continúa igual...) 