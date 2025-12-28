CREATE PROCEDURE SendBasicIndexMetadataEmail
    @RecipientEmail NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @HTML NVARCHAR(MAX);

    SET @HTML = N'
    <html>
    <head>
        <style>
            table { border-collapse: collapse; width: 100%; }
            th { background-color: #4CAF50; color: white; padding: 10px; }
            td { padding: 8px; border: 1px solid #ddd; }
            tr:nth-child(even) { background-color: #f2f2f2; }
        </style>
    </head>
    <body>
        <h2>Index Metadata Report</h2>
        <table>
            <tr>
                <th>Table Name</th>
                <th>Index Name</th>
                <th>Index Type</th>
                <th>Column Type</th>
            </tr>';

    SELECT @HTML = @HTML + CAST((
        SELECT 
            td = OBJECT_SCHEMA_NAME(t.object_id) + '.' + t.name,
            td = i.name,
            td = CASE i.type
                    WHEN 1 THEN 'CLUSTERED'
                    WHEN 2 THEN 'NONCLUSTERED'
                    WHEN 3 THEN 'XML'
                    WHEN 4 THEN 'SPATIAL'
                    WHEN 5 THEN 'COLUMNSTORE'
                    ELSE 'OTHER'
                 END,
            td = STUFF((
                SELECT ', ' + c.name + 
                       CASE WHEN ic.is_included_column = 1 THEN ' (INCLUDED)' ELSE '' END
                FROM sys.index_columns ic
                JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
                WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
                ORDER BY ic.key_ordinal
                FOR XML PATH('')
            ), 1, 2, '')
        FROM sys.tables t
        JOIN sys.indexes i ON t.object_id = i.object_id
        WHERE t.is_ms_shipped = 0
          AND i.type > 0
        ORDER BY OBJECT_SCHEMA_NAME(t.object_id), t.name, i.name
        FOR XML PATH('tr'), TYPE
    ) AS NVARCHAR(MAX));
    
    SET @HTML += N'
        </table>
        <p><i>Generated on ' + CONVERT(NVARCHAR, GETDATE(), 120) + '</i></p>
    </body>
    </html>';

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = NULL,
        @recipients = @RecipientEmail,
        @subject = 'Index Metadata Report',
        @body = @HTML,
        @body_format = 'HTML';
END;
GO