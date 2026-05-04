CREATE DATABASE EventSourcingDB;

USE EventSourcingDB;

CREATE SCHEMA [Archive]; -- Arxiv jadvallari uchun alohida schema


CREATE TABLE Users25 (
  UserID INT PRIMARY KEY IDENTITY(1,1),
  FullName NVARCHAR(100) NOT NULL,
  Email NVARCHAR(100) NOT NULL,
  Balance DECIMAL(18, 2) DEFAULT 0,
  SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
  PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Archive].Users25History));



CREATE TABLE [Archive].AuditLogs25 (
  LogID INT PRIMARY KEY IDENTITY(1,1),
  TableName NVARCHAR(50),
  Operation NVARCHAR(10),
  OldData NVARCHAR(MAX), 
  ChangedBy NVARCHAR(100),
  ChangedDate DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_Users_Audit25
ON Users
AFTER UPDATE, DELETE
AS
BEGIN
DECLARE @OldDataJSON NVARCHAR(MAX);

SET @OldDataJSON = (SELECT * FROM deleted FOR JSON AUTO);

INSERT INTO [Archive].AuditLogs (TableName, Operation, OldData, ChangedBy)
VALUES ('Users', 
          CASE WHEN EXISTS(SELECT * FROM inserted) THEN 'UPDATE' ELSE 'DELETE' END, 
          @OldDataJSON, 
          SUSER_SNAME());
END;
CREATE PROCEDURE sp_GetUserAtTime
  @TargetTime DATETIME2
AS
BEGIN
  SELECT * FROM Users
  FOR SYSTEM_TIME AS OF @TargetTime;
END;
GO


