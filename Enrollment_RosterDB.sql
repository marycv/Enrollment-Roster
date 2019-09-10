--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: MaryVilloso
-- Desc: This file demonstrates how to design and create; 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2019-08-27,MaryVilloso,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_MaryVilloso')
	 Begin 
	  Alter Database [ITFnd130FinalDB_MaryVilloso] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_MaryVilloso;
	 End
	Create Database ITFnd130FinalDB_MaryVilloso;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_MaryVilloso;
go

-- Create Tables (Module 01)-- 
Create Table Students
(StudentID int IDENTITY(1,1) NOT NULL
,StudentFirstName nvarchar(100) NOT NULL
,StudentLastName nvarchar(100) NOT NULL
,StudentNumber nvarchar(100) NOT NULL
,StudentEmail nvarchar(100) NOT NULL
,StudentPhone nvarchar(100) NULL
,StudentAddress nvarchar(100) NOT NULL
,StudentCity nvarchar(100) NOT NULL
,StudentState nchar(2) NOT NULL
,StudentZipCode nchar(5) NOT NULL
);
go

Create Table Enrollments
(EnrollmentID int IDENTITY(1,1) NOT NULL
,EnrollmentDate date NOT NULL
,EnrollmentAmountPaid money NOT NULL
,StudentID int NOT NULL
,CourseID int NOT NULL
);
go

Create Table Courses
(CourseID int IDENTITY(1,1) NOT NULL
,CourseName nvarchar(100) NOT NULL
,CourseStartDate date NULL
,CourseEndDate date NULL
,CoursePrice money NULL
);
go

Create Table CourseSessions
(CourseSessionID int IDENTITY(1,1) NOT NULL
,CourseSessionStartTime datetime NOT NULL
,CourseSessionEndTime datetime NOT NULL
,CourseID int NOT NULL
,RoomID int NOT NULL
);
go

