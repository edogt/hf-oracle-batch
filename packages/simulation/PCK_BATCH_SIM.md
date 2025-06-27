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