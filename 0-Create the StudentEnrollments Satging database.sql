--*************************************************************************--
-- Title: Create the DWStudentEnrollments database
-- Author: RRoot
-- Desc: This file will drop and create the [DWStudentEnrollments] database, with all its objects. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- <03/14/2020>,<Dejene Hailu>, Modified DW creation code
--**************************************************************************--

USE StudentEnrollments
Go

ALTER TABLE StudentEnrollments.[dbo].[Classes] 
DROP CONSTRAINT [fkClassesToClassrooms];

ALTER TABLE StudentEnrollments.[dbo].[Classes]
DROP CONSTRAINT [fkClassesToDepartments];

ALTER TABLE StudentEnrollments.[dbo].[Enrollments]
DROP CONSTRAINT [fkEnrollmentsToClasses];

ALTER TABLE StudentEnrollments.[dbo].[Enrollments]
DROP CONSTRAINT [fkEnrollmentsToStudents];


TRUNCATE TABLE StudentEnrollments.dbo.Classes;
TRUNCATE TABLE StudentEnrollments.dbo.Students;
TRUNCATE TABLE StudentEnrollments.[dbo].[Classrooms];
TRUNCATE TABLE StudentEnrollments.[dbo].[Departments];
TRUNCATE TABLE StudentEnrollments.[dbo].[Enrollments];


--Create the Departments staging table (insert into target table from linked cloud server database)
INSERT INTO StudentEnrollments.dbo.Departments
SELECT [DepartmentName]
FROM [continuumsql.westus2.cloudapp.azure.com].StudentEnrollments.[dbo].[Departments];


--Create the Classrooms staging table (Copy table from linked cloud server database)
INSERT INTO StudentEnrollments.dbo.Classrooms 
SELECT [ClassroomName], [MaxClassSize]
FROM [continuumsql.westus2.cloudapp.azure.com].StudentEnrollments.[dbo].[Classrooms];


-- Create the Classes staging table (Copy table from linked cloud server database)
INSERT INTO StudentEnrollments.dbo.Classes 
SELECT [ClassName], [DepartmentID], [ClassStartDate], [ClassEndDate], [CurrentClassPrice], [MaxClassEnrollment]
, [ClassroomID]
FROM [continuumsql.westus2.cloudapp.azure.com].StudentEnrollments.[dbo].[Classes]


--Create the Students staging table (Copy table from linked cloud server database)
INSERT INTO StudentEnrollments.dbo.Students
SELECT [StudentFirstName], [StudentLastName], [StudentEmail]
FROM [continuumsql.westus2.cloudapp.azure.com].StudentEnrollments.[dbo].[Students]


--Create the Enrollments staging table (Copy table from linked cloud server database)
INSERT INTO StudentEnrollments.dbo.Enrollments
SELECT [EnrollmentDate], [StudentID], [ClassID], [ActualEnrollmentPrice]
FROM [continuumsql.westus2.cloudapp.azure.com].StudentEnrollments.[dbo].[Enrollments]


--Add Forien key constraints
ALTER TABLE Classes ADD CONSTRAINT 
       [fkClassesToDepartments] FOREIGN KEY (DepartmentID) REFERENCES Departments (DepartmentID);

ALTER TABLE Classes ADD CONSTRAINT 
       [fkClassesToClassrooms] FOREIGN KEY (ClassroomID) REFERENCES Classrooms (ClassroomID);

ALTER TABLE Enrollments ADD CONSTRAINT 
       [fkEnrollmentsToStudents] FOREIGN KEY (StudentID) REFERENCES Students (StudentID);

ALTER TABLE Enrollments ADD CONSTRAINT
       [fkEnrollmentsToClasses] FOREIGN KEY (ClassID) REFERENCES Classes (ClassID);




Select 'Database Created'
Select Name, xType, crDate from SysObjects 
Where xType in ('u', 'PK', 'F')
Order By xType Desc, Name
GO

