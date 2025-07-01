# Análisis de la Implementación de HF_OBATCH

## Introducción
**HF_OBATCH** (HoldFast Oracle Batch) es un sistema de automatización de procesos que utiliza el paquete `dbms_scheduler` de Oracle para gestionar la ejecución de cadenas, procesos y actividades en la plataforma. Este análisis detalla la configuración de cadenas-procesos, la gestión de salidas, la distribución de archivos y las pruebas realizadas, basado en los documentos proporcionados y la bitácora de aplicaciones (*Bitácora de aplicaciones cierre mensual.xlsx*).

## Configuración de Cadenas-Procesos

### Descripción
HF_OBATCH organiza los procesos en **cadenas** (estructuras que agrupan procesos para ejecución programada) y **procesos** (actividades específicas dentro de una cadena). La configuración define el orden de ejecución, ya sea mediante predecesores o reglas condicionales.

### Configuración de Cadenas
- **Campos Clave**:
  - **code**: Identificador único (máximo 20 caracteres, normas Oracle).
  - **config**: JSON con:
    - `auto_process_date`: Fecha de procesamiento (e.g., `trunc(sysdate-1)`).
    - `report_fails_to`: Correos para notificar fallos (e.g., `user1@example.com`).
    - `report_success_to`: Correos para notificaciones de éxito (e.g., `user1@example.com, user2@example.com`).
    - `repeat_interval`: Programación de ejecución (e.g., `FREQ=MINUTELY; INTERVAL=5`).
    - `execution_logic`: `"by rules"` para reglas condicionales; de lo contrario, usa `predecessors`.
    - `simulation_mode`: Booleano para modo simulación.
  - **rules_set**: JSON con reglas de ejecución, incluyendo:
    - `name`: Nombre de la regla.
    - `condition`: Condición (e.g., `TRUE`, `CIERROF SUCCEEDED`).
    - `action`: Acción (e.g., `start INTER_01, INTER_02, INTER_03`).
    - `comments`: Comentario opcional.

- **Ejemplo** (*Diagrama cadena de prueba.pptm*):
  ```json
  {
    "auto_process_date": "trunc(sysdate-1)",
    "report_fails_to": "user1@example.com",
    "report_success_to": "user1@example.com, user2@example.com",
    "repeat_interval": "FREQ=MONTHLY; BYMONTHDAY=-1",
    "execution_logic": "by rules",
    "rules_set": [
      {"name": "inicio", "condition": "TRUE", "action": "start CIERROF", "comments": ""},
      {"name": "interfaces", "condition": "CIERROF SUCCEEDED", "action": "start INTER_01, INTER_02, INTER_03", "comments": ""},
      {"name": "centralizacion", "condition": "INTER_01 SUCCEEDED AND INTER_02 SUCCEEDED AND INTER_03 SUCCEEDED", "action": "start CENTRALIZ", "comments": ""},
      {"name": "Contab", "condition": "CENTRALIZ SUCCEEDED", "action": "start CONTAB", "comments": ""},
      {"name": "CobrInformes", "condition": "CONTAB SUCCEEDED", "action": "start COBRAN, GENINFO", "comments": ""},
      {"name": "EnvioCobranza", "condition": "COBRAN SUCCEEDED", "action": "start ENVCOB", "comments": ""},
      {"name": "DistribInformes", "condition": "GENINFO SUCCEEDED", "action": "start DISTNFO", "comments": ""},
      {"name": "Estadisticas", "condition": "ENVCOB SUCCEEDED AND DISTNFO SUCCEEDED", "action": "start SENDSTAT", "comments": ""}
    ]
  }
  ```

### Configuración de Procesos
- **Campos Clave**:
  - **code**: Identificador único (máximo 20 caracteres).
  - **propagate_failed_state**: Booleano para propagar errores a la cadena.
  - **rules_set**: Reglas para ejecución de actividades (similar a cadenas).
- **Ejemplo**: Proceso `CENTRALIZ` con actividades `ACT1`, `ACT2`, `ACT3`:
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

### Configuración de Procesos-Actividades
- **Campos Clave**:
  - **code**: Identificador único de la relación.
  - **predecessors**: Orden de ejecución si no hay reglas.
  - **Parámetros**: Valores específicos para la actividad (e.g., `P_USERCODE => 3100`).
- **Ejemplo**: Proceso `COBRAN`, actividades `ACT_COB1`, `ACT_COB2`:
  - `predecessors`: `ACT_COB1 -> ACT_COB2`.
  - Parámetros: `P_DATE => last_day(add_months(sysdate,-1))`.

### Configuración de Actividades
- **Campos Clave**:
  - **code**: Identificador único (máximo 20 caracteres).
  - **propagate_failed_state**: Booleano para propagar errores al proceso.
  - **action**: Procedimiento almacenado (e.g., `PCK_HF_OBATCH_FCAL096.MAIN`).
