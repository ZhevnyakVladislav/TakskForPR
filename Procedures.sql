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
	SET NOCOUNT ON;
    INSERT INTO dbo.Users (
	Name, Login, Password, Email)
	VALUES (@Name, @Login, @Password, @Email)
	RETURN SCOPE_IDENTITY();	
END

--Blogs

GO
CREATE OR ALTER PROCEDURE CreateBlog
	(@Name VARCHAR(50),
	@UserId INT)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.Blogs 
	(Name, UserId, IsPaid)
	VALUES (@Name, @UserId, 0);

	RETURN SCOPE_IDENTITY();
END

GO
CREATE OR ALTER PROCEDURE PayBlog
	(@BlogId INT)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.Blogs SET IsPaid = 1 WHERE Id = @BlogId;
	UPDATE dbo.Articles SET IsBlocked = 0 WHERE BlogId = @BlogId AND IsBlocked = 1;
END

--Atricles

GO
CREATE OR ALTER PROCEDURE CreateArticle
	(@BlogId INT,
	@Title VARCHAR(50),
	@Content TEXT)
AS
BEGIN
	SET NOCOUNT ON;

	IF (dbo.GetFreedArticlesCount(@BlogId) >= 5) --value should be 1000
		--ROLLBACK do not work

	DECLARE @IsBlogPaid BIT;
	DECLARE @count INT;
	DECLARE @IsArticleBlocked BIT = 0;
	
	SELECT @IsBlogPaid = IsPaid FROM dbo.Blogs WHERE Id = @BlogId;
	SELECT @count = dbo.GetArticlesCount(@BlogId);
	
	IF(@IsBlogPaid = 0)
		IF(@count >= 4) --value should be 100
			SET @IsArticleBlocked = 1;
		
	INSERT INTO dbo.Articles 
	(BlogId, Title, Content, IsBlocked)
	VALUES (@BlogId, @Title, @Content, @IsArticleBlocked)

	RETURN SCOPE_IDENTITY();
END

GO
CREATE OR ALTER PROCEDURE RateArticle
	(@articleId INT,
	 @userId INT,
	 @mark INT)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ArticleRating
	(ArticleId, UserId, Mark)
	VALUES (@articleId, @userId, @mark);
END

GO
CREATE OR ALTER PROCEDURE UpdateArticleAverageRating
	(@articleId INT)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @rating FLOAT;

	SELECT @rating = AVG(CAST(Mark as FLOAT)) FROM dbo.ArticleRating WHERE ArticleId = @articleId;
	UPDATE dbo.Articles SET AverageRaing = @rating WHERE Id = @articleId
END

GO
CREATE OR ALTER PROCEDURE CheckArticleCount
	(@articleId INT)
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @BlogId INT
	DECLARE @ArticleCount INT;
	SELECT @BlogId = BlogId FROM dbo.Articles WHERE Id = @articleId;
	SELECT @ArticleCount = dbo.GetArticlesCount(@BlogId);

	IF (@ArticleCount > 5)
		ROLLBACK
END


--Common

GO
CREATE OR ALTER PROCEDURE SetCreatedAt
	(@tableName VARCHAR(20),
	@Id INT)
AS
BEGIN
	DECLARE @Cmd nvarchar(150) = N'UPDATE' + QUOTENAME(@tableName) + 'SET CreatedAt = GETDATE() WHERE Id = ' + CAST(@Id as VARCHAR);;
	EXEC sp_executeSQL @Cmd,  N'@tableName VARCHAR(20), @Id INT', @tableName, @Id;

END

GO
CREATE OR ALTER PROCEDURE SetUpdatedAt
	(@tableName VARCHAR(20),
	@Id INT)
AS
BEGIN
	DECLARE @Cmd nvarchar(150) = N'UPDATE' + QUOTENAME(@tableName) + 'SET UpdatedAt = GETDATE() WHERE Id = ' + CAST(@Id as VARCHAR);
	EXEC sp_executeSQL @Cmd,  N'@tableName VARCHAR(20), @Id INT', @tableName, @Id;
END