Create Table Rooms
(RoomID int IDENTITY(1,1) NOT NULL
,RoomName nvarchar(100) NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin -- Students
	Alter Table Students
	 Add Constraint pkStudents
	  Primary Key (StudentID);

	Alter Table Students
	 Add Constraint ukStudents
	  Unique (StudentNumber);

	Alter Table Students
	 Add Constraint ukStudentEmail
	  Unique (StudentEmail);
End
go

Begin -- Courses
	Alter Table Courses
	 Add Constraint pkCourses
	  Primary Key (CourseID);

	Alter Table Courses
	 Add Constraint ukCourses
	  Unique (CourseName);

	Alter Table Courses
	 Add Constraint ckCourseEndDateGreaterThanCourseStartDate
	  Check (CourseEndDate > CourseStartDate);
End
go

Begin -- Enrollments
	Alter Table Enrollments
	 Add Constraint pkEnrollments
	  Primary Key (EnrollmentID);

	Alter Table Enrollments
	 Add Constraint dfEnrollmentDate
	  Default GetDate() For EnrollmentDate;

	Alter Table Enrollments
	 Add Constraint fkEnrollmentsToStudents
	  Foreign Key (StudentID) References Students(StudentID);

	Alter Table Enrollments
	 Add Constraint fkEnrollmentsToCourses
	  Foreign Key (CourseID) References Courses(CourseID);
End
go

Begin -- Rooms
	Alter Table Rooms
	 Add Constraint pkRooms
	  Primary Key (RoomID);
End
go

Begin -- CourseSessions
	Alter Table CourseSessions
	 Add Constraint pkCourseSessions
	  Primary Key (CourseSessionID);

	Alter Table CourseSessions
	 Add Constraint ckCourseSessionEndTimeGreaterThanCourseSessionStartTime
	  Check (CourseSessionEndTime > CourseSessionStartTime);

	Alter Table CourseSessions
	 Add Constraint fkCourseSessionsToCourses
	  Foreign Key (CourseID) References Courses(CourseID);

	Alter Table CourseSessions
	 Add Constraint fkCourseSessionsToRooms
	  Foreign Key (RoomID) References Rooms(RoomID);
End
go

-- Adding Views (Module 03 and 06) -- 
Create View vStudents
WITH SCHEMABINDING
 AS
  Select StudentID
	    ,StudentFirstName
	    ,StudentLastName
	    ,StudentNumber
	    ,StudentEmail
	    ,StudentPhone
	    ,StudentAddress
	    ,StudentCity
	    ,StudentState
	    ,StudentZipCode
  From dbo.Students;
go

Create View vCourses
WITH SCHEMABINDING
 AS
  Select CourseID
	    ,CourseName
	    ,CourseStartDate
	    ,CourseEndDate
	    ,CoursePrice
  From dbo.Courses;
go

Create View vEnrollments
WITH SCHEMABINDING
 AS
  Select EnrollmentID
	    ,EnrollmentDate
	    ,EnrollmentAmountPaid
	    ,StudentID
	    ,CourseID
  From dbo.Enrollments;
go

Create View vRooms
WITH SCHEMABINDING
 AS
  Select RoomID
	    ,RoomName
  From dbo.Rooms;
go

Create View vCourseSessions
WITH SCHEMABINDING
 AS
  Select CourseSessionID
		,CourseSessionStartTime
		,CourseSessionEndTime
		,CourseID
		,RoomID
  From dbo.CourseSessions;
go

-- Adding Stored Procedures (Module 04, 08, and 09) --

-- Author: MaryVilloso
-- Desc: Processes insert into Students table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.

Create Procedure pInsStudents
 (@StudentFirstName nVarchar(100), @StudentLastName nVarchar(100), @StudentNumber nVarchar(100)
 ,@StudentEmail	nVarchar(100), @StudentPhone nVarchar(100), @StudentAddress Varchar(100)
 ,@StudentCity Varchar(100), @StudentState nChar(2), @StudentZipCode nChar(5)
 )
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Tran
    Insert Into Students
	(StudentFirstName, StudentLastName, StudentNumber
	,StudentEmail, StudentPhone, StudentAddress
	,StudentCity, StudentState, StudentZipCode
	)
	Values  (@StudentFirstName, @StudentLastName, @StudentNumber 
			,@StudentEmail, @StudentPhone, @StudentAddress
			,@StudentCity, @StudentState, @StudentZipCode 
			)
   Commit Tran
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Tran
   Print Error_Message()
   Set @RC = -1
  End Catch
 Return @RC;
End
go

-- Author: MaryVilloso
-- Desc: Processes updates into Students table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.

Create Procedure pUpdStudents
 (@StudentID int, @StudentFirstName nVarchar(100), @StudentLastName nVarchar(100), @StudentNumber nVarchar(100)
 ,@StudentEmail	nVarchar(100), @StudentPhone nVarchar(100), @StudentAddress Varchar(100)
 ,@StudentCity Varchar(100), @StudentState nChar(2), @StudentZipCode nChar(5)
 )
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Update Students
	  Set StudentFirstName = @StudentFirstName
		 ,StudentLastName = @StudentLastName  
		 ,StudentNumber = @StudentNumber
		 ,StudentEmail = @StudentEmail
		 ,StudentPhone = @StudentPhone  
		 ,StudentAddress = @StudentAddress
		 ,StudentCity = @StudentCity
		 ,StudentState = @StudentState
		 ,StudentZipCode = @StudentZipCode
	   Where StudentID = @@IDENTITY;
	Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
    Print Error_Message()
    Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes deletes into Students table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.
Create Procedure pDelStudents
 (@StudentID int)
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Delete from Students
	  Where StudentID = @StudentID;
    Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
	Print Error_Message()
	Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes insert into Courses table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.
Create Procedure pInsCourses
 (@CourseName nvarchar(100), @CourseStartDate date, @CourseEndDate date, @CoursePrice money)
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Tran
    Insert Into Courses
	(CourseName, CourseStartDate, CourseEndDate, CoursePrice)
	Values (@CourseName, @CourseStartDate, @CourseEndDate, @CoursePrice)
   Commit Tran
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Tran
   Print Error_Message()
   Set @RC = -1
  End Catch
 Return @RC;
End
go

-- Author: MaryVilloso
-- Desc: Processes updates into Courses table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.

Create Procedure pUpdCourses
 (@CourseID int, @CourseName nvarchar(100), @CourseStartDate date, @CourseEndDate date, @CoursePrice money)
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Update Courses
	  Set CourseName = @CourseName
		 ,CourseStartDate = @CourseStartDate  
		 ,CourseEndDate = @CourseEndDate
		 ,CoursePrice = @CoursePrice
	   Where CourseID = @@IDENTITY;
	Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
    Print Error_Message()
    Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes deletes into Courses table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.
Create Procedure pDelCourses
 (@CourseID int)
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Delete from Courses
	  Where CourseID = @CourseID;
    Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
	Print Error_Message()
	Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes insert into Enrollments table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.
Create Procedure pInsEnrollments
 (@EnrollmentDate date, @EnrollmentAmountPaid money, @StudentID int, @CourseID int)
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Tran
    Insert Into Enrollments
	(EnrollmentDate, EnrollmentAmountPaid, StudentID, CourseID)
	Values (@EnrollmentDate, @EnrollmentAmountPaid, @StudentID, @CourseID)
   Commit Tran
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Tran
   Print Error_Message()
   Set @RC = -1
  End Catch
 Return @RC;
End
go

-- Author: MaryVilloso
-- Desc: Processes updates into Enrollments table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.

Create Procedure pUpdEnrollments
 (@EnrollmentID int, @EnrollmentDate date, @EnrollmentAmountPaid money, @StudentID int, @CourseID int)
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Update Enrollments
	  Set EnrollmentDate = @EnrollmentDate
		 ,EnrollmentAmountPaid = @EnrollmentAmountPaid  
		 ,StudentID = @StudentID
		 ,CourseID = @CourseID
	   Where EnrollmentID = @@IDENTITY;
	Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
    Print Error_Message()
    Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes deletes into Enrollments table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.
Create Procedure pDelEnrollments
 (@EnrollmentID int)
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Delete from Enrollments
	  Where EnrollmentID = @EnrollmentID;
    Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
	Print Error_Message()
	Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes insert into Rooms table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.

Create Procedure pInsRooms
 (@RoomName nvarchar(100))
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Tran
    Insert Into Rooms (RoomName)
	Values  (@RoomName)
   Commit Tran
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Tran
   Print Error_Message()
   Set @RC = -1
  End Catch
 Return @RC;
End
go

-- Author: MaryVilloso
-- Desc: Processes updates into Rooms table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.

Create Procedure pUpdRooms
 (@RoomID int, @RoomName nvarchar(100))
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Update Rooms
	  Set RoomName = @RoomName
	   Where RoomID = @@IDENTITY;
	Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
    Print Error_Message()
    Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes deletes into Rooms table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.
Create Procedure pDelRooms
 (@RoomID int)
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Delete from Rooms
	  Where RoomID = @RoomID;
    Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
	Print Error_Message()
	Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes insert into CourseSessions table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.

Create Procedure pInsCourseSessions
 (@CourseSessionStartTime datetime, @CourseSessionEndTime datetime, @CourseID int, @RoomID int)
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Tran
    Insert Into CourseSessions
	(CourseSessionStartTime, CourseSessionEndTime, CourseID, RoomID)
	Values  (@CourseSessionStartTime, @CourseSessionEndTime, @CourseID, @RoomID)
   Commit Tran
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Tran
   Print Error_Message()
   Set @RC = -1
  End Catch
 Return @RC;
End
go

-- Author: MaryVilloso
-- Desc: Processes updates into CourseSessions table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.

Create Procedure pUpdCourseSessions
 (@CourseSessionID int, @CourseSessionStartTime datetime, @CourseSessionEndTime datetime, @CourseID int, @RoomID int)
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Update CourseSessions
	  Set CourseSessionStartTime = @CourseSessionStartTime
	     ,CourseSessionEndTime = @CourseSessionEndTime
		 ,CourseID = @CourseID
		 ,RoomID = @RoomID
	   Where CourseSessionID = @@IDENTITY;
	Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
    Print Error_Message()
    Set @RC = -1
   End Catch
   Return @RC;
 End
go

-- Author: MaryVilloso
-- Desc: Processes deletes into CourseSessions table
-- Change Log: When,Who,What
-- 2019-08-31,MaryVilloso,Created Sproc.
Create Procedure pDelCourseSessions
 (@CourseSessionID int)
AS
 Begin
  Declare @RC int = 0;
   Begin Try
    Begin Tran
	 Delete from CourseSessions
	  Where CourseSessionID = @CourseSessionID;
    Commit Tran
	Set @RC = +1
   End Try
   Begin Catch
    Rollback Tran
	Print Error_Message()
	Set @RC = -1
   End Catch
   Return @RC;
 End
go
-- Set Permissions --

--Permissions for Students Table
Deny 
Select, Insert, Update, Delete On Students
 To Public;
go
Grant 
Select On vStudents
 To Public;
go
Grant 
Exec On pInsStudents
 To Public;
go
Grant 
Exec On pUpdStudents
 To Public;
go
Grant
Exec On pDelStudents
 To Public;
go

-- Permissions for Enrollments Table
Deny 
Select, Insert, Update, Delete On Enrollments
 To Public;
go
Grant 
Select On vEnrollments
 To Public;
go
Grant 
Exec On pInsEnrollments
 To Public;
go
Grant 
Exec On pUpdEnrollments
 To Public;
go
Grant
Exec On pDelEnrollments
 To Public;
go

-- Permissions for Courses Table
Deny 
Select, Insert, Update, Delete On Courses
 To Public;
go
Grant 
Select On vCourses
 To Public;
go
Grant 
Exec On pInsCourses
 To Public;
go
Grant 
Exec On pUpdCourses
 To Public;
go
Grant
Exec On pDelCourses
 To Public;
go

-- Permissions for CourseSessions Table
Deny 
Select, Insert, Update, Delete On CourseSessions
 To Public;
go
Grant 
Select On vCourseSessions
 To Public;
go
Grant 
Exec On pInsCourseSessions
 To Public;
go
Grant 
Exec On pUpdCourseSessions
 To Public;
go
Grant
Exec On pDelCourseSessions
 To Public;
go

-- Permissions on Rooms Table
Deny 
Select, Insert, Update, Delete On Rooms
 To Public;
go
Grant 
Select On vRooms
 To Public;
go
Grant 
Exec On pInsRooms
 To Public;
go
Grant 
Exec On pUpdRooms
 To Public;
go
Grant
Exec On pDelRooms
 To Public;
go

--< Test Sprocs >-- 

-- TEST INSERT SPROCS
-- Test Insert [dbo].[pInsStudents]
Declare @Status int;
Exec @Status = pInsStudents
				@StudentFirstName = 'John'
			   ,@StudentLastName = 'Jackson'
			   ,@StudentNumber = 'J-Jackson-072'
			   ,@StudentEmail = 'JJackson@HopMail.com'
			   ,@StudentPhone = '(206)-464-8956'
			   ,@StudentAddress = '456 Madison St.'
			   ,@StudentCity = 'Seattle'
			   ,@StudentState = 'WA'
			   ,@StudentZipCode = '98001'
Select Case @Status
 When +1 Then 'Students Insert was successful!'
 When -1 Then 'Students Insert failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vStudents Where StudentID = @@IDENTITY;
go

-- Test Insert [dbo].[pInsCourses]
Declare @Status int;
Exec @Status = pInsCourses
				@CourseName = 'SQL3 - Spring 2018'
			   ,@CourseStartDate = '2018-04-02'
			   ,@CourseEndDate = '2018-04-16'
			   ,@CoursePrice = 399
Select Case @Status
 When +1 Then 'Courses Insert was successful!'
 When -1 Then 'Courses Insert failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vCourses Where CourseID = @@IDENTITY;
go

-- Test Insert [dbo].[pInsEnrollments]
Declare @Status int;
Exec @Status = pInsEnrollments
				@EnrollmentDate = '2018-03-26'
			   ,@EnrollmentAmountPaid = 399
			   ,@StudentID = 1
			   ,@CourseID = 1
Select Case @Status
 When +1 Then 'Enrollments Insert was successful!'
 When -1 Then 'Enrollments Insert failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vEnrollments Where EnrollmentID = @@IDENTITY;
go

--Test Insert [dbo].[pInsRooms]
Declare @Status int;
Exec @Status = pInsRooms
				@RoomName = 'C-205'
Select Case @Status
 When +1 Then 'Rooms Insert was successful!'
 When -1 Then 'Rooms Insert failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vRooms Where RoomID = @@IDENTITY;
go

--Test Insert [dbo].[pInsCourseSessions]
Declare @Status int;
Exec @Status = pInsCourseSessions
				@CourseSessionStartTime = '2018-04-02T06:00:00'
			   ,@CourseSessionEndTime = '2018-04-16T08:50:00'
			   ,@CourseID = 1
			   ,@RoomID = 1
Select Case @Status
 When +1 Then 'CourseSessions Insert was successful!'
 When -1 Then 'CourseSessions Insert failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vCourseSessions Where CourseSessionID = @@IDENTITY;
go

-- TEST UPDATE SPROCS
-- Test Update [dbo].[pUpdStudents]
Declare @Status int;
Exec @Status = pUpdStudents
			    @StudentID = 1
			   ,@StudentFirstName = 'John'
			   ,@StudentLastName = 'Jackson'
			   ,@StudentNumber = 'J-Jackson-072'
			   ,@StudentEmail = 'JJackson@HopMail.com'
			   ,@StudentPhone = '(808)-785-0934'
			   ,@StudentAddress = '456 Madison St.'
			   ,@StudentCity = 'Seattle'
			   ,@StudentState = 'WA'
			   ,@StudentZipCode = '98001'
Select Case @Status
 When +1 Then 'Students Update was successful!'
 When -1 Then 'Students Update failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vStudents Where StudentID = @@IDENTITY;
go

-- Test Update [dbo].[pUpdCourses]
Declare @Status int;
Exec @Status = pUpdCourses
			    @CourseID = 1
			   ,@CourseName = 'SQL3 - Spring 2018'
			   ,@CourseStartDate = '2018-04-02'
			   ,@CourseEndDate = '2018-04-16'
			   ,@CoursePrice = 370
Select Case @Status
 When +1 Then 'Courses Update was successful!'
 When -1 Then 'Courses Update failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vCourses Where CourseID = @@IDENTITY;
go

--Test Update [dbo].[pUpdEnrollments]
Declare @Status int;
Exec @Status = pUpdEnrollments
			    @EnrollmentID = 1
			   ,@EnrollmentDate = '2018-03-26'
			   ,@EnrollmentAmountPaid = 370
			   ,@StudentID = 1
			   ,@CourseID = 1
Select Case @Status
 When +1 Then 'Enrollments Update was successful!'
 When -1 Then 'Enrollments Update failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vEnrollments Where EnrollmentID = @@IDENTITY;
go

-- Test Update [dbo].[pUpdRooms]
Declare @Status int;
Exec @Status = pUpdRooms
			    @RoomID = 1
			   ,@RoomName = 'C-203'
Select Case @Status
 When +1 Then 'Rooms Update was successful!'
 When -1 Then 'Rooms Update failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vRooms Where RoomID = @@IDENTITY;
go

--Test Update [dbo].[pUpdCourseSessions]
Declare @Status int;
Exec @Status = pUpdCourseSessions
			    @CourseSessionID = 1
			   ,@CourseSessionStartTime = '2018-04-03T06:00:00'
			   ,@CourseSessionEndTime = '2018-04-22T08:50:00'
			   ,@CourseID = 1
			   ,@RoomID = 1
Select Case @Status
 When +1 Then 'CourseSessions Update was successful!'
 When -1 Then 'CourseSessions Update failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vCourseSessions Where CourseSessionID = @@IDENTITY;
go

-- TEST DELETE SPROCS
-- Test Delete [dbo].[dDelEnrollments]
Declare @Status int;
Exec @Status = pDelEnrollments
				@EnrollmentID = 1
Select Case @Status
 When +1 Then 'Enrollments Delete was successful!'
 When -1 Then 'Enrollments Delete failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vEnrollments Where EnrollmentID = @@IDENTITY
go

-- Test Delete [dbo].[pDelStudents]
Declare @Status int;
Exec @Status = pDelStudents
                @StudentID = 1
Select Case @Status
  When +1 Then 'Students Delete was successful!'
  When -1 Then 'Students Delete failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vStudents Where StudentID = @@IDENTITY;
go

--Test Delete [dbo].[pDelCourseSessions]
Declare @Status int;
Exec @Status = pDelCourseSessions
                @CourseSessionID = 1
Select Case @Status
  When +1 Then 'CourseSessions Delete was successful!'
  When -1 Then 'CourseSessions Delete failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCourseSessions Where CourseSessionID = @@IDENTITY;
go

-- Test Delete [dbo].[pDelCourses]
Declare @Status int;
Exec @Status = pDelCourses
				@CourseID = 1
Select Case @Status
 When +1 Then 'Courses Delete was successful!'
 When -1 Then 'Courses Delete failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vCourses Where CourseID = @@IDENTITY
go

-- Test Delete [dbp].[pDelRooms]
Declare @Status int;
Exec @Status = pDelRooms
				@RoomID = 1
Select Case @Status
 When +1 Then 'Rooms Delete was successful!'
 When -1 Then 'Rooms Delete failed! Common Issues: Duplicate Data'
 End as [Status];
Select * from vRooms Where RoomID = @@IDENTITY
go

--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/