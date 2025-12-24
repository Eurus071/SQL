-- TASK 1
DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
WITH DatabaseList AS (
    -- Get all non-system databases
    SELECT name
    FROM sys.databases
    WHERE database_id > 4 -- Exclude system databases (master=1, tempdb=2, model=3, msdb=4)
      AND state = 0 -- Only online databases
)
SELECT DISTINCT
    DB_NAME() AS DatabaseName,
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    CASE 
        WHEN ty.name IN (''varchar'', ''nvarchar'', ''char'', ''nchar'') 
            THEN CAST(c.max_length AS VARCHAR(10))
        WHEN ty.name IN (''decimal'', ''numeric'')
            THEN CAST(c.precision AS VARCHAR(5)) + '', '' + CAST(c.scale AS VARCHAR(5))
        WHEN ty.name IN (''datetime2'', ''datetimeoffset'', ''time'')
            THEN CAST(c.scale AS VARCHAR(5))
        ELSE NULL
    END AS TypeDetails,
    CASE 
        WHEN c.is_nullable = 1 THEN ''YES''
        ELSE ''NO''
    END AS IsNullable
FROM sys.schemas s
INNER JOIN sys.tables t ON s.schema_id = t.schema_id
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE t.is_ms_shipped = 0 -- Exclude system tables
ORDER BY DatabaseName, SchemaName, TableName, c.column_id;
';

CREATE TABLE #SchemaInfo (
    DatabaseName NVARCHAR(128),
    SchemaName NVARCHAR(128),
    TableName NVARCHAR(128),
    ColumnName NVARCHAR(128),
    DataType NVARCHAR(128),
    TypeDetails NVARCHAR(50),
    IsNullable CHAR(3)
);

DECLARE @dbName NVARCHAR(128);
DECLARE @dbSQL NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
SELECT name FROM sys.databases 
WHERE database_id > 4 AND state = 0;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @dbSQL = N'USE [' + @dbName + N']; ' + @SQL;
    
    INSERT INTO #SchemaInfo
    EXEC sp_executesql @dbSQL;
    
    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;


SELECT * FROM #SchemaInfo
ORDER BY DatabaseName, SchemaName, TableName, ColumnName;



