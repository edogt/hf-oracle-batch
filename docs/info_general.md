A continuación, se documenta la configuración de **cadenas-procesos** en la plataforma **BATCH_MAN**, integrando la información de los documentos proporcionados, con un enfoque en la eliminación del servicio externo "la oreja" y la adopción de `dbms_scheduler` de Oracle. La documentación se presenta de manera abstracta, sin hacer referencia a la aplicación web, y se complementa con detalles relevantes de los nuevos documentos, incluyendo la gestión de salidas, pruebas de concepto (POC) de FTP, y ejemplos de configuraciones de cadenas. Se mantiene la estructura jerárquica y se incorporan los conceptos de ejecución, distribución de archivos y pruebas.

---

### **Configuración de Cadenas-Procesos**

**Descripción**:  
La configuración de cadenas-procesos define las asociaciones entre **cadenas** (estructuras que agrupan procesos para su ejecución programada) y **procesos** (conjuntos de actividades que implementan tareas específicas). Esta configuración establece qué procesos forman parte de una cadena y, en ausencia de reglas, el orden de ejecución mediante el campo `predecessors`.

**Campos clave**:
- **predecessors**: 
  - Define el orden secuencial de ejecución de los procesos dentro de una cadena si no se utiliza la lógica de ejecución basada en reglas (`execution_logic: "by rules"`).
  - Ejemplo: Si `PROC1` es predecesor de `PROC2`, `PROC2` no se ejecutará hasta que `PROC1` finalice con éxito.
- **Código de la cadena y proceso**: 
  - Cada cadena y proceso debe tener un código único (máximo 20 caracteres, siguiendo las normas de nomenclatura de Oracle para `dbms_scheduler`).
  - Estos códigos identifican los objetos en la base de datos y se utilizan en las reglas de ejecución.

**Consideraciones**:
- Si la cadena utiliza `execution_logic: "by rules"`, el orden de ejecución se define en el `rules_set` de la cadena (ver Configuración de Cadenas), y el campo `predecessors` se ignora.
- La configuración se almacena en la tabla `BATCH_CHAINS` y sus tablas relacionadas, como `BATCH_CHAIN_PROCESSES` (no mencionada explícitamente en los documentos, pero implícita en la estructura jerárquica).

**Ejemplo conceptual**:
- Cadena `CADENA_1` incluye los procesos `CIERROF`, `INTER_01`, `INTER_02`, `INTER_03`, `CENTRALIZ`, `CONTAB`, `COBRAN`, `GENINFO`, `ENVCOB`, `DISTNFO`, `SENDSTAT` (según el documento *Diagrama cadena de prueba.pptm*).
- Sin reglas:
  - `predecessors`: `CIERROF -> INTER_01 -> INTER_02 -> INTER_03 -> CENTRALIZ -> CONTAB -> COBRAN, GENINFO -> ENVCOB, DISTNFO -> SENDSTAT`.
- Con reglas:
  - Se define en el `rules_set` de la cadena (ver ejemplo en Configuración de Cadenas).

---

### **Configuración de Cadenas**

**Descripción**:  
Las cadenas son estructuras que agrupan procesos y definen su ejecución programada o condicional. Con la eliminación del servicio externo "la oreja" (un programa .NET que gestionaba la programación de cadenas), las cadenas ahora se configuran utilizando el paquete `dbms_scheduler` de Oracle, lo que elimina la necesidad de reiniciar un servicio externo ante cambios en la programación.

**Campos clave**:
- **code**: 
  - Código único de la cadena (máximo 20 caracteres, normas Oracle).
  - Usado para identificar la cadena en `dbms_scheduler`.
