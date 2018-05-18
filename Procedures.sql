USE Task_DB

--Users

GO
CREATE OR ALTER PROCEDURE CreateUser
	(@Name VARCHAR(50),
    @Login VARCHAR(50),
    @Password VARCHAR(50),
    @Email VARCHAR(50))
AS 
BEGIN
    INSERT INTO dbo.Users 
	(Name, Login, Password, Email) 
	VALUES (@Name, @Login, @Password, @Email)	
END

--Blogs

GO
CREATE OR ALTER PROCEDURE CreateBlog
	(@Name VARCHAR(50),
	@UserId INT)
AS
BEGIN
	INSERT INTO dbo.Blogs 
	(Name, UserId)
	VALUES (@Name, @UserId)
END

GO
CREATE OR ALTER PROCEDURE PayBlog
	(@BlogId INT)
AS
BEGIN
	UPDATE dbo.Blogs SET IsPaid = 1 WHERE Id = @BlogId
END

GO
CREATE OR ALTER PROCEDURE CheckBlogForPaid
	(@articleId int)
AS
BEGIN
	DECLARE @count INT;
	DECLARE @blogId INT;
    DECLARE @blogIsPaid BIT;
	SELECT @blogId = BlogId FROM dbo.Articles WHERE Id = @articleId;
	SELECT @count = COUNT(Id) FROM dbo.Articles WHERE BlogId = @blogId;
    SELECT @blogIsPaid = IsPaid FROM dbo.Blogs WHERE Id = @blogId
	IF( @blogIsPaid = 0 OR @count > 100)
		BEGIN
			UPDATE dbo.Articles
			SET IsBlocked = 0
			WHERE Id = @articleId
		ENd
	ELSE
		BEGIN
			UPDATE dbo.Articles
			SET IsBlocked = 1
			WHERE Id = @articleId
		END
END

--Atricles

GO
CREATE OR ALTER PROCEDURE CreateArticle
	(@BlogId INT,
	@Title VARCHAR(50),
	@Content TEXT)
AS
BEGIN
	INSERT INTO dbo.Articles 
	(BlogId, Title, Content)
	VALUES (@BlogId, @Title, @Content)
END