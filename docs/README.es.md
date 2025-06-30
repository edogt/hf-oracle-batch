# HF Oracle Batch

> **Para versión en inglés, ver [README.md](README.md)**

**HF** significa **HoldFast** - representando la capacidad del sistema para mantener y gestionar procesos batch de manera segura con confiabilidad y consistencia.

Sistema integral de gestión de procesos batch basado en Oracle diseñado para orquestar, monitorear y rastrear flujos de trabajo complejos de procesamiento de datos. HF proporciona un marco robusto para gestionar cadenas de procesos, actividades y ejecuciones con trazabilidad completa y manejo de errores.

## 📋 ¿Qué es HF Oracle Batch?

HF es un sistema completo de gestión de procesos batch que te permite:
- Definir y ejecutar cadenas de procesos complejas con dependencias
- Monitorear el estado de ejecución y rendimiento en tiempo real
- Rastrear salidas de actividades y valores de parámetros
- Gestionar configuraciones y parámetros específicos por empresa
- Manejar recuperación de errores y mecanismos de reintento
- Generar reportes completos de ejecución

## 🏗️ Arquitectura del Sistema

### Componentes Principales
- **Cadenas de Procesos**: Flujos de trabajo jerárquicos que organizan procesos relacionados
- **Procesos**: Unidades de procesamiento individuales que realizan tareas específicas
- **Actividades**: Operaciones granulares dentro de los procesos
- **Ejecuciones**: Instancias de tiempo de ejecución con auditoría completa
- **Parámetros**: Valores configurables para procesos y actividades
- **Salidas**: Resultados y datos generados por las actividades

### Tablas Principales
- `BATCH_CHAINS` - Definiciones de cadenas de procesos
- `BATCH_PROCESSES` - Definiciones de procesos dentro de cadenas
- `BATCH_ACTIVITIES` - Definiciones de actividades dentro de procesos
- `BATCH_CHAIN_EXECUTIONS` - Seguimiento de ejecuciones de cadenas
- `BATCH_PROCESS_EXECUTIONS` - Seguimiento de ejecuciones de procesos
- `BATCH_ACTIVITY_EXECUTIONS` - Seguimiento de ejecuciones de actividades
- `BATCH_COMPANIES` - Configuraciones específicas por empresa

## 🚀 Características Principales

- **Gestión Jerárquica de Procesos**: Define cadenas → procesos → actividades
- **Gestión de Parámetros**: Parámetros específicos por empresa y ejecución
- **Monitoreo en Tiempo Real**: Rastrea estado de ejecución y métricas de rendimiento
- **Manejo de Errores**: Mecanismos de reintento y recuperación integrados
- **Auditoría**: Historial completo de ejecución y linaje de datos
- **Configuración Flexible**: Soporte para múltiples empresas y entornos
- **Reportes**: Reportes completos de ejecución y análisis

## 🛠️ Instalación y Configuración

### Prerrequisitos
- Oracle Database 12c o superior
- Entorno de desarrollo PL/SQL
- Privilegios de base de datos apropiados

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone [url-del-repositorio]
   cd batch-man
   ```

2. **Ejecutar el script maestro**
   ```sql
   @00_MASTER_SCRIPT.sql
   ```

3. **Configurar parámetros de empresa**
   ```sql
   -- Agregar configuración de tu empresa
   INSERT INTO BATCH_COMPANIES (COMPANY_ID, COMPANY_NAME, IS_ACTIVE)
   VALUES (1, 'Tu Empresa', 'Y');
   ```

4. **Configurar cadenas y procesos iniciales**
   ```sql
   -- Ejemplo: Crear una cadena de procesamiento de datos
   EXEC PCK_BATCH_MANAGER.CREATE_CHAIN('PROCESAMIENTO_DATOS', 'Flujo principal de procesamiento de datos');
   ```

## 📖 Ejemplos de Uso

### Creando una Cadena de Procesos
```sql
-- Definir una cadena para procesamiento ETL
BEGIN
  PCK_BATCH_MANAGER.CREATE_CHAIN(
    p_chain_name => 'PROCESAMIENTO_ETL',
    p_description => 'Procesamiento Extract, Transform, Load'
  );
  
  -- Agregar procesos a la cadena
  PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN(
    p_chain_name => 'PROCESAMIENTO_ETL',
    p_process_name => 'EXTRAER_DATOS',
    p_description => 'Extraer datos de sistemas fuente'
  );
