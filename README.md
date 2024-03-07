### Task 1
Дадена е таблицата Staff, в която са записани служителите на компанията, датата, от която са на дадената позиция и ID на позицията.
Да се извадят всички служители, които към 01.01.2014 са на PositionID = 15.

Table Staff
ID	UserID	FName	LName	StartDate	PositionID
12	12	Ivan	Petrov	5.3.2012	11
13	123	Asen 	Vasev	  6.3.2012	15
14	34	Maya	Dimova	7.3.2012	11
15	34	Maya	Dimova	8.3.2013	15
16	12	Ivan	Petrov	9.3.2015	15
17	34	Maya	Dimova	8.3.2018	11

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
