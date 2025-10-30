/* ===== 0) Create and use a new clean database ===== */
IF DB_ID('University6') IS NOT NULL
    BEGIN
        ALTER DATABASE University6 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE University6;
    END;


CREATE DATABASE University6;
GO

USE University6;
GO

/* ===== 1) Simple example tables ===== test  */
CREATE TABLE dbo.Departments (
                                 DepartmentId INT IDENTITY(1,1) PRIMARY KEY,
                                 Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Students (
                              StudentId INT IDENTITY(1,1) PRIMARY KEY,
                              FullName NVARCHAR(100) NOT NULL,
                              DepartmentId INT NOT NULL
                                  CONSTRAINT FK_Students_Departments
                                      REFERENCES dbo.Departments(DepartmentId)
);

/* ===== 2) Insert sample data ===== */
INSERT INTO dbo.Departments (Name)
VALUES (N'Computer Science'), (N'Mathematics');

INSERT INTO dbo.Students (FullName, DepartmentId)
VALUES (N'Ana Ionescu', 1),
       (N'Mihai Georgescu', 1),
       (N'Ioana Dumitru', 2);

/* ===== 3) Test query ===== */
SELECT s.StudentId, s.FullName, d.Name AS Department
FROM dbo.Students s
         JOIN dbo.Departments d ON d.DepartmentId = s.DepartmentId
ORDER BY s.StudentId;
GO
