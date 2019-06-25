SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG='Inventory'
GO

USE inventory
GO

CREATE TABLE servers (
    computername NVARCHAR(100) NOT NULL,
    biosserial NVARCHAR(100) NULL,
    manufacturer NVARCHAR(100) NULL,
    model NVARCHAR(100) NULL,
    osname NVARCHAR(100) NULL,
    osversion NVARCHAR(100) NULL,
    spversion NVARCHAR(10) NULL,
    totalram NVARCHAR(20) NULL,
    processors NVARCHAR(20) NULL,
    lprocessors NVARCHAR(40) NULL,
    CONSTRAINT systems_pk PRIMARY KEY (computername)
);

EXEC sp_help servers;