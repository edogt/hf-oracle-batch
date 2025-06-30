# Gestión de Parámetros en HF_OBATCH

> **Para la versión en inglés, ver [PARAMETER_MANAGEMENT_HF_OBATCH.md](PARAMETER_MANAGEMENT_HF_OBATCH.md)**

## 1. Introducción
Este documento describe en profundidad cómo se gestionan, resuelven y sobrescriben los parámetros en el sistema HF_OBATCH, abarcando los niveles de compañía, proceso, actividad y ejecución.

## 2. Jerarquía y Resolución de Parámetros
- **Nivel Compañía**: Parámetros globales para cada empresa.
- **Nivel Proceso/Actividad**: Parámetros definidos en la configuración de cada proceso o actividad.
- **Nivel Ejecución**: Parámetros pasados explícitamente al lanzar una ejecución.
- **Prioridad de Resolución**: Ejecución > Compañía > Proceso/Actividad > Valor por defecto.

## 3. Definición de Parámetros
- Tablas de parámetros (por compañía, proceso, actividad).
- Parámetros en JSON de configuración.
- Ejemplo de definición y estructura.

## 4. Ejemplos de Resolución y Sobrescritura

### Ejemplo 1: Proceso de Cierre Mensual Multiempresa

#### a) Proceso: MONTHLY_CLOSING
```json
{
  "P_COMPANY": "[:company_id]",
  "P_CUTOFF_DATE": "last_day(add_months(sysdate, -1))",
  "P_USER": "[:execution_user]",
  "P_CLOSING_TYPE": "MONTHLY",
  "P_AUTO_SEND": true,
  "P_RETRIES": 3
}
```

#### b) Actividad: GENERATE_BALANCE
```json
{
  "P_COMPANY": null,
  "P_CUTOFF_DATE": null,
  "P_REPORT_TYPE": "BALANCE",
  "P_FORMAT": "PDF"
}
```

#### c) Actividad: SEND_REPORT
```json
{
  "P_COMPANY": null,
  "P_CUTOFF_DATE": null,
  "P_RECIPIENT": "accounting@company.com, audit@company.com",
  "P_SUBJECT": "Monthly balance [:company_id] [:sysdate|YYYY-MM]",
  "P_ATTACH_LOG": true
}
```

#### d) Ejecución
- El usuario lanza la cadena para la compañía 1001, usuario "jlopez".
- El sistema resuelve:
  - `P_COMPANY`: 1001 (por contexto de ejecución)
  - `P_CUTOFF_DATE`: último día del mes anterior (dinámico)
  - `P_USER`: "jlopez"
  - `P_CLOSING_TYPE`: "MONTHLY"
  - `P_AUTO_SEND`: true
  - `P_RETRIES`: 3
- Las actividades heredan estos parámetros, salvo que se sobrescriban en la ejecución o en la configuración de la actividad.

---

### Ejemplo 2: Proceso de Carga de Datos con Parámetros de Validación

#### a) Proceso: DATA_LOAD
```json
{
  "P_COMPANY": "[:company_id]",
  "P_START_DATE": "trunc(sysdate, 'MM')",
  "P_END_DATE": "last_day(sysdate)",
  "P_VALIDATE_DUPLICATES": true,
  "P_LOAD_TYPE": "INCREMENTAL"
}
```

#### b) Actividad: VALIDATE_DATA
```json
{
  "P_COMPANY": null,
  "P_START_DATE": null,
  "P_END_DATE": null,
  "P_VALIDATE_DUPLICATES": null,
  "P_ERROR_THRESHOLD": 0.01
}
```

#### c) Actividad: LOAD_TABLE
```json
{
  "P_COMPANY": null,
  "P_START_DATE": null,
  "P_END_DATE": null,
  "P_LOAD_TYPE": null,
  "P_TARGET_TABLE": "TRANSACTIONS"
}
```

#### d) Ejecución especial
- El usuario lanza la cadena para la compañía 2047, pero pasa en la ejecución:
  ```json
  {
    "P_LOAD_TYPE": "TOTAL",
    "P_VALIDATE_DUPLICATES": false
  }
  ```
- El sistema resuelve:
  - `P_LOAD_TYPE`: "TOTAL" (por ejecución)
  - `P_VALIDATE_DUPLICATES`: false (por ejecución)
  - `P_COMPANY`: 2047 (por contexto)
  - `P_START_DATE` y `P_END_DATE`: según el proceso
  - `P_ERROR_THRESHOLD`: 0.01 (por actividad)
  - `P_TARGET_TABLE`: "TRANSACTIONS" (por actividad)

---

### Ejemplo 3: Proceso con Parámetros de Control y Notificación

#### a) Proceso: EXPORT_REPORTS
```json
{
  "P_COMPANY": "[:company_id]",
  "P_EXPORT_DATE": "sysdate",
  "P_FILE_FORMAT": "XLSX",
  "P_SEND_NOTIFICATION": true,
  "P_NOTIFICATION_EMAILS": "support@company.com, manager@company.com"
}
```

#### b) Actividad: GENERATE_REPORT
```json
{
  "P_COMPANY": null,
  "P_EXPORT_DATE": null,
  "P_FILE_FORMAT": null,
  "P_REPORT_NAME": "Report_[:company_id]_[::sysdate|YYYYMMDD].xlsx"
}
```

#### c) Actividad: SEND_NOTIFICATION
```json
{
  "P_COMPANY": null,
  "P_NOTIFICATION_EMAILS": null,
  "P_MESSAGE": "The report was successfully exported on [:sysdate|YYYY-MM-DD]."
}
```

---

## Situaciones Reales Cubiertas

- **Herencia y sobrescritura de parámetros**: Un parámetro puede venir del contexto, del proceso, de la actividad o de la ejecución.
- **Expresiones dinámicas**: Fechas, nombres de archivos, destinatarios, etc., se calculan en tiempo real.
- **Parámetros de control**: Flags booleanos, umbrales, formatos, etc.
- **Notificaciones y logs**: Parámetros para notificar a diferentes áreas según el proceso.
- **Ejecuciones especiales**: El usuario puede sobrescribir cualquier parámetro en la ejecución para pruebas, contingencias o necesidades puntuales. 