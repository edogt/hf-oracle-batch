# Repeat Interval Examples for HF_OBATCH

> **Oracle Official Documentation:** [DBMS_SCHEDULER Repeat Interval](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html#GUID-4C3E8F8A-8B8A-4B8A-8B8A-4B8A8B8A8B8A)

## Introduction

The `repeat_interval` parameter in HF_OBATCH configuration JSON corresponds directly to the `repeat_interval` parameter in Oracle's `DBMS_SCHEDULER`. This document provides comprehensive examples of how to configure scheduling for different business scenarios.

## Basic Syntax

```json
{
  "repeat_interval": "FREQ=frequency; [INTERVAL=interval]; [BYMONTH=month]; [BYMONTHDAY=day]; [BYHOUR=hour]; [BYMINUTE=minute]; [BYSECOND=second]"
}
```

## Frequency Examples

### 1. Daily Execution

#### Every Day at 2:00 AM
```json
{
  "repeat_interval": "FREQ=DAILY; BYHOUR=2"
}
```

#### Every Day at 9:30 AM
```json
{
  "repeat_interval": "FREQ=DAILY; BYHOUR=9; BYMINUTE=30"
}
```

#### Every Day at 11:45:30 PM
```json
{
  "repeat_interval": "FREQ=DAILY; BYHOUR=23; BYMINUTE=45; BYSECOND=30"
}
```

### 2. Weekly Execution

#### Every Monday at 8:00 AM
```json
{
  "repeat_interval": "FREQ=WEEKLY; BYDAY=MON; BYHOUR=8"
}
```

#### Every Friday at 5:00 PM
```json
{
  "repeat_interval": "FREQ=WEEKLY; BYDAY=FRI; BYHOUR=17"
}
```

#### Every Tuesday and Thursday at 10:00 AM
```json
{
  "repeat_interval": "FREQ=WEEKLY; BYDAY=TUE,THU; BYHOUR=10"
}
```

### 3. Monthly Execution

#### First Day of Every Month at 6:00 AM
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYMONTHDAY=1; BYHOUR=6"
}
```

#### Last Day of Every Month at 11:00 PM
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYMONTHDAY=-1; BYHOUR=23"
}
```

#### 15th Day of Every Month at 3:30 PM
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYMONTHDAY=15; BYHOUR=15; BYMINUTE=30"
}
```

#### First Monday of Every Month at 9:00 AM
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYDAY=MON; BYMONTHDAY=1,2,3,4,5,6,7"
}
```

### 4. Quarterly Execution

#### First Day of Every Quarter at 7:00 AM
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYMONTH=JAN,APR,JUL,OCT; BYMONTHDAY=1; BYHOUR=7"
}
```

#### Last Day of Every Quarter at 6:00 PM
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYMONTH=MAR,JUN,SEP,DEC; BYMONTHDAY=-1; BYHOUR=18"
}
```

### 5. Yearly Execution

#### January 1st at 12:00 AM (New Year)
```json
{
  "repeat_interval": "FREQ=YEARLY; BYMONTH=JAN; BYMONTHDAY=1; BYHOUR=0"
}
```

#### December 31st at 11:59 PM (Year End)
```json
{
  "repeat_interval": "FREQ=YEARLY; BYMONTH=DEC; BYMONTHDAY=31; BYHOUR=23; BYMINUTE=59"
}
```

## Interval-Based Execution

### 1. Every 5 Minutes
```json
{
  "repeat_interval": "FREQ=MINUTELY; INTERVAL=5"
}
```

### 2. Every 2 Hours
```json
{
  "repeat_interval": "FREQ=HOURLY; INTERVAL=2"
}
```

### 3. Every 3 Days
```json
{
  "repeat_interval": "FREQ=DAILY; INTERVAL=3"
}
```

### 4. Every 2 Weeks
```json
{
  "repeat_interval": "FREQ=WEEKLY; INTERVAL=2"
}
```

### 5. Every 6 Months
```json
{
  "repeat_interval": "FREQ=MONTHLY; INTERVAL=6"
}
```

## Business Scenarios