- **config**: 
  - JSON que contiene la configuración básica de la cadena. Incluye:
    - **auto_process_date**: Fecha de procesamiento (e.g., `"trunc(sysdate-1)"` para el día anterior).
    - **report_fails_to**: Lista de correos electrónicos para notificar fallos (e.g., `"edogt@hotmail.com"`).
    - **report_success_to**: Lista de correos para notificar ejecuciones exitosas (e.g., `"edogt@hotmail.com, Jose.Villalaz@hdi.cl"`).
    - **repeat_interval**: Define la frecuencia y horario de ejecución, siguiendo la sintaxis de `dbms_scheduler` (reemplaza la entrada obsoleta `cron`).
    - **execution_logic**: `"by rules"` para ejecución basada en reglas definidas en `rules_set`; cualquier otro valor o ausencia implica ejecución según `predecessors`.
    - **simulation_mode**: Booleano que indica si la cadena se ejecuta en modo simulación (sin efectos reales).
- **rules_set**: 
  - Lista de reglas en formato JSON que determinan el orden de ejecución de los procesos. Cada regla incluye:
    - `name`: Nombre de la regla.
    - `condition`: Condición para ejecutar la regla (e.g., `"TRUE"`, `"CIERROF SUCCEEDED"`).
    - `action`: Acción a ejecutar (e.g., `"start INTER_01, INTER_02, INTER_03"`).
    - `comments`: Comentario opcional.

**Eliminación de "la oreja"**:
- **Problema anterior**: 
  - "La oreja" era un programa .NET que buscaba la próxima cadena a ejecutar, dormía hasta el momento programado, la ejecutaba y repetía el ciclo. Cualquier cambio en la programación (e.g., modificar o agregar una cadena) requería reiniciar el programa, lo que generaba problemas operativos (*Eliminación de la oreja.pptx*).
- **Solución**: 
  - Se eliminó "la oreja" y se implementaron jobs de `dbms_scheduler` que se generan automáticamente al actualizar la tabla `BATCH_CHAINS`.
  - Cambio en la configuración: Se reemplazó la entrada `cron` (e.g., `"40 16 * * *"`) por `repeat_interval` (e.g., `"FREQ=MINUTELY; INTERVAL=5;"`).
- **Ventaja**: 
  - Mayor flexibilidad, ya que los cambios en la programación se reflejan automáticamente sin intervención manual.

**Ejemplo de configuración** (*Eliminación de la oreja.pptx*):
```json
{
  "auto_process_date": "trunc(sysdate-1)",
  "report_fails_to": "edogt@hotmail.com",
  "report_success_to": "edogt@hotmail.com",
  "repeat_interval": "FREQ=MINUTELY; INTERVAL=5;",
  "execution_logic": "by rules"
}
```

**Ejemplo de rules_set** (*Diagrama cadena de prueba.pptm*):
```json
[
  {"name": "inicio", "condition": "TRUE", "action": "start CIERROF", "comments": ""},
  {"name": "interfaces", "condition": "CIERROF SUCCEEDED", "action": "start INTER_01, INTER_02, INTER_03", "comments": ""},
  {"name": "centralizacion", "condition": "INTER_01 SUCCEEDED AND INTER_02 SUCCEEDED AND INTER_03 SUCCEEDED", "action": "start CENTRALIZ", "comments": ""},
  {"name": "Contab", "condition": "CENTRALIZ SUCCEEDED", "action": "start CONTAB", "comments": ""},
  {"name": "CobrInformes", "condition": "CONTAB SUCCEEDED", "action": "start COBRAN, GENINFO", "comments": ""},
  {"name": "EnvioCobranza", "condition": "COBRAN SUCCEEDED", "action": "start ENVCOB", "comments": ""},
  {"name": "DistribInformes", "condition": "GENINFO SUCCEEDED", "action": "start DISTNFO", "comments": ""},
  {"name": "Estadisticas", "condition": "ENVCOB SUCCEEDED AND DISTNFO SUCCEEDED", "action": "start SENDSTAT", "comments": ""}
]
```

**Consideraciones**:
- El `repeat_interval` utiliza la sintaxis de `dbms_scheduler` (detallada en el Anexo).
- Las reglas en `rules_set` permiten dependencias condicionales (e.g., ejecutar procesos solo si otros han tenido éxito).
- La tabla `BATCH_CHAINS` es clave para la generación automática de jobs en `dbms_scheduler`.

---

### **Configuración de Procesos**