--TASK 2
CREATE PROCEDURE GetStoredProceduresAndFunctions
    @DatabaseName NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
 
    CREATE TABLE #ProcedureFunctionInfo (
        DatabaseName NVARCHAR(128),
        ObjectSchema NVARCHAR(128),
        ObjectName NVARCHAR(128),
        ObjectType NVARCHAR(60),
        ParameterName NVARCHAR(128),
        ParameterDataType NVARCHAR(128),
        MaxLength INT,
        [Precision] TINYINT,
        Scale TINYINT,
        IsOutput BIT,
        HasDefaultValue BIT,
        ParameterOrder INT
    );
    
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    -- Get stored procedures with parameters
    SELECT 
        DB_NAME() AS DatabaseName,
        SCHEMA_NAME(p.schema_id) AS ObjectSchema,
        p.name AS ObjectName,
        ''STORED PROCEDURE'' AS ObjectType,
        pr.name AS ParameterName,
        t.name AS ParameterDataType,
        pr.max_length AS MaxLength,
        pr.precision,
        pr.scale,
        pr.is_output AS IsOutput,
        CASE WHEN pr.has_default_value = 1 THEN 1 ELSE 0 END AS HasDefaultValue,
        pr.parameter_id AS ParameterOrder
    FROM sys.procedures p
    LEFT JOIN sys.parameters pr ON p.object_id = pr.object_id
    LEFT JOIN sys.types t ON pr.user_type_id = t.user_type_id
    WHERE p.is_ms_shipped = 0
    
    UNION ALL
    
    -- Get scalar functions with parameters
    SELECT 
        DB_NAME() AS DatabaseName,
        SCHEMA_NAME(o.schema_id) AS ObjectSchema,
        o.name AS ObjectName,
        ''SCALAR FUNCTION'' AS ObjectType,
        p.name AS ParameterName,
        t.name AS ParameterDataType,
        p.max_length AS MaxLength,
        p.precision,
        p.scale,
        p.is_output AS IsOutput,
        CASE WHEN p.has_default_value = 1 THEN 1 ELSE 0 END AS HasDefaultValue,
        p.parameter_id AS ParameterOrder
    FROM sys.objects o
    INNER JOIN sys.parameters p ON o.object_id = p.object_id
    INNER JOIN sys.types t ON p.user_type_id = t.user_type_id
    WHERE o.type IN (''FN'', ''IF'', ''TF'') -- Scalar, inline table-valued, table-valued functions
      AND o.is_ms_shipped = 0
    
    UNION ALL
    
    -- Get objects without parameters (still need to show them)
    SELECT 
        DB_NAME() AS DatabaseName,
        SCHEMA_NAME(p.schema_id) AS ObjectSchema,
        p.name AS ObjectName,
        CASE 
            WHEN p.type = ''P'' THEN ''STORED PROCEDURE''
            WHEN p.type = ''FN'' THEN ''SCALAR FUNCTION''
            WHEN p.type IN (''IF'', ''TF'') THEN ''TABLE-VALUED FUNCTION''
            ELSE ''UNKNOWN''
        END AS ObjectType,
        NULL AS ParameterName,
        NULL AS ParameterDataType,
        NULL AS MaxLength,
        NULL AS [Precision],
        NULL AS Scale,
        NULL AS IsOutput,
        NULL AS HasDefaultValue,
        NULL AS ParameterOrder
    FROM sys.objects p
    WHERE p.type IN (''P'', ''FN'', ''IF'', ''TF'')
      AND p.is_ms_shipped = 0
      AND NOT EXISTS (
          SELECT 1 
          FROM sys.parameters pr 
          WHERE pr.object_id = p.object_id
      )
    ORDER BY DatabaseName, ObjectSchema, ObjectName, ParameterOrder;
    ';
    
    DECLARE @dbName NVARCHAR(128);
    DECLARE @dbSQL NVARCHAR(MAX);
    
    IF @DatabaseName IS NOT NULL
    BEGIN

        IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName AND state = 0)
        BEGIN
            SET @dbSQL = N'USE [' + @DatabaseName + N']; ' + @SQL;
            
            INSERT INTO #ProcedureFunctionInfo
            EXEC sp_executesql @dbSQL;
        END
        ELSE
        BEGIN
            RAISERROR('Database "%s" does not exist or is not online.', 16, 1, @DatabaseName);
            RETURN;
        END
    END
    ELSE
    BEGIN

        DECLARE db_cursor CURSOR FOR
        SELECT name FROM sys.databases 
        WHERE database_id > 4 AND state = 0; 
        
        OPEN db_cursor;
        FETCH NEXT FROM db_cursor INTO @dbName;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @dbSQL = N'USE [' + @dbName + N']; ' + @SQL;
            
            BEGIN TRY
                INSERT INTO #ProcedureFunctionInfo
                EXEC sp_executesql @dbSQL;
            END TRY
            BEGIN CATCH

                PRINT 'Skipping database ' + @dbName + ': ' + ERROR_MESSAGE();
            END CATCH
            
            FETCH NEXT FROM db_cursor INTO @dbName;
        END
        
        CLOSE db_cursor;
        DEALLOCATE db_cursor;
    END

    SELECT 
        DatabaseName,
        ObjectSchema,
        ObjectName,
        ObjectType,
        ParameterName,
        ParameterDataType,
        CASE 
            WHEN ParameterDataType IN ('varchar', 'nvarchar', 'char', 'nchar') 
                THEN CAST(MaxLength AS NVARCHAR(20))
            WHEN ParameterDataType IN ('decimal', 'numeric')
                THEN CAST([Precision] AS NVARCHAR(5)) + ', ' + CAST(Scale AS NVARCHAR(5))
            WHEN MaxLength = -1 THEN 'MAX'
            ELSE CAST(MaxLength AS NVARCHAR(20))
        END AS MaxLengthDetails,
        CASE WHEN IsOutput = 1 THEN 'YES' ELSE 'NO' END AS IsOutputParameter,
        CASE WHEN HasDefaultValue = 1 THEN 'YES' ELSE 'NO' END AS HasDefaultValue,
        ParameterOrder
    FROM #ProcedureFunctionInfo
    ORDER BY DatabaseName, ObjectSchema, ObjectName, 
             CASE WHEN ParameterOrder IS NULL THEN 1 ELSE 0 END, 
             ParameterOrder;
 