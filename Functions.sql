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
	WHERE viewArticles.CreatedAt < @specialDate
	
	
GO
CREATE OR ALTER FUNCTION GetArticlesCount
	(@blogId INT)
RETURNS INT
BEGIN
   DECLARE @count INT;

   SELECT @count = COUNT(*) FROM dbo.Articles WHERE BlogId = @BlogId;

   RETURN @count;
END
	
GO
CREATE OR ALTER FUNCTION GetFreeArticlesCount
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
