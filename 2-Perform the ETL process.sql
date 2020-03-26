--*************************************************************************--
-- Title: Perform the DWStudentEnrollments ETL process
-- Author: RRoot
-- Desc: This file will FLUSH AND FILL the [DWStudentEnrollments] database tables. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- <03/14/2020>,<Dejene Hailu>, Modified ETL code
--**************************************************************************--

USE DWStudentEnrollments
Go

ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
DROP CONSTRAINT fk_FactEnrollments_DimClasses;

ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
DROP CONSTRAINT fk_FactEnrollments_DimStudents;

ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
DROP CONSTRAINT fk_FactEnrollments_Dimdate;
Go

TRUNCATE TABLE DWStudentEnrollments.dbo.DimClasses;
TRUNCATE TABLE DWStudentEnrollments.dbo.DimStudents;
TRUNCATE TABLE DWStudentEnrollments.dbo.DimDate;
GO

INSERT INTO DWStudentEnrollments.dbo.DimClasses
SELECT [ClassID] = IIF([ClassID] IS NULL,  'Soon inform you', [ClassID])
		 ,[ClassName] 
		 ,[DepartmentID] = IIF (ED.DepartmentID IS NULL, 'Soon inform you', ED.DepartmentID)
		 ,[ClassStartDate]= CAST([ClassEndDate] AS [date])
		 ,[ClassEndDate] = CAST([ClassEndDate] AS [date])
		 ,[CurrentClassPrice] 
		 ,[MaxClassEnrollment]
		 ,[ClassroomID] = IIF(EC.[ClassroomID] IS NULL, 'Soon inform you', Ec.[ClassroomID])
		 ,[ClassroomName] 
		 ,[MaxClassSize]
		 ,[DepartmentName]
FROM [StudentEnrollments].[dbo].[Classes] AS EC
JOIN [StudentEnrollments].[dbo].[Classrooms] AS ECR
ON EC.ClassRoomID = ECR.ClassRoomID
JOIN [StudentEnrollments].[dbo].Departments AS ED
ON EC.DepartmentID = ED.DepartmentID
GO

---An explicit value for the identity column in table 'DWStudentEnrollments.dbo.DimStudents' 
----can only be specified when a column list is used and IDENTITY_INSERT is ON.
---Step1: [StudentFirstName] = [StudentFirstName] + [StudentLastName]
---'fk_FactEnrollments_DimStudents' is not a constraint ---computer replay
---Violation of PRIMARY KEY constraint 'pk_FactEnrollments'. Cannot insert duplicate key in object 'dbo.FactEnrollments'. The duplicate key value is (1, 1, 1).
---Finally changed into 
---Step2: [StudentFirstName] = CONCAT([StudentFirstName], ' ' , [StudentLastName])
INSERT INTO DWStudentEnrollments.dbo.DimStudents
SELECT [StudentID] = IIF([StudentID] IS NULL,  'Soon inform you', [StudentID])
		,[StudentName] = CONCAT(StudentFirstName, ' ' , StudentLastName)
		,[StudentEmail]
FROM [StudentEnrollments].[dbo].[Students]
GO

---Create Dimate table using variables to hold the start and end date
DECLARE @StartDate datetime = '2020-01-01'
DECLARE @EndDate datetime = '2020-02-04' 

DECLARE @DateInProcess datetime
Set @DateInProcess = @StartDate

WHILE @DateInProcess <= @EndDate
 BEGIN

 INSERT INTO DWStudentEnrollments.dbo.Dimdate 
 ( [DateKey], [FullDate], [USADateName], [MonthKey], [MonthName], [QuarterKey], [QuarterName], [YearKey], [YearName] )
 VALUES ( 
    Cast(Convert(nvarchar(100), @DateInProcess , 112) as int)
   ,@DateInProcess 
  , DateName( weekday, @DateInProcess ) + ', ' + Convert(nvarchar(100), @DateInProcess , 110)   
  , Left(Cast(Convert(nvarchar(100), @DateInProcess , 112) as int), 6)    
  , DateName( MONTH, @DateInProcess ) + ', ' + Cast( Year(@DateInProcess ) as nVarchar(100) )
  ,  Cast(Cast(YEAR(@DateInProcess) as nvarchar(100))  + '0' + DateName( QUARTER,  @DateInProcess) as int)
  , 'Q' + DateName( QUARTER, @DateInProcess ) + ', ' + Cast( Year(@DateInProcess) as nVarchar(100) ) 
  , CAST(Year( @DateInProcess ) AS int) 
  , Cast( Year(@DateInProcess ) as nVarchar(100) )           
  )  
 Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
 End 

  
INSERT INTO DWStudentEnrollments.dbo.Dimdate 
  ( [DateKey] 
  ,[FullDate]
  , [USADateName]
  , [MonthKey]
  , [MonthName]
  , [QuarterKey]
  , [QuarterName]
  , [YearKey]
  , [YearName] )
  SELECT 
    [DateKey] = -1
  ,[FullDate] = -1
  , [DateName] = Cast('Unknown Day' as nVarchar(100) )
  , [Month] = -1
  , [MonthName] = Cast('Unknown Month' as nVarchar(100) )
  , [Quarter] =  -1
  , [QuarterName] = Cast('Unknown Quarter' as nVarchar(100) )
  , [Year] = -1
  , [YearName] = Cast('Unknown Year' as nVarchar(100) )
  UNION
  SELECT 
    [DateKey] = -2
  ,[FullDate] = -2
  , [DateName] = Cast('Corrupt Day' as nVarchar(100) )
  , [Month] = -2
  , [MonthName] = Cast('Corrupt Month' as nVarchar(100) )
  , [Quarter] =  -2
  , [QuarterName] = Cast('Corrupt Quarter' as nVarchar(100) )
  , [Year] = -2
  , [YearName] = Cast('Corrupt Year' as nVarchar(100) )
Go


INSERT INTO DWStudentEnrollments.dbo.FactEnrollments
SELECT [EnrollmentID] = IIF([EnrollmentID] IS NULL,  'Soon inform you', [EnrollmentID])
		 ,[DateKey] 
		 ,[StudentKey] 
		 ,[ClassKey] 
		 ,[ActualEnrollmentPrice] = FORMAT(CAST([ActualEnrollmentPrice] AS money), 'C', 'en-US')
FROM  DWStudentEnrollments.dbo.DimClasses AS DC
join [StudentEnrollments].[dbo].[Enrollments] AS EE
ON DC.ClassID = EE.ClassID
join DWStudentEnrollments.dbo.DimStudents AS DS
ON EE.StudentID = DS.StudentID
join DWStudentEnrollments.dbo.Dimdate AS DD
ON DD.DateKey = isNull(Convert(nvarchar(100), EE.EnrollmentDate, 112), '-1')
Go

ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
ADD CONSTRAINT fk_FactEnrollments_DimClasses
FOREIGN KEY (ClassKey) REFERENCES DimClasses (ClassKey);

ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
ADD CONSTRAINT fk_FactEnrollments_DimStudents
FOREIGN KEY (StudentKey) REFERENCES DimStudents (StudentKey);

ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
ADD CONSTRAINT fk_FactEnrollments_Dimdate
FOREIGN KEY (DateKey) REFERENCES Dimdate (DateKey);
Go

-- Review the results of this script
Select 'Database Created'
Select Name, xType, crDate from SysObjects 
Where xType in ('u', 'PK', 'F')
Order By xType Desc, Name



select * from Dimdate





