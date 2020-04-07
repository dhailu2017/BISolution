--*************************** Instructors Version ******************************--
-- Title: DWStudentEnrollments Document Models Views
-- Author: RRoot
-- Desc: View in the 
--		[DWStudentEnrollments] database for Document. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- <03/14/2020>,<Dejene Hailu>, Modified ETL code
--**************************************************************************--

USE DWStudentEnrollments;
Go

CREATE or ALTER FUNCTION dbo.fKPIMaxLessCurrentEnrollments(@ClassKey int)
Returns int
AS
BEGIN
  RETURN(
   SELECT DISTINCT [Number of Students] = CASE
   WHEN (dc.MaxClassEnrollment * .25) >= (COUNT(fe.Studentkey) OVER (PARTITION BY fe.ClassKey))
    THEN -1
   WHEN (dc.MaxClassEnrollment * .5) > (COUNT(fe.Studentkey) OVER (PARTITION BY fe.ClassKey))
    THEN 0
   When (dc.MaxClassEnrollment * .75) >= (COUNT(fe.Studentkey) OVER (PARTITION BY fe.ClassKey))
    THEN 1
  END
  FROM FactEnrollments AS fe Join DimClasses AS dc
    ON fe.ClassKey = dc.ClassKey
  WHERE fe.ClassKey = @ClassKey
  )
END
GO
SELECT dbo.fKPIMaxLessCurrentEnrollments(20);
SELECT dbo.fKPIMaxLessCurrentEnrollments(21);
Go


Create or Alter View vETLForDocumentDB  
AS
  Select 
   [EnrollmentID] = EnrollmentID 
	,[FullDate] = CAST(FullDate as Date)
	,[Date] = REPLACE([USADateName], ',' , ' ') 
	,[Month] = REPLACE([MonthName], ',', ' ' )
	,[Quarter] = REPLACE(QuarterName, ',', '  ' )
	,[Year] = YearName
	,[ClassID] = ClassID
  ,[Course] = ClassName
  , DepartmentID
  ,[Department]= DepartmentName
  , ClassStartDate
  ,ClassEndDate
  ,ClassroomID
  ,[Classroom] = ClassroomName
  ,StudentID
  ,[StudentFullName] = StudentName
  ,StudentEmail
  ,[MaxCourseEnrollment] = MaxClassEnrollment
  ,MaxClassroomSize = MaxClassSize
  ,[EnrollmentsPerCourse] = Count(fe.Studentkey) Over(Partition By fe.ClassKey)
  ,[CourseEnrollmentLevelKPI] = dbo.fKPIMaxLessCurrentEnrollments(fe.ClassKey)
  ,[CurrentCoursePrice] = CurrentClassPrice 
  ,ActualEnrollmentPrice
  From FactEnrollments as fe
  Join DimDate as dd
    On fe.DateKey = dd.DateKey
  Join DimClasses as dc
    On fe.ClassKey = dc.ClassKey
  Join DimStudents as ds
    On fe.StudentKey = ds.StudentKey;
Go

SELECT * FROM vETLForDocumentDB 



















