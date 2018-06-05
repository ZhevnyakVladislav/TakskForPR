USE Task_DB;

--Articles
GO
CREATE Or ALTER FUNCTION GetArticlesCreatedLater(
	@date DATETIME)
RETURNS TABLE
AS 
RETURN
	SELECT Articles.Title, Articles.Content, Blogs.Name, Users.Login
	FROM dbo.Articles
	JOIN Blogs on Articles.BlogId = Blogs.Id
	JOIN Users on Blogs.UserId = Users.Id
	JOIN Comments on  Blogs.UserId = Users.Id
	AND Articles.CreatedAt < GETDATE();