**Descripción**:  
Los procesos son conjuntos de actividades que se ejecutan dentro de una cadena. La configuración define su comportamiento y el orden de ejecución de las actividades asociadas, ya sea mediante reglas o predecesores.

**Campos clave**:
- **code**: 
  - Código único del proceso (máximo 20 caracteres, normas Oracle).
  - Identifica la subcadena en `dbms_scheduler`.
- **propagate_failed_state**: 
  - Booleano que indica si un estado de error (FAILED) se propaga a la cadena que instanció el proceso.
- **config**: 
  - JSON para configuración básica (no implementado según los documentos).
- **rules_set**: 
  - Lista de reglas en formato JSON para definir el orden de ejecución de las actividades. Cada regla incluye:
    - `name`: Nombre de la regla.
    - `condition`: Condición (e.g., `"TRUE"`, `"ACT1 SUCCEEDED"`).
    - `action`: Acción (e.g., `"start ACT2"`).
    - `comments`: Comentario opcional.

**Ejemplo conceptual**:
- Proceso `CENTRALIZ` con actividades `ACT1`, `ACT2`, `ACT3`.
- Configuración:
  ```json
  {
    "code": "CENTRALIZ",
    "propagate_failed_state": true,
    "rules_set": [
      {"name": "inicio_act1", "condition": "TRUE", "action": "start ACT1", "comments": ""},
      {"name": "inicio_act2", "condition": "ACT1 SUCCEEDED", "action": "start ACT2", "comments": ""},
      {"name": "inicio_act3", "condition": "ACT2 SUCCEEDED", "action": "start ACT3", "comments": ""}
    ]
  }
  ```

**Consideraciones**:
- Si no se usa `rules_set`, el orden de ejecución se basa en el campo `predecessors` de la configuración de procesos-actividades.
- Los procesos se asocian a cadenas mediante la configuración de cadenas-procesos.

---

### **Configuración de Procesos-Actividades**

**Descripción**:  
Esta configuración define las asociaciones entre procesos y sus actividades, especificando el orden de ejecución (si no se usan reglas) y los parámetros de las actividades.

**Campos clave**:
- **code**: 
  - Código único que identifica la relación proceso-actividad (máximo 20 caracteres, normas Oracle).
  - Usado en las reglas de ejecución del proceso.
- **predecessors**: 
  - Define el orden de ejecución de las actividades dentro del proceso si no se usa `rules_set`.
  - Ejemplo: `ACT1 -> ACT2` indica que `ACT2` se ejecuta tras `ACT1`.
- **Parámetros de la actividad**: 
  - Valores específicos para los parámetros del procedimiento asociado a la actividad, definidos en la configuración de la actividad.

**Ejemplo conceptual**:
- Proceso `COBRAN` con actividades `ACT_COB1`, `ACT_COB2`.
- Configuración:
  - `code`: `COBRAN_ACT_COB1`.
  - `predecessors`: `ACT_COB1 -> ACT_COB2`.
  - Parámetros: Si `ACT_COB1` ejecuta `PCK_BATCH_COB.MAIN(P_USERCODE, P_DATE)`, se especifican `P_USERCODE => 3100`, `P_DATE => last_day(add_months(sysdate,-1))`.

**Consideraciones**:
- Los parámetros deben coincidir con la firma del procedimiento de la actividad.
- La tabla `BATCH_PROCESS_ACTIVITIES` almacena estas asociaciones (*Evidencia_Pruebas_MH-2708.pptx* indica una modificación en el tipo de dato de `predecessors` en esta tabla).

---

### **Configuración de Actividades**

**Descripción**:  
Las actividades son las tareas específicas dentro de un proceso, implementadas mediante procedimientos almacenados en Oracle. La configuración define el procedimiento a ejecutar y sus parámetros.

**Campos clave**:
- **code**: 
  - Código único de la actividad (máximo 20 caracteres, normas Oracle).
  - Identifica el job en `dbms_scheduler`.
- **propagate_failed_state**: 
  - Booleano que indica si un estado de error (FAILED) se propaga al proceso que instanció la actividad.