END;
/
```

### Ejecutando una Cadena
```sql
-- Iniciar una ejecución de cadena
DECLARE
  v_execution_id NUMBER;
BEGIN
  v_execution_id := PCK_BATCH_MANAGER.START_CHAIN_EXECUTION(
    p_chain_name => 'PROCESAMIENTO_ETL',
    p_company_id => 1
  );
  
  DBMS_OUTPUT.PUT_LINE('ID de Ejecución: ' || v_execution_id);
END;
/
```

### Monitoreando Ejecuciones
```sql
-- Verificar cadenas en ejecución
SELECT * FROM V_BATCH_RUNNING_CHAINS;

-- Verificar procesos en ejecución
SELECT * FROM V_BATCH_RUNNING_PROCESSES;

-- Verificar actividades en ejecución
SELECT * FROM V_BATCH_RUNNING_ACTIVITIES;
```

## 📊 Monitoreo y Reportes

### Vistas en Tiempo Real
- `V_BATCH_RUNNING_CHAINS` - Cadenas ejecutándose actualmente
- `V_BATCH_RUNNING_PROCESSES` - Procesos ejecutándose actualmente
- `V_BATCH_RUNNING_ACTIVITIES` - Actividades ejecutándose actualmente
- `V_BATCH_CHAIN_EXECUTIONS` - Historial de ejecuciones de cadenas
- `V_BATCH_PROCESS_EXECUTIONS` - Historial de ejecuciones de procesos

### Funciones de Reportes
```sql
-- Obtener resumen de ejecución
SELECT * FROM TABLE(PCK_BATCH_MGR_REPORT.GET_EXECUTION_SUMMARY(
  p_chain_name => 'PROCESAMIENTO_ETL',
  p_date_from => SYSDATE - 7,
  p_date_to => SYSDATE
));
```

## 🔧 Configuración

### Parámetros de Empresa
```sql
-- Establecer parámetros específicos de empresa
INSERT INTO BATCH_COMPANY_PARAMETERS (
  COMPANY_ID, PARAMETER_NAME, PARAMETER_VALUE, DESCRIPTION
) VALUES (
  1, 'RUTA_DATOS_FUENTE', '/datos/fuentes', 'Ruta a archivos de datos fuente'
);
```

### Parámetros de Actividad
```sql
-- Configurar parámetros específicos de actividad
INSERT INTO BATCH_ACTIVITY_PARAMETERS (
  ACTIVITY_NAME, PARAMETER_NAME, PARAMETER_TYPE, DEFAULT_VALUE
) VALUES (
  'CARGAR_DATOS', 'TAMANO_LOTE', 'NUMBER', '1000'
);
```

## 📁 Estructura del Proyecto

```
├── packages/           # Paquetes PL/SQL principales
│   ├── core/          # Paquetes de gestión principales
│   ├── monitoring/    # Monitoreo y reportes
│   └── utils/         # Funciones de utilidad
├── tables/            # Definiciones de tablas de base de datos
├── types/             # Definiciones de tipos PL/SQL
├── views/             # Vistas de monitoreo y reportes
├── functions/         # Funciones independientes
└── sequences/         # Secuencias de base de datos
```

## 📚 Documentación

- [Arquitectura del Sistema](SYSTEM_ARCHITECTURE.md) - Diseño detallado del sistema
- [Documentación de Paquetes](packages/) - Documentación individual de paquetes
- [Definiciones de Tablas](tables/) - Documentación del esquema de base de datos

## 👤 Autor
- **Nombre:** Eduardo Gutiérrez Tapia
- **Email:** edogt@hotmail.com
- **LinkedIn:** [Eduardo Gutiérrez](https://www.linkedin.com/in/%E2%98%86-eduardo-guti%C3%A9rrez-6706778/)
- **GitHub:** [@edogt](https://github.com/edogt)

## 📝 Licencia
Este proyecto se distribuye bajo licencia MIT, salvo indicación contraria en archivos específicos. 