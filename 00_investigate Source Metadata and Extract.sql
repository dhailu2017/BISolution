-*************************************************************************--
-- Title: Perform the DWStudentEnrollments ETL process
-- Author: RRoot
-- Desc: This file will FLUSH AND FILL the [DWStudentEnrollments] database tables. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- <03/14/2020>,<Dejene Hailu>, Modified ETL code
--**************************************************************************--

USE [StudentEnrollments]
GO

SELECT *
FROM INFORMATION_SCHEMA.TABLES

SP_HELP Classes
-----Database objects copied from source colud database using general script and created new database and copied all objects.
----Reaserching database objects from sysobjects using the following sql scrip


--SELECT [Name], crdate, Parent_obj, [type] 
--FROM SysObjects
--WHERE xtype in ('u', 'pk', 'fk', 'f' )
--ORDER BY crdate

-- Getting MetaData --------------------------------------------------------------
USE StudentEnrollments;
-- Two important functions are Object_Name and Object_ID
SELECT 'Name' = object_name(-105), 'ID' = object_id('SysObjects');
-- Note the aliases
SELECT 'Object_Name' = Object_Name(-105), 'Object_Id' = Object_iId('SysObjects');

-- [SysObjects] --
SELECT * 
FROM Sys.objects ORDER BY create_date desc;

SELECT * 
FROM SysObjects 
WHERE xtype in ('u', 'pk', 'f' )
ORDER BY parent_obj
--Order by crdate desc


SELECT  [Name], [Parent object] = iif(parent_obj = 0, '', Object_Name(parent_obj)) 
FROM SysObjects 
WHERE xtype in ('u', 'pk', 'f')
ORDER BY  parent_obj

-- [Sys.Objects] -- Newer
SELECT * 
FROM Sys.Objects ORDER BY create_date desc;

-- Filter out most system objects
SELECT  *, 'Parent object' = iif(parent_object_id = 0, '', Object_Name(parent_object_id)) 
FROM Sys.Objects 
WHERE type in ('u', 'pk', 'f') 
ORDER BY  parent_object_id

-- Just the object and Parent objects
SELECT Name, 'Parent object' = iif(parent_object_id = 0, '', Object_Name(parent_object_id)) 
FROM Sys.Objects 
WHERE type in ('u', 'pk', 'f') 
ORDER BY  parent_object_id

-- [Sys.Tables] -- 
SELECT * FROM Sys.Tables ORDER BY create_date;

---Schema
SELECT "Schema" = schema_name([schema_id]), [name] 
FROM Sys.Tables 

-- [Sys.Columns] -- 
SELECT * FROM Sys.Columns; 

---tables
SELECT [Table] = object_name([object_id]), [Name], system_type_id, max_length
                   , [precision], scale, is_nullable  
FROM Sys.Columns
WHERE [object_id] in (SELECT [object_id] FROM Sys.Tables); 

-- [Sys.Types] -- 
SELECT * FROM Sys.Types;

---join
SELECT [Table] = object_name([object_id]), c.[Name], t.[Name], c.max_length, t.max_length
FROM Sys.Types AS t 
Join Sys.Columns AS c 
 ON t.system_type_id = c.system_type_id 
WHERE [object_id] in (SELECT [object_id] FROM Sys.Tables); 
 

 -- Combining the results 
SELECT  
 [Database] = DB_Name()
,[Schema Name] = SCHEMA_NAME(tab.[schema_id])
,[Table] = object_name(tab.[object_id])
,[Column] =  col.[Name]
,[Type] =  t.[Name] 
,[Nullable] = col.is_nullable
FROM Sys.Types AS t 
Join Sys.Columns AS col 
 ON t.system_type_id = col.system_type_id 
Join Sys.Tables tab
  ON Tab.[object_id] = col.[object_id]
And t.name <> 'sysname'
ORDER BY 1, 2;

--3.13.1-- option one Formating for documentation
SELECT 
 [Source Table] = DB_Name() + '.' + SCHEMA_NAME(tab.[schema_id]) + '.' + object_name(tab.[object_id])