- **config**: 
  - JSON para configuración básica (no implementado).
- **action**: 
  - Procedimiento almacenado que implementa la actividad (e.g., `PCK_BATCH_FCAL096.MAIN`).
- **Parámetros**: 
  - Definidos en la asociación proceso-actividad, especifican los valores para el procedimiento.

**Ejemplo** (*Evidencia_Pruebas_MH-2652.pptx*):
- Actividad `FCAL096`:
  ```sql
  begin
    dbms_lock.sleep(trunc(dbms_random.value(1,5)));
    PCK_BATCH_FCAL096.MAIN(
      P_USERCODE => 3001,
      P_COMPANY => 10,
      P_MONTH => to_number(to_char(add_months(sysdate,-1),'MM')),
      P_YEAR => to_number(to_char(add_months(sysdate,-1),'YYYY'))
    );
  end;
  ```

**Consideraciones**:
- Los procedimientos deben estar definidos en la base de datos Oracle.
- Los parámetros son específicos del procedimiento y se configuran en la asociación proceso-actividad.
- La inclusión de `dbms_lock.sleep` en los ejemplos sugiere simulaciones con retrasos aleatorios para pruebas (*Evidencia_Pruebas_MH-2652.pptx*).

---

### **Gestión de Salidas (Outputs)**

**Descripción**:  
La plataforma **BATCH_MAN** incluye un módulo para gestionar las salidas de las actividades, definiendo cómo se generan, nombran, mueven y distribuyen los archivos resultantes. Esta funcionalidad se configura en la tabla `BATCH_ACTIVITY_OUTPUTS` y se implementa mediante paquetes como `PCK_BATCH_MANAGER`, `PCK_BATCH_MGR_ACTIVITIES` y `PCK_BATCH_FTP` (*Distribución de archivos.pptx*, *batchman_gestion de salidas.pptx*).

**Configuración de salidas**:
- **Tabla**: `BATCH_ACTIVITY_OUTPUTS`.
- **Campos clave**:
  - **name**: Nombre lógico de la salida (e.g., `Archivo de cobranza DIN`).
  - **type**: Tipo de salida (`file` o `email`).
  - **file_name_format**: Define la estructura del nombre del archivo usando literales y parámetros (e.g., `[:sysdate|yyyyddmm]_Cobranza_Din.TXT`).
    - Parámetros soportados: Los definidos en la actividad más `sysdate`.
    - Ejemplo: `[:sysdate|yyyyddmm]_HDI_CONTENT_NULOS.TXT` genera `20181112_HDI_CONTENT_NULOS.TXT`.
  - **config**: JSON con:
    - `code`: Identificador único de la salida.
    - `move_to`: Ruta de destino del archivo, usando la misma lógica de `file_name_format` (e.g., `"\\tineo\Generales\[:sysdate|YYYY]\[:sysdate|month]\Cobranzas"`).
    - `send_to`: Lista de correos electrónicos para enviar el archivo (separados por comas, opcional).
- **Ejemplo** (*batchman_gestion de salidas.pptx*):
  ```json
  {
    "name": "Archivo de cobranza DIN",
    "type": "file",
    "file_name_format": "[:sysdate|yyyyddmm]_Cobranza_Din.TXT",
    "config": {
      "code": "COB-DIN",
      "move_to": "\\tineo\Generales\[:sysdate|YYYY]\[:sysdate|month]\Cobranzas",
      "send_to": "external_user@mail.com"
    }
  }
  ```
  - Resultado para el 01-11-2018: Genera `20181101_Cobranza_Din.TXT`, lo mueve a `\\tineo\Generales\2018\Noviembre\Cobranzas` y lo envía a `external_user@mail.com`.

**Distribución de archivos**:
- **Método**: Los archivos se distribuyen mediante FTP utilizando el paquete `PCK_BATCH_FTP` (*POC - PLSQL ftp.pptx*).
- **Requisitos**:
  - Servidor FTP accesible desde la base de datos (e.g., FileZilla en `192.168.66.155`, puerto 21, usuario `batchman_ftp`, contraseña `ftp1`).
  - Permisos de lectura en el directorio `batch_output_directory` y lectura/escritura en los directorios de destino (e.g., `\\tineo\Generales\2018\Noviembre\Cobranzas`).
