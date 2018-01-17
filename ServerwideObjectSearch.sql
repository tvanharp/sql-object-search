CREATE PROC [dbo].[ServerwideObjectSearch]
  @searchObjSchema NVARCHAR(255)
 ,@searchObj NVARCHAR(255)
AS
  CREATE TABLE #SearchTerm
    (
     SearchSchema NVARCHAR(255)
    ,SearchObj NVARCHAR(255)
    );
  INSERT  INTO #SearchTerm
          (SearchSchema, SearchObj)
  VALUES
          (@searchObjSchema, @searchObj);


  CREATE TABLE #SearchResult
    (
     Servername sysname
    ,DBName sysname
    ,SearchTerm NVARCHAR(512)
    ,ObjName sysname
    ,ObjType NVARCHAR(60)
    ,ObjDefinition NVARCHAR(MAX)
    );

  EXEC sp_MSforeachdb 'USE [?] DECLARE @searchObjSchema NVARCHAR(255) = (
                                            SELECT SearchSchema
                                              FROM #SearchTerm
                                           );
  DECLARE @searchObj NVARCHAR(255) = (
                                      SELECT SearchObj FROM #SearchTerm
                                     );

  DECLARE @find NVARCHAR(512) = @searchObjSchema + ''.'' + @searchObj;

  DECLARE
    @objid INT
   ,@objname sysname
   ,@objType NVARCHAR(60);

  DECLARE c CURSOR
  FOR
    SELECT
      o.object_id
     ,o.name
     ,o.type_desc
    FROM
      sys.objects o
    WHERE
      o.type IN (''AF'', ''C'', ''D'', ''F'', ''FN'', ''FS'', ''FT'', ''IF'', ''P'', ''PC'',
                 ''PG'', ''V'');

  OPEN c;
  FETCH NEXT FROM c INTO @objid, @objname, @objType;
  WHILE @@FETCH_STATUS = 0
    BEGIN

      INSERT  INTO #SearchResult
              (Servername
              ,DBName
              ,SearchTerm
              ,ObjName
              ,ObjType
              ,ObjDefinition)
      SELECT
        @@SERVERNAME
       ,DB_NAME()
       ,@find
       ,@objname
       ,@objType
       ,OBJECT_DEFINITION(@objid);

      FETCH NEXT FROM c INTO @objid, @objname, @objType;

    END;

  CLOSE c;
  DEALLOCATE c;';


  DECLARE @find NVARCHAR(512) = @searchObjSchema + '.' + @searchObj;
  DECLARE @findSQB NVARCHAR(512) = '\[' + @searchObjSchema + '\].\[' + @searchObj + '\]';

  SELECT
    *
  FROM
    #SearchResult sr
  WHERE
    sr.ObjDefinition LIKE '%' + @find + '%' OR sr.ObjDefinition LIKE '%' + @findSQB + '%' ESCAPE '\';

  DROP TABLE #SearchTerm;
  DROP TABLE #SearchResult;