,[Source Column] =  col.[Name]
,[Source Type] = CASE 
	      WHEN t.[Name] in ('char', 'nchar', 'varchar', 'nvarchar' ) 
		THEN t.[Name] + ' (' +  format(col.max_length, '####') + ')'                
	      WHEN t.[Name]  in ('decimal', 'money') 
		THEN t.[Name] + ' (' +  format(col.[precision], '#') + ',' + format(col.scale, '#') + ')'
             ELSE t.[Name] 
             END 
,[Source Nullability] = iif(col.is_nullable = 0, 'null', 'not null')  
,[Sort] = ROW_NUMBER() OVER (ORDER BY tab.[object_id])
FROM Sys.Types AS t 
Join Sys.Columns as col 
 ON t.system_type_id = col.system_type_id 
Join Sys.Tables tab
  ON Tab.[object_id] = col.[object_id]
And t.name <> 'sysname'
ORDER BY [Sort]; 

----3.13.2. Option two Formating for documentation
SELECT
 [Source Table] = CONCAT(DB_Name(), SCHEMA_NAME(tab.[schema_id])
, object_name(tab.[object_id]))
,[Source Columns] = col.[Name]
,[Source Data Type] =  
       CASE 
	      WHEN t.[Name] in ('char', 'nchar', 'varchar', 'nvarchar' ) 
		THEN t.[Name] + ' (' +  format(col.max_length, '####') + ')'                
	      WHEN t.[Name]  in ('decimal', 'money') 
		THEN t.[Name] + ' (' +  format(col.[precision], '#') + ',' + format(col.scale, '#') + ')'
             ELSE t.[Name] 
             END 
,[Nullability] =  CASE 
              WHEN col.is_nullable = 1 THEN 'not null'
			  WHEN  col.is_nullable = 0 THEN 'null'
			  ELSE '' END
FROM Sys.Types AS t 
Join Sys.Columns AS col 
 ON t.system_type_id = col.system_type_id 
Join Sys.Tables tab
  ON Tab.[object_id] = col.[object_id]
And t.name <> 'sysname' 
WHERE object_name(tab.[object_id]) <> 'sysdiagrams'
ORDER BY object_name(tab.[object_id]);


-- Getting Sample Data --------------------------------------------------------------
EXEC sp_msforeachtable @Command1 = 'sp_help [?]'
Go 

---Sample data
SELECT TOP(2)* FROM [dbo].[Classes]
SELECT TOP(2)* FROM [dbo].[Classrooms];
SELECT TOP(2)* FROM [dbo].[Departments];
SELECT TOP(2)* FROM [dbo].[Students];
SELECT TOP(2)* FROM [dbo].[Enrollments];
SELECT * FROM vStudentEnrollmentsMetaData

---CREATE DATA VIEW FOR METAD DATA
USE StudentEnrollments;
GO
Create or Alter View vStudentEnrollmentsMetaData
AS
SELECT TOP 100 PERCENT
 [Source Table] = DB_Name() + '.' + SCHEMA_NAME(tab.[schema_id]) + '.' + object_name(tab.[object_id])
,[Source Column] =  col.[Name]
,[Source Type] = CASE 
				WHEN t.[Name] in ('char', 'nchar', 'varchar', 'nvarchar' ) 
				  THEN t.[Name] + ' (' +  format(col.max_length, '####') + ')'                
				WHEN t.[Name]  in ('decimal', 'money') 
				  THEN t.[Name] + ' (' +  format(col.[precision], '#') + ',' + format(col.scale, '#') + ')'
				 ELSE t.[Name] 
                End 
,[Source Nullability] = iif(col.is_nullable = 1, 'Null', 'Not Null') 
FROM Sys.Types AS t 
Join Sys.Columns AS col 
 ON t.system_type_id = col.system_type_id 
Join Sys.Tables tab
  ON tab.[object_id] = col.[object_id]
And t.name <> 'sysname'
ORDER BY [Source Table], col.column_id; 
GO
SELECT * FROM vStudentEnrollmentsMetaData;
