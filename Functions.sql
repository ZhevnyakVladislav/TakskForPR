USE Task_DB;

--Articles
GO
CREATE OR ALTER FUNCTION GetArticlesCreatedLater
	(@specialDate DATETIME)
RETURNS TABLE
AS 
RETURN
	SELECT *
	FROM viewArticles
	WHERE viewArticles.CreatedAt > @specialDate
	
	
GO
CREATE OR ALTER FUNCTION GetArticlesCount
	(@blogId INT)
RETURNS INT
BEGIN
	DECLARE @count INT;

	SELECT @count = COUNT(*) FROM dbo.Articles 
		WHERE BlogId = @BlogId;

	RETURN @count;
END
	
GO
CREATE OR ALTER FUNCTION GetFreeUserArticlesCount
	(@blogId INT)
RETURNS INT  
AS   
BEGIN  
	DECLARE @count INT;

	SELECT @count = COUNT(*) FROM dbo.Articles 
		WHERE BlogId IN (
			SELECT Id FROM dbo.Blogs 
				WHERE IsPaid = 0 AND UserId = (
					SELECT UserId from dbo.Blogs
						Where Blogs.Id = @blogId));

	RETURN @count;
END;  

GO
CREATE OR ALTER FUNCTION GetFreeBlogArticlesCount
	(@blogId INT)
RETURNS INT  
AS   
BEGIN  
	DECLARE @count INT;

	SELECT @count = COUNT(*) FROM dbo.Articles 
		WHERE BlogId = @blogId;

	RETURN @count;
END;

GO
CREATE OR ALTER FUNCTION GetCurrentlevel()
	RETURNS TABLE
AS 
RETURN
	SELECT CASE transaction_isolation_level 
	WHEN 0 THEN 'Unspecified' 
	WHEN 1 THEN 'ReadUncommitted' 
	WHEN 2 THEN 'ReadCommitted' 
	WHEN 3 THEN 'Repeatable' 
	WHEN 4 THEN 'Serializable' 
	WHEN 5 THEN 'Snapshot' END AS TRANSACTION_ISOLATION_LEVEL 
	FROM sys.dm_exec_sessions 
	where session_id = @@SPID