- **Ejemplo de código PL/SQL** (*POC - PLSQL ftp.pptx*):
  ```sql
  DECLARE
    l_conn UTL_TCP.connection;
  BEGIN
    l_conn := pck_batch_ftp.login('192.168.66.155', '21', 'batchman_ftp', 'ftp1');
    pck_batch_ftp.ascii(p_conn => l_conn);
    pck_batch_ftp.put(
      p_conn => l_conn,
      p_from_dir => 'BATCH_OUTPUT_FCOL031',
      p_from_file => 'SdoAcreed_Gen_201802_20181212_042156.TXT',
      p_to_file => 'test_ftp/SdoAcreed_Gen_201802_20181212_042156.TXT'
    );
    pck_batch_ftp.logout(l_conn);
  END;
  ```
- **Resultado de la POC**: La transferencia de archivos desde PL/SQL a un servidor FTP es viable y sencilla, permitiendo:
  - Enviar un archivo a múltiples directorios.
  - Enviar diferentes archivos a distintos directorios.
  - Combinar distribución por FTP y correo electrónico.

**Consideraciones**:
- Los nombres de archivo y rutas pueden incluir parámetros dinámicos como `[:sysdate|yyyyddmm]` o `[:empresa]`.
- El paquete `PCK_BATCH_FTP` está basado en un desarrollo de Tim Hall (oracle-base.com).
- La validación de parámetros de tipo fecha en `file_name_format` y `move_to` incluye conversiones automáticas a `to_date` si no se usan funciones específicas como `sysdate`, `last_day`, o `add_months` (*batchman_gestion de salidas.pptx*).

---

### **Anexo: Sintaxis de `repeat_interval`**

**Descripción**:  
El campo `repeat_interval` define la programación de ejecución de las cadenas en `dbms_scheduler`. Se utiliza en el JSON `config` de las cadenas (*Eliminación de la oreja.pptx*).

**Parámetros principales**:
- **FREQ**: Tipo de recurrencia (`YEARLY`, `MONTHLY`, `WEEKLY`, `DAILY`, `HOURLY`, `MINUTELY`, `SECONDLY`).
- **INTERVAL**: Intervalo de repetición (entero positivo, predeterminado: 1, máximo: 999).
- **BYMONTH**: Meses de ejecución (e.g., `1` para enero, `FEB` para febrero).
- **BYWEEKNO**: Semana del año (1 a 53, ISO-8601, solo para `YEARLY`).
- **BYYEARDAY**: Día del año (1 a 366, e.g., `69` para 10 de marzo en años no bisiestos).
- **BYDATE**: Lista de fechas en formato `[YYYY]MMDD` o rangos con `SPAN`/`OFFSET` (e.g., `BYDATE=0110+SPAN:5D`).
- **BYMONTHDAY**: Día del mes (1 a 31, o `-1` para el último día).
- **BYDAY**: Día de la semana (e.g., `MON`, `-1 FRI` para el último viernes).
- **BYHOUR**: Hora (0 a 23).
- **BYMINUTE**: Minuto (0 a 59).

**Ejemplos**:
- `FREQ=MINUTELY; INTERVAL=5`: Ejecuta cada 5 minutos.
- `BYDATE=0110+SPAN:5D`: Ejecuta durante 5 días desde el 10 de enero.
- `BYMONTHDAY=-1`: Ejecuta el último día del mes.

**Consideraciones**:
- Combinaciones inválidas (e.g., `FREQ=YEARLY; BYWEEKNO=1; BYMONTH=12`) generan errores.
- La sintaxis es idéntica a la de `dbms_scheduler` de Oracle.

---

### **Ejemplo Práctico: Cadena de Prueba**

