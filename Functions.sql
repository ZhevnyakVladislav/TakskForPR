USE Task_DB;

--Articles
GO
CREATE OR ALTER FUNCTION GetArticlesCreatedLater
	(@date DATETIME)
RETURNS TABLE
AS 
RETURN
	SELECT Articles.Title, Articles.Content, Blogs.Name, Users.Login
	FROM dbo.Articles
	JOIN Blogs on Articles.BlogId = Blogs.Id
	JOIN Users on Blogs.UserId = Users.Id
	AND Articles.CreatedAt < @date;
	
GO
CREATE OR ALTER FUNCTION GetFreedArticlesCount
	(@blogId INT)
RETURNS INT
BEGIN
   DECLARE @count INT;
   SELECT @count = COUNT(*) FROM dbo.Articles WHERE BlogId = @BlogId;
   RETURN @count;
END
	
GO
CREATE OR ALTER FUNCTION GetFreedArticlesCount
	(@blogId INT)
RETURNS INT  
AS   
BEGIN  
   DECLARE @count INT;
   SELECT @count = COUNT(*) FROM dbo.Articles
   JOIN Blogs ON Articles.BlogId = Blogs.Id
   JOIN Users ON Blogs.UserId = Users.Id
   WHERE BlogId = @blogId AND Blogs.IsPaid = 0;
   RETURN @count;
END;  
