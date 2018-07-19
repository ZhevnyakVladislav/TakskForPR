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

    INSERT INTO dbo.Users 
	(Name, Login, Password, Email)
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
	DECLARE @IsArticleBlocked BIT = 0;

	IF((SELECT IsPaid FROM Blogs WHERE Id = @BlogId) = 0)
		IF (dbo.GetFreeArticlesCount(@BlogId) >= 5) --value should be 1000 follow the requi
			BEGIN
				DECLARE @fd INT;
				--ROLLBACK
			END
		ELSE
			BEGIN
				DECLARE @fdefa INT;
				SET @IsArticleBlocked = 1;
			END 
		
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
		
	IF NOT EXISTS(SELECT * from dbo.ArticleRating WHERE UserId = @userId)
		BEGIN
			INSERT INTO dbo.ArticleRating
			(ArticleId, UserId, Mark)
			VALUES (@articleId, @userId, @mark);
		END
	ELSE
		BEGIN
			UPDATE dbo.ArticleRating 
			SET Mark = @mark 
			WHERE ArticleId = @articleId AND UserId = @userId
		END
	EXEC UpdateArticleAverageRating @articleId;
END

GO
CREATE OR ALTER PROCEDURE UpdateArticleAverageRating
	(@articleId INT)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @rating FLOAT;

	SELECT @rating = AVG(CAST(Mark as FLOAT)) FROM dbo.ArticleRating WHERE ArticleId = @articleId;
	UPDATE dbo.Articles SET AverageRating = @rating WHERE Id = @articleId
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

GO
CREATE OR ALTER PROCEDURE CommentArticle
	(@articleId INT,
	 @userId INT,
	 @comment TEXT)
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO dbo.Comments
	(ArticleId, UserId, Coment)
	VALUES (@articleId, @userId, @comment)
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