El documento *Diagrama cadena de prueba.pptm* proporciona un ejemplo detallado de una cadena con múltiples procesos y reglas condicionales:
- **Cadena**: Incluye procesos como `CIERROF`, `INTER_01`, `INTER_02`, `INTER_03`, `CENTRALIZ`, `CONTAB`, `COBRAN`, `GENINFO`, `ENVCOB`, `DISTNFO`, `SENDSTAT`.
- **rules_set**:
  - Inicia con `CIERROF`.
  - Ejecuta `INTER_01`, `INTER_02`, `INTER_03` en paralelo tras el éxito de `CIERROF`.
  - Ejecuta `CENTRALIZ` cuando todas las interfaces han tenido éxito.
  - Continúa con `CONTAB`, luego `COBRAN` y `GENINFO` en paralelo, y finalmente `ENVCOB`, `DISTNFO`, y `SENDSTAT` con dependencias condicionales.
- **Configuración implícita**:
  - `execution_logic`: `"by rules"`.
  - `repeat_interval`: Podría ser, por ejemplo, `FREQ=MONTHLY; BYMONTHDAY=-1` para un cierre mensual.
- **Salidas**:
  - Actividades como `COBRAN` o `GENINFO` pueden generar archivos (e.g., `20181101_Cobranza_Din.TXT`) que se mueven a directorios específicos (e.g., `\\tineo\Generales\2018\Noviembre\Cobranzas`) y se envían por correo (*batchman_gestion de salidas.pptx*).

---

### **Pruebas y Evidencias**

**Pruebas de simulación** (*Evidencia_Pruebas_MH-2652.pptx*):
- Se simularon cierres mensuales (e.g., IFRS, Producción, Siniestros, Recuperos, Primas) con actividades como `FCAL096`, `FCPT023`, `FCPL033`.
- Cada actividad incluye un retraso aleatorio (`dbms_lock.sleep`) para simular ejecución y procedimientos con parámetros específicos (e.g., `P_USERCODE`, `P_MONTH`, `P_YEAR`).
- Ejemplo:
  ```sql
  begin
    dbms_lock.sleep(trunc(dbms_random.value(1,5)));
    PCK_BATCH_FCAL096.MAIN(
      P_USERCODE => 3001,
      P_COMPANY => 10,
      P_MONTH => to_number(to_char(add_months(sysdate,-1),'MM')),
      P_YEAR => to_number(to_char(add_months(sysdate,-1),'YYYY'))
    );
  end;
  ```

**Modificación de tipo de dato** (*Evidencia_Pruebas_MH-2708.pptx*):
- Se alteró la tabla `BATCH_PROCESS_ACTIVITIES` para cambiar el tipo de dato del campo `predecessors`, probablemente para soportar formatos más complejos o mejorar la gestión de dependencias.
- Se compiló el paquete `PCK_BATCH_MANAGER` en un ambiente de certificación para soportar estas modificaciones.

**Prueba de concepto de FTP** (*POC - PLSQL ftp.pptx*):
- Se demostró la viabilidad de distribuir archivos automáticamente desde PL/SQL usando `PCK_BATCH_FTP`.
- Configuración del servidor FTP (FileZilla) en `192.168.66.155` con acceso a `batch_output_directory` y directorios de destino.
- La POC transfirió un archivo de `BATCH_OUTPUT_FCOL031` a `/test_ftp`, confirmando la funcionalidad.

---

### **Resumen General**

La configuración de **cadenas-procesos** en **BATCH_MAN** permite asociar procesos a cadenas, definiendo su orden de ejecución mediante `predecessors` o reglas condicionales (`rules_set`). La eliminación de "la oreja" y la adopción de `dbms_scheduler` mejoraron la flexibilidad, permitiendo cambios en la programación sin reinicios. Las actividades generan salidas configuradas en `BATCH_ACTIVITY_OUTPUTS`, con nombres y rutas dinámicas, y se distribuyen vía FTP (`PCK_BATCH_FTP`) o correo electrónico. Las pruebas de simulación y la POC de FTP validan la robustez del sistema, soportando cierres mensuales y distribución automática de archivos. La integración con Oracle asegura compatibilidad y escalabilidad.