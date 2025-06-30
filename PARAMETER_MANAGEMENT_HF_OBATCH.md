# Parameter Management in HF_OBATCH

> **For the Spanish version, see [PARAMETER_MANAGEMENT_HF_OBATCH.es.md](PARAMETER_MANAGEMENT_HF_OBATCH.es.md)**

## 1. Introduction
This document provides an in-depth description of how parameters are managed, resolved, and overridden in the HF_OBATCH system, covering company, process, activity, and execution levels.

## 2. Parameter Hierarchy and Resolution
- **Company Level:** Global parameters for each company.
- **Process/Activity Level:** Parameters defined in the configuration of each process or activity.
- **Execution Level:** Parameters explicitly passed when launching an execution.
- **Resolution Priority:** Execution > Company > Process/Activity > Default value.

## 3. Parameter Definition
- Parameter tables (by company, process, activity).
- Parameters in configuration JSON.
- Example of definition and structure.

## 4. Examples of Resolution and Overriding

### Example 1: Multi-company Monthly Closing Process

#### a) Process: MONTHLY_CLOSING
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

#### b) Activity: GENERATE_BALANCE
```json
{
  "P_COMPANY": null,
  "P_CUTOFF_DATE": null,
  "P_REPORT_TYPE": "BALANCE",
  "P_FORMAT": "PDF"
}
```

#### c) Activity: SEND_REPORT
```json
{
  "P_COMPANY": null,
  "P_CUTOFF_DATE": null,
  "P_RECIPIENT": "accounting@company.com, audit@company.com",
  "P_SUBJECT": "Monthly balance [:company_id] [:sysdate|YYYY-MM]",
  "P_ATTACH_LOG": true
}
```

#### d) Execution
- The user launches the chain for company 1001, user "jlopez".
- The system resolves:
  - `P_COMPANY`: 1001 (from execution context)
  - `P_CUTOFF_DATE`: last day of previous month (dynamic)
  - `P_USER`: "jlopez"
  - `P_CLOSING_TYPE`: "MONTHLY"
  - `P_AUTO_SEND`: true
  - `P_RETRIES`: 3
- Activities inherit these parameters unless overridden in the execution or activity configuration.

---

### Example 2: Data Load Process with Validation Parameters

#### a) Process: DATA_LOAD
```json
{
  "P_COMPANY": "[:company_id]",
  "P_START_DATE": "trunc(sysdate, 'MM')",
  "P_END_DATE": "last_day(sysdate)",
  "P_VALIDATE_DUPLICATES": true,
  "P_LOAD_TYPE": "INCREMENTAL"
}
```

#### b) Activity: VALIDATE_DATA
```json
{
  "P_COMPANY": null,
  "P_START_DATE": null,
  "P_END_DATE": null,
  "P_VALIDATE_DUPLICATES": null,
  "P_ERROR_THRESHOLD": 0.01
}
```

#### c) Activity: LOAD_TABLE
```json
{
  "P_COMPANY": null,
  "P_START_DATE": null,
  "P_END_DATE": null,
  "P_LOAD_TYPE": null,
  "P_TARGET_TABLE": "TRANSACTIONS"
}
```

#### d) Special Execution
- The user launches the chain for company 2047, but passes in the execution:
  ```json
  {
    "P_LOAD_TYPE": "TOTAL",
    "P_VALIDATE_DUPLICATES": false
  }
  ```
- The system resolves:
  - `P_LOAD_TYPE`: "TOTAL" (from execution)
  - `P_VALIDATE_DUPLICATES`: false (from execution)
  - `P_COMPANY`: 2047 (from context)
  - `P_START_DATE` and `P_END_DATE`: from process
  - `P_ERROR_THRESHOLD`: 0.01 (from activity)
  - `P_TARGET_TABLE`: "TRANSACTIONS" (from activity)

---

### Example 3: Process with Control and Notification Parameters

#### a) Process: EXPORT_REPORTS
```json
{
  "P_COMPANY": "[:company_id]",
  "P_EXPORT_DATE": "sysdate",
  "P_FILE_FORMAT": "XLSX",
  "P_SEND_NOTIFICATION": true,
  "P_NOTIFICATION_EMAILS": "support@company.com, manager@company.com"
}
```

#### b) Activity: GENERATE_REPORT
```json
{
  "P_COMPANY": null,
  "P_EXPORT_DATE": null,
  "P_FILE_FORMAT": null,
  "P_REPORT_NAME": "Report_[:company_id]_[::sysdate|YYYYMMDD].xlsx"
}
```

#### c) Activity: SEND_NOTIFICATION
```json
{
  "P_COMPANY": null,
  "P_NOTIFICATION_EMAILS": null,
  "P_MESSAGE": "The report was successfully exported on [:sysdate|YYYY-MM-DD]."
}
```

---

## Real-World Scenarios Covered

- **Parameter inheritance and overriding:** A parameter can come from context, process, activity, or execution.
- **Dynamic expressions:** Dates, file names, recipients, etc., are calculated at runtime.
- **Control parameters:** Boolean flags, thresholds, formats, etc.
- **Notifications and logs:** Parameters to notify different areas depending on the process.
- **Special executions:** The user can override any parameter in the execution for testing, contingencies, or specific needs. 