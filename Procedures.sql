USE Task_DB

--Users

GO
CREATE OR ALTER PROCEDURE CreateUser
	(@Name VARCHAR(50),
    @Login VARCHAR(50),
    @Password VARCHAR(50),
    @Email VARCHAR(50))
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRAN
	SET NOCOUNT ON;

    INSERT INTO dbo.Users 
	(Name, Login, Password, Email)
	VALUES (@Name, @Login, @Password, @Email)

IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK
		PRINT 'User was not created'
	END
ELSE
	BEGIN
		COMMIT
		RETURN SCOPE_IDENTITY();
	END

--Blogs

GO
CREATE OR ALTER PROCEDURE CreateBlog
	(@Name VARCHAR(50),
	 @UserId INT)
AS
BEGIN TRAN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	INSERT INTO dbo.Blogs 
	(Name, UserId, IsPaid)
	VALUES (@Name, @UserId, 0);
IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK
		PRINT 'Blog was not created'
	END
ELSE
	BEGIN
		COMMIT
		RETURN SCOPE_IDENTITY();
	END

GO
CREATE OR ALTER PROCEDURE PayBlog
	(@BlogId INT)
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN
	SET NOCOUNT ON;

	UPDATE dbo.Blogs SET IsPaid = 1 WHERE Id = @BlogId;

IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK
		PRINT 'Blog was not payed'
	END
ELSE
	BEGIN
		COMMIT
		RETURN SCOPE_IDENTITY();
	END

--Atricles

GO
CREATE OR ALTER PROCEDURE CreateArticle
	(@BlogId INT,
	 @Title VARCHAR(50),
	 @Content TEXT)
AS
BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @IsArticleBlocked BIT = 0;

	IF((SELECT IsPaid FROM Blogs WHERE Id = @BlogId) = 0)
		IF (dbo.GetFreeUserArticlesCount(@BlogId) >= 7) --value should be 1000
			BEGIN
				ROLLBACK
				PRINT 'Can not to insert one more free article! Please, pay the blog!'
			END
		ELSE IF (dbo.GetFreeBlogArticlesCount(@BlogId) >= 5)
			SET @IsArticleBlocked = 1;
		
	INSERT INTO dbo.Articles 
	(BlogId, Title, Content, IsBlocked)
	VALUES (@BlogId, @Title, @Content, @IsArticleBlocked)

IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK
		PRINT 'Blog was not payed'
	END
ELSE
	BEGIN
		COMMIT
		RETURN SCOPE_IDENTITY();
	END

GO
CREATE OR ALTER PROCEDURE UnlockActicles
	(@blogId INT)
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN
	SET NOCOUNT ON;
	UPDATE dbo.Articles SET IsBlocked = 0 WHERE BlogId = @blogId AND IsBlocked = 1;

IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK
		PRINT 'Blog was not payed'
	END
ELSE
	BEGIN
		COMMIT
		RETURN SCOPE_IDENTITY();
	END

GO
CREATE OR ALTER PROCEDURE RateArticle
	(@articleId INT,
	 @userId INT,
	 @mark INT)
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN
	SET NOCOUNT ON;
		
	IF NOT EXISTS(SELECT * from dbo.ArticleRating WHERE UserId = @userId)
		INSERT INTO dbo.ArticleRating
		(ArticleId, UserId, Mark)
		VALUES (@articleId, @userId, @mark);
	ELSE
		UPDATE dbo.ArticleRating 
		SET Mark = @mark 
		WHERE ArticleId = @articleId AND UserId = @userId
	
	EXEC UpdateArticleAverageRating @articleId;

IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK
		PRINT 'Article was not rated'
	END
ELSE
	COMMIT

GO
CREATE OR ALTER PROCEDURE UpdateArticleAverageRating
	(@articleId INT)
AS
BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @rating FLOAT;

	SELECT @rating = AVG(CAST(Mark as FLOAT)) FROM dbo.ArticleRating WHERE ArticleId = @articleId;
	UPDATE dbo.Articles SET AverageRating = @rating WHERE Id = @articleId

IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK
		PRINT 'Article was not rated'
	END
ELSE
	COMMIT

GO
CREATE OR ALTER PROCEDURE CommentArticle
	(@articleId INT,
	 @userId INT,
	 @comment TEXT)
AS
BEGIN TRAN
	SET NOCOUNT ON;
	
	INSERT INTO dbo.Comments
	(ArticleId, UserId, Coment)
	VALUES (@articleId, @userId, @comment)

IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK
		PRINT 'Comment was not created'
	END
ELSE
	COMMIT


--Common

GO
CREATE OR ALTER PROCEDURE SetCreatedAt
	(@tableName VARCHAR(20),
	@Id INT)
AS
BEGIN TRAN
	DECLARE @Cmd nvarchar(150) = N'UPDATE' + QUOTENAME(@tableName) + 'SET CreatedAt = GETDATE() WHERE Id = ' + CAST(@Id as VARCHAR);;
	EXEC sp_executeSQL @Cmd,  N'@tableName VARCHAR(20), @Id INT', @tableName, @Id;
IF(@@ERROR <> 0 )
	ROLLBACK
ELSE
	COMMIT

GO
CREATE OR ALTER PROCEDURE SetUpdatedAt
	(@tableName VARCHAR(20),
	@Id INT)
AS
BEGIN TRAN
	DECLARE @Cmd nvarchar(150) = N'UPDATE' + QUOTENAME(@tableName) + 'SET UpdatedAt = GETDATE() WHERE Id = ' + CAST(@Id as VARCHAR);
	EXEC sp_executeSQL @Cmd,  N'@tableName VARCHAR(20), @Id INT', @tableName, @Id;
IF(@@ERROR <> 0 )
	ROLLBACK
ELSE
	COMMIT