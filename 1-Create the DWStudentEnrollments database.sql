--*************************************************************************--
-- Title: Create the DWStudentEnrollments database
-- Author: RRoot
-- Desc: This file will DROP AND CREATE the [DWStudentEnrollments] database, with all its objects. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- 03/13/2020
---DejeneHailu
---Modified DW creation code
--**************************************************************************--

USE [master]
IF Exists (SELECT Name from SysDatabases WHERE Name = 'DWStudentEnrollments')
  BEGIN
   ALTER DATABASE DWStudentEnrollments SET SINGLE_USER WITH ROLLBACK IMMEDIATE
   DROP DATABASE DWStudentEnrollments
  End
GO
CREATE DATABASE DWStudentEnrollments;
GO
USE DWStudentEnrollments;
GO

-- Create the Dimension Tables
CREATE TABLE DWStudentEnrollments.dbo.DimClasses(
          ClassKey int IDENTITY(1,1)        NOT NULL
		 ,ClassID int                       NOT NULL
		 ,ClassName nvarchar(100)    NULL
		 ,DepartmentID int             NOT NULL
		 ,ClassStartDate date               NULL
		 ,ClassEndDate date                 NULL
		 ,CurrentClassPrice money           NULL
		 ,MaxClassEnrollment int            NULL
		 ,ClassroomID int                   NOT NULL
		 ,ClassroomName nchar(20)           NULL
		 ,MaxClassSize int                  NULL
		 ,DepartmentName nvarchar(100) NULL
		 CONSTRAINT pk_DimClasses PRIMARY KEY (ClassKey)
		 )
Go

CREATE TABLE DWStudentEnrollments.dbo.DimStudents(
         StudentKey int IDENTITY (1,1)      NOT NULL
		,StudentID int                      NOT NULL
		,StudentName nvarchar(200)     NOT NULL
		,StudentEmail nvarchar(100)         NULL
		CONSTRAINT pk_DimStudents PRIMARY KEY (StudentKey)
		)
GO

CREATE TABLE DWStudentEnrollments.dbo.Dimdate(
         DateKey int                        NOT NULL
		,FullDate datetime                  NOT NULL
		,USADateName nvarchar(50)           NOT NULL
		,MonthKey int                       NOT NULL
		,[MonthName] nvarchar(50)           NOT NULL
		,QuarterKey int                     NOT NULL
		,QuarterName nvarchar(50)           NOT NULL
		,YearKey int                        NOT NULL
		,YearName nvarchar(50)              NOT NULL
		CONSTRAINT pk_Dimdate PRIMARY KEY (DateKey)
		)
GO

-- Create the Fact Tables
CREATE TABLE DWStudentEnrollments.dbo.FactEnrollments(
          EnrollmentID int                    NOT NULL
		 ,DateKey int                         NOT NULL
		 ,StudentKey int                       NOT NULL
		 ,ClassKey int                        NOT NULL
		 ,ActualEnrollmentPrice money NOT NULL
		 CONSTRAINT pk_FactEnrollments	PRIMARY KEY (EnrollmentID, ClassKey, DateKey)
		 )
Go

-- Add the Foreign Key Constraints
ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
ADD CONSTRAINT fk_FactEnrollments_DimClasses
FOREIGN KEY (ClassKey) REFERENCES DimClasses (ClassKey)
Go

ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
ADD CONSTRAINT fk_FactEnrollments_DimStudents
FOREIGN KEY (StudentKey) REFERENCES DimStudents (StudentKey)
GO

ALTER TABLE DWStudentEnrollments.dbo.FactEnrollments
ADD CONSTRAINT fk_FactEnrollments_Dimdate
FOREIGN KEY (DateKey) REFERENCES Dimdate (DateKey)
GO

ALTER TABLE DWStudentEnrollments.dbo.DimStudents
ADD CONSTRAINT fk_DimStudents_Email
UNIQUE (StudentEmail)
GO

 ---Create a Reporting View of all tables
CREATE OR ALTER VIEW vRptStudentEnrollmentByClass
AS 
SELECT TOP 100 PERCENT 
       FE.EnrollmentID 
       ,DC.ClassID
       ,DC.ClassName
	   ,DC.DepartmentName
	   ,DC.CurrentClassPrice
	   ,DC.MaxClassEnrollment
	   ,DC.ClassroomName
	   ,DC.MaxClassSize
	   ,StudentName
	   ,[Date] = CONVERT(Varchar(50),CAST(CAST(IIF(DD.[DateKey] > 0, DD.[DateKey], '20200101') AS CHAR(8)) AS DATE), 112) 
	   ,USADateName
	   ,FE.ActualEnrollmentPrice
FROM DWStudentEnrollments.dbo.DimClasses AS DC
JOIN DWStudentEnrollments.dbo.FactEnrollments AS FE
ON DC.ClassKey = FE.ClassKey
JOIN DWStudentEnrollments.dbo.DimStudents AS DS
ON FE.StudentKey = DS.StudentKey
Join DWStudentEnrollments.dbo.Dimdate AS DD
ON FE.DateKey = DD.DateKey
Go

--********************************************************************--
-- Review the results of this script
--********************************************************************--
Go
Select 'Database Created'
Select Name, xType, crDate from SysObjects 
Where xType in ('u', 'PK', 'F')
Order By xType Desc, Name


