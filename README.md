### Task 1
Дадена е таблицата Staff, в която са записани служителите на компанията, датата, от която са на дадената позиция и ID на позицията.
Да се извадят всички служители, които към 01.01.2014 са на PositionID = 15.

##ins pic

```sql
WITH EmpLastPos AS (
    SELECT 
        UserID, 
        FName + ' ' + LName AS [Name],
        MAX(StartDate) AS StartDateLastPosition 
    FROM 
        Staff
    WHERE 
        StartDate <= '2014-01-01'
    GROUP BY 
        UserID, FName + ' ' + LName
)
SELECT 
    e.UserID, 
    e.Name
FROM 
    EmpLastPos e
JOIN 
    Staff s ON e.UserID = s.UserID 
            AND e.StartDateLastPosition = s.StartDate 
            AND s.PositionID = 15
ORDER BY 
    s.FName, s.LName ASC;
```

##ins result

### Task 2
Имаме таблица, която описва с исторически интервали дългосрочните договори на абонатите.
SubID – Id на абоната
StartDT – начална дата на записа
EndDT – крайна дата на записа
ContractEndDT – крайна дата на дългосрочния договор на абоната
ContractPeriod – продължителност на дългосрочния договор
Искаме да получим месечното състояние на договорите на абонатите и по-точно MonthTowardExpiration – брой месеци, оставащи до изтичането на договора
Интервалът FromDT – ToDT е един календарен месец. 
Стойността на MonthTowardExpiration е положителна, ако договорът не е изтекъл, 0, ако договорът изтича в съответния месец, и отрицателна, ако договорът е изтекъл.

## ins pic

```sql
WITH ContractsId AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY SubID ORDER BY StartDT) AS ContractID
  FROM 
    Contracts
),
RecursiveMonths AS (
  SELECT 
    c.SubID,
    c.ContractID,
    DATEFROMPARTS(YEAR(c.StartDT), MONTH(c.StartDT),1) AS FromDT,
    DATEADD(day, 1, EOMONTH(c.StartDT)) AS ToDT,
    DATEFROMPARTS(YEAR(c.EndDT), MONTH(c.EndDT), 1) AS EndMonth,
    c.ContractPeriod,
	DATEFROMPARTS(YEAR(c.ContractEndDT), MONTH(c.ContractEndDT),1) as ContractEndDT
  FROM 
    ContractsId c
  UNION ALL
  SELECT 
    c.SubID,
    c.ContractID,
    DATEADD(month, 1, rm.FromDT),
    DATEADD(day, 1, EOMONTH(DATEADD(month, 1, rm.FromDT))),
    rm.EndMonth,
    c.ContractPeriod,
	DATEFROMPARTS(YEAR(c.ContractEndDT), MONTH(c.ContractEndDT),1) as ContractEndDT
  FROM 
    RecursiveMonths rm
  JOIN 
    ContractsID c ON c.SubID = rm.SubID AND c.ContractID = rm.ContractID
    AND DATEADD(month, 1, rm.FromDT) < rm.EndMonth
)

SELECT 
  SubID,
  FromDT,
  ToDT,
  ContractEndDT,
  ContractPeriod,
  DATEDIFF(MONTH, FromDT, ContractEndDT) as MonthTowardExpiration
FROM 
  RecursiveMonths
ORDER BY
  SubID,
  FromDT;
```
## ins result