### 1. End-of-Day Processing
```json
{
  "repeat_interval": "FREQ=DAILY; BYHOUR=23; BYMINUTE=30"
}
```

### 2. End-of-Week Processing
```json
{
  "repeat_interval": "FREQ=WEEKLY; BYDAY=FRI; BYHOUR=18"
}
```

### 3. End-of-Month Processing
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYMONTHDAY=-1; BYHOUR=22"
}
```

### 4. End-of-Quarter Processing
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYMONTH=MAR,JUN,SEP,DEC; BYMONTHDAY=-1; BYHOUR=21"
}
```

### 5. End-of-Year Processing
```json
{
  "repeat_interval": "FREQ=YEARLY; BYMONTH=DEC; BYMONTHDAY=31; BYHOUR=23; BYMINUTE=45"
}
```

## Complex Scenarios

### 1. Business Hours Only (Monday-Friday, 9 AM - 5 PM)
```json
{
  "repeat_interval": "FREQ=WEEKLY; BYDAY=MON,TUE,WED,THU,FRI; BYHOUR=9,10,11,12,13,14,15,16,17"
}
```

### 2. Multiple Times Per Day
```json
{
  "repeat_interval": "FREQ=DAILY; BYHOUR=6,12,18"
}
```

### 3. Specific Business Days
```json
{
  "repeat_interval": "FREQ=MONTHLY; BYMONTHDAY=1,15; BYHOUR=8"
}
```

## Special Cases

### 1. Once Only (No Repeat)
```json
{
  "repeat_interval": null
}
```

### 2. Every Second (High Frequency)
```json
{
  "repeat_interval": "FREQ=SECONDLY"
}
```

### 3. Every Minute
```json
{
  "repeat_interval": "FREQ=MINUTELY"
}
```

## Integration with HF_OBATCH

### Example Chain Configuration
```json
{
  "code": "MONTHLY_CLOSING",
  "config": {
    "repeat_interval": "FREQ=MONTHLY; BYMONTHDAY=-1; BYHOUR=22",
    "auto_process_date": "trunc(sysdate-1)",
    "report_fails_to": "admin@company.com",
    "execution_logic": "by rules"
  }
}
```

### Example Process Configuration
```json
{
  "code": "DAILY_BACKUP",
  "config": {
    "repeat_interval": "FREQ=DAILY; BYHOUR=2",
    "propagate_failed_state": true
  }
}
```

## Validation and Testing

### 1. Test Interval Syntax
```sql
-- Test if the interval is valid
SELECT DBMS_SCHEDULER.EVALUATE_CALENDAR_STRING(
  'FREQ=MONTHLY; BYMONTHDAY=-1; BYHOUR=22',
  SYSDATE,
  SYSDATE + 30
) FROM DUAL;
```

### 2. View Next Run Times
```sql
-- Check when the job will run next
SELECT NEXT_RUN_DATE, REPEAT_INTERVAL 
FROM USER_SCHEDULER_JOBS 
WHERE JOB_NAME = 'YOUR_JOB_NAME';
```

## Best Practices

1. **Use Specific Times**: Always specify BYHOUR, BYMINUTE for predictable execution
2. **Consider Time Zones**: Be aware of database timezone settings
3. **Test Intervals**: Validate complex intervals before production use
4. **Document Business Logic**: Clearly document why specific intervals are chosen
5. **Monitor Execution**: Track actual vs. expected execution times

## Common Pitfalls

1. **Missing Time Specification**: `FREQ=DAILY` without BYHOUR may run at unexpected times
2. **Invalid Day Combinations**: `BYDAY=SUN,MON` with `FREQ=MONTHLY` may not work as expected
3. **Timezone Issues**: Intervals may run at different times than expected due to timezone differences
4. **Leap Year Considerations**: February 29th handling in yearly schedules

## References

- [Oracle Scheduler Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html)
- [Calendar String Syntax](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html#GUID-4C3E8F8A-8B8A-4B8A-8B8A-4B8A8B8A8B8A)
- [HF_OBATCH Parameter Management](PARAMETER_MANAGEMENT_HF_OBATCH.md) 