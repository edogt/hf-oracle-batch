# Aspectos a Revisar en Ejemplos y Documentación de HF_OBATCH

1. **Correspondencia de Parámetros y Configuración**
   - ✅ repeat_interval: Verificar correspondencia con dbms_scheduler.
     > **Documentación creada:** REPEAT_INTERVAL_EXAMPLES_HF_OBATCH.md con batería completa de ejemplos y enlaces a documentación oficial de Oracle.
   - execution_logic/by rules: Documentar y ejemplificar la lógica de reglas.
   - rules_set: Sintaxis y compatibilidad con Oracle Scheduler.
   - predecessors: Uso y correspondencia con dependencias nativas.

2. **Ejemplos de Configuración**
   - Ejemplos JSON completos y válidos.
   - Parámetros dinámicos y su resolución.
   - Propagación de errores (propagate_failed_state).

3. **Lógica de Reglas y Dependencias**
   - Condiciones y acciones bien explicadas.
   - Ejemplos de reglas complejas (AND, OR, múltiples acciones).
   - Compatibilidad semántica con dbms_scheduler.

4. **Gestión de Salidas y Distribución**
   - Configuración de archivos y correos en ACTIVITY_OUTPUTS.
   - Formato de nombres de archivo y variables dinámicas.
   - Ejemplos de distribución automática (FTP, correo).  
     > **Nota:** Actualmente, los ejemplos de distribución automática (FTP, correo) no están implementados. Este aspecto podría incluirse en el roadmap de desarrollo.

5. **Ejecución y Simulación**
   - Ejemplos de uso de simulation_mode.
   - Scripts de prueba y documentación de resultados.

6. **Modificaciones y Extensibilidad**
   - Documentar cambios estructurales relevantes.
   - Ejemplos de extensión de reglas, parámetros o actividades.

7. **Gestión de Errores y Auditoría**
   - Ejemplos de propagación y documentación de errores.
   - Ejemplos de consulta de logs y auditoría.

8. **Correspondencia con Oracle Scheduler**
   - Mapeo directo de campos y lógica.
   - Documentar limitaciones o diferencias con la funcionalidad nativa.

9. **Manejo de Parámetros (Análisis Profundo)** ✅ **COMPLETADO**
   - ✅ Describir cómo se gestionan los parámetros a nivel de compañía, proceso y actividad.
   - ✅ Explicar la jerarquía de resolución de parámetros: valores por defecto, sobrescritura por compañía, sobrescritura por ejecución.
   - ✅ Ejemplificar cómo se definen y documentan los parámetros en cada nivel (tablas de parámetros, JSON de configuración, etc.).
   - ✅ Incluir ejemplos de cómo se pasan y resuelven los parámetros dinámicamente en la ejecución de actividades.
   - ✅ Documentar cómo se gestionan los parámetros obligatorios y opcionales, y cómo se validan antes de la ejecución.
   - ✅ Recomendar la inclusión de ejemplos claros de sobreescritura de parámetros y su efecto en la ejecución real.
   
   **Documentación creada:**
   - PARAMETER_MANAGEMENT_HF_OBATCH.md (versión en inglés)
   - PARAMETER_MANAGEMENT_HF_OBATCH.es.md (versión en español) 