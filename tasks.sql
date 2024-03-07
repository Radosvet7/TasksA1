CREATE TABLE Staff ([ID] INT,
[UserID] INT,
[FName] VARCHAR(50),
[LName] VARCHAR(50),
[StartDate] DATETIME2,
[PositionID] INT)

CREATE TABLE Contracts (SubID INT,
[StartDT] DATETIME2,
[EndDT] DATETIME2,
ContractEndDT DATETIME2,
ContractPeriod INT )

INSERT INTO Staff (ID, UserID, FName, LName, StartDate, PositionID) VALUES
(12, 12, 'Ivan', 'Petrov', '5.3.2012', 11),
(13, 123, 'Asen', 'Vasev', '6.3.2012', 15),
(14, 34, 'Maya', 'Dimova', '7.3.2012', 11),
(15, 34, 'Maya', 'Dimova', '8.3.2013', 15),
(16, 12, 'Ivan', 'Petrov', '9.3.2015', 15),
(17, 34, 'Maya', 'Dimova', '8.3.2018', 11)

INSERT INTO Contracts (SubID, StartDT, EndDT, ContractEndDT, ContractPeriod) VALUES
(1, '2014-01-01', '2015-08-15', '2015-01-01', 12),
(1, '2015-08-15', '2017-12-01', '2017-08-01', 24)


select * from Contracts
SELECT * FROM Staff

;WITH EmpLastPos AS (SELECT UserID, 
FName + ' ' + LName as [Name],
MAX(StartDate) as StartDateLastPosition 
FROM Staff
WHERE StartDate <= '2014-01-01'
GROUP BY UserID, FName + ' ' + LName)
SELECT e.UserID, e.Name
FROM EmpLastPos e
JOIN Staff s ON e.UserID = s.UserID AND e.StartDateLastPosition = s.StartDate and s.PositionID = 15
ORDER BY s.FName, s.LName ASC

SELECT DISTINCT e.UserID, e.FName + ' ' + e.LName as [Name]
FROM Staff e
WHERE EXISTS (
   SELECT 1
   FROM Staff s
   WHERE s.UserID = e.UserID 
   AND s.StartDate <= '2014-01-01'
   AND s.PositionID = 15
)

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








