# sql-object-search
This procedure will search object definitions across all databases on a server for a referenced object specified in the procedure parameters. 

You can search for any object such as a table, view, procedure, function, etc... and return the definition of the view, procedure, function, foreign key, etc... that is referencing it.

Input parameters:
@searchObjSchema NVARCHAR(255): the schema of the object 
@searchObj NVARCHAR(255): the name of the object

EXEC   [dbo].[ServerwideObjectSearch]
              @searchObjSchema = N'dbo',
              @searchObj = N'customers'

The results include the servername, db name, object name being searched for , object name found, object type found, and the object definition. 
