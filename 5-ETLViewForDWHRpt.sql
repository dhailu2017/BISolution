--*************************** Instructors Version ******************************--
-- Title: DWStudentEnrollments Document Models Views
-- Author: RRoot
-- Desc: Scaler user define function in the 
--		[DWStudentEnrollments] database for its Document Model. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- <03/14/2020>,<Dejene Hailu>, Modified ETL code
--**************************************************************************--

 ---Create a Reporting View of all tables

 CREATE OR ALTER VIEW vRptStudentEnrollmentByClass
AS
  SELECT 
   EnrollmentID 
	,[FullDate] = CAST(FullDate AS Date)
	,[Date] =[USADateName]
	,[Month] = [MonthName]
	,[Quarter] = QuarterName
	,[Year] = YearName
	,[ClassID] = ClassID
  ,[Course] = ClassName
  ,DC.DepartmentID
  ,[Department]= DepartmentName
  ,ClassStartDate
  ,ClassEndDate
  ,[CurrentCoursePrice] = CurrentClassPrice
  ,[MaxCourseEnrollment] = MaxClassEnrollment
  ,ClassroomID
  ,[Classroom] = ClassroomName
  ,[MaxClassroomSize] = MaxClassSize
  ,StudentID
  ,[StudentFullName] = StudentName
  ,StudentEmail
  ,[EnrollmentsPerCourse] = COUNT(FE.Studentkey) OVER(Partition By FE.ClassKey)
  ,[CourseEnrollmentLevelKPI] = dbo.fKPIMaxLessCurrentEnrollments(FE.ClassKey)
  ,ActualEnrollmentPrice
  FROM [dbo].[FactEnrollments] AS FE
  Join [dbo].[Dimdate] AS DD
    ON FE.DateKey = DD.DateKey
  Join [dbo].[DimClasses] AS DC
    ON FE.ClassKey = DC.ClassKey
  Join [dbo].[DimStudents] AS DS
    ON FE.StudentKey = DS.StudentKey;
Go
SELECT * FROM vRptStudentEnrollmentByClass;