- **Ejemplo** (*Evidencia_Pruebas_MH-2652.pptx*):
  ```sql
  begin
    dbms_lock.sleep(trunc(dbms_random.value(1,5)));
    PCK_HF_OBATCH_FCAL096.MAIN(
      P_USERCODE => 3001,
      P_COMPANY => 10,
      P_MONTH => to_number(to_char(add_months(sysdate,-1),'MM')),
      P_YEAR => to_number(to_char(add_months(sysdate,-1),'YYYY'))
    );
  end;
  ```

## Gestión de Salidas

### Descripción
HF_OBATCH gestiona las salidas de las actividades (archivos o correos) mediante la tabla `ACTIVITY_OUTPUTS`, utilizando paquetes como `PCK_HF_OBATCH_MANAGER`, `PCK_HF_OBATCH_MGR_ACTIVITIES` y `PCK_HF_OBATCH_FTP` (*batchman_gestion de salidas.pptx*).

### Configuración
- **Campos Clave**:
  - **name**: Nombre lógico (e.g., `Archivo de cobranza DIN`).
  - **type**: `file` o `email`.
  - **file_name_format**: Formato del nombre del archivo (e.g., `[:sysdate|yyyyddmm]_Cobranza_Din.TXT`).
  - **config**: JSON con:
    - `code`: Identificador único.
    - `move_to`: Ruta de destino (e.g., `\\server\Generales\[:sysdate|YYYY]\[:sysdate|month]\Cobranzas`).
    - `send_to`: Correos para envío (e.g., `external_user@mail.com`).
- **Ejemplo**:
  ```json
  {
    "name": "Archivo de cobranza DIN",
    "type": "file",
    "file_name_format": "[:sysdate|yyyyddmm]_Cobranza_Din.TXT",
    "config": {
      "code": "COB-DIN",
      "move_to": "\\server\Generales\[:sysdate|YYYY]\[:sysdate|month]\Cobranzas",
      "send_to": "external_user@mail.com"
    }
  }
  ```
  - Resultado (01-11-2018): Archivo `20181101_Cobranza_Din.TXT` en `\\server\Generales\2018\Noviembre\Cobranzas`, enviado a `external_user@mail.com`.

## Distribución de Archivos

### Descripción
Los archivos generados se distribuyen automáticamente vía FTP usando `PCK_HF_OBATCH_FTP` (*POC - PLSQL ftp.pptx*).

### Implementación
- **Servidor FTP**: Configurado en `192.168.66.155`, puerto 21, usuario `ftp_user`, contraseña `ftp_password`.
- **Ejemplo PL/SQL**:
  ```sql
  DECLARE
    l_conn UTL_TCP.connection;
  BEGIN
    l_conn := PCK_HF_OBATCH_FTP.login('192.168.66.155', '21', 'ftp_user', 'ftp_password');
    PCK_HF_OBATCH_FTP.ascii(p_conn => l_conn);
    PCK_HF_OBATCH_FTP.put(
      p_conn => l_conn,
      p_from_dir => 'OUTPUT_FCOL031',
      p_from_file => 'SdoAcreed_Gen_201802_20181212_042156.TXT',
      p_to_file => 'test_ftp/SdoAcreed_Gen_201802_20181212_042156.TXT'
    );
    PCK_HF_OBATCH_FTP.logout(l_conn);
  END;
  ```
- **Resultados de la POC**:
  - Transferencia exitosa de archivos desde PL/SQL.
  - Soporta múltiples destinos y envíos por correo.
  - Requiere permisos en `output_directory` y directorios de destino.

## Pruebas Realizadas

### Simulaciones (*Evidencia_Pruebas_MH-2652.pptx*)
- **Procesos Probados**: Cierres mensuales (IFRS, Producción, Siniestros, Recuperos, Primas) con actividades como `FCAL096`, `FCPT023`, `FCPL033`.
- **Metodología**: Uso de `dbms_lock.sleep` para simular retrasos y procedimientos con parámetros dinámicos (e.g., `P_MONTH`, `P_YEAR`).
- **Ejemplo**:
  ```sql
  begin
    dbms_lock.sleep(trunc(dbms_random.value(1,5)));
    PCK_HF_OBATCH_FCAL096.MAIN(
      P_USERCODE => 3001,
      P_COMPANY => 10,
      P_MONTH => to_number(to_char(add_months(sysdate,-1),'MM')),
      P_YEAR => to_number(to_char(add_months(sysdate,-1),'YYYY'))
    );
  end;
  ```

### Modificaciones (*Evidencia_Pruebas_MH-2708.pptx*)
- Alteración del tipo de dato de `predecessors` en `PROCESS_ACTIVITIES` para soportar dependencias complejas.
- Compilación de `PCK_HF_OBATCH_MANAGER` en ambiente de certificación.

## Conclusión
HF_OBATCH automatiza la ejecución de procesos mediante `dbms_scheduler`, gestionando cadenas, procesos y actividades con reglas condicionales y predecesores. La gestión de salidas permite la distribución automática de archivos vía FTP y correo, con configuraciones flexibles. Las pruebas realizadas (*MH-2652*, *MH-2708*) confirman la funcionalidad para cierres mensuales, aunque algunos procesos requieren ajustes (*sheet_id: 39-179*). La implementación mejora la eficiencia operativa al eliminar tareas manuales y garantizar ejecuciones consistentes.