--*************************** Instructors Version ******************************--
-- Title: DWStudentEnrollments Tabular Models Views
-- Author: RRoot
-- Desc: This file will create or alter views in the [DWStudentEnrollments] database for its Tabular Models. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- <03/14/2020>,<Dejene Hailu>, Modified ETL code
--**************************************************************************--
Set NoCount On;
Go

USE DWStudentEnrollments;
Go

-- Dimension Tables --
CREATE or ALTER View vDimStudentTabularETL
AS
SELECT StudentKey
        ,StudentID 
		,[StudentName]
		,[StudentEmail]
FROM DWStudentEnrollments.dbo.DimStudents 
GO

CREATE or ALTER View vDimClassTabularETL
AS
SELECT ClassKey
        ,ClassID
		,DepartmentName
		,ClassroomName
		,ClassName 
		,ClassStartDate
		,ClassEndDate
		,CurrentClassPrice = FORMAT(CurrentClassPrice, 'C', 'en-us') 
		,MaxClassEnrollment
		,MaxClassSize
FROM DWStudentEnrollments.dbo.DimClasses
GO

CREATE or ALTER View vDimDateTabularETL 
AS
SELECT DateKey 
         ,[Date] = [FullDate] 
         ,[USADateName]= CONVERT(varchar(100), USADateName, 110)
         ,[MonthKey] = CONVERT(varchar(100), [MonthKey], 112)   
         ,[Month] = [MonthName]
		 ,[QuarterKey] = CONVERT(varchar(100), [QuarterKey], 110)
		 ,[Quarter] = [QuarterName]
         ,[YearKey] = CAST([YearKey] AS char(100))
         ,[Year] = [YearName]
FROM DWStudentEnrollments.dbo.Dimdate 
WHERE DateKey > 0
GO 
-- Fact Table --
CREATE or ALTER View vFactEnrollmentTabularETL
AS
SELECT EnrollmentID	  
       ,ClassKey
	    ,StudentKey 
		 ,DateKey
	   ,ActualEnrollmentPrice = FORMAT(ActualEnrollmentPrice, 'C', 'en-us')    
FROM DWStudentEnrollments.dbo.FactEnrollments
GO
--
 --= cast(Convert(varchar(50), DateKey, 112) AS [date])

SELECT * FROM vDimStudentTabularETL
SELECT * FROM vDimClassTabularETL
SELECT * FROM vDimDateTabularETL
SELECT * FROM vFactEnrollmentTabularETL