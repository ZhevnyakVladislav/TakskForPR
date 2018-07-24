USE Task_DB

--Common

GO
CREATE OR ALTER PROCEDURE HandleError
AS 
BEGIN
	DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;
	SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();
	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END

GO
CREATE OR ALTER PROCEDURE SetCreatedAt
	(@tableName VARCHAR(20),
	@Id INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @Cmd nvarchar(150) = N'UPDATE' + QUOTENAME(@tableName) + 'SET CreatedAt = GETDATE() WHERE Id = ' + CAST(@Id as VARCHAR);;
	EXEC sp_executeSQL @Cmd,  N'@tableName VARCHAR(20), @Id INT', @tableName, @Id;
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError;
END CATCH

GO
CREATE OR ALTER PROCEDURE SetUpdatedAt
	(@tableName VARCHAR(20),
	@Id INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @Cmd nvarchar(150) = N'UPDATE' + QUOTENAME(@tableName) + 'SET UpdatedAt = GETDATE() WHERE Id = ' + CAST(@Id as VARCHAR);

	EXEC sp_executeSQL @Cmd,  N'@tableName VARCHAR(20), @Id INT', @tableName, @Id;
	
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError;
END CATCH

--Atricles

GO
CREATE OR ALTER PROCEDURE CreateArticle
	(@BlogId INT,
	 @Title VARCHAR(50),
	 @Content TEXT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @IsArticleBlocked BIT = 0;
	
	IF((SELECT IsPaid FROM Blogs WHERE Id = @BlogId) = 0)
		IF (dbo.GetFreeUserArticlesCount(@BlogId) >= 1000)
		BEGIN
			RAISERROR ('Error! User must not have more that 1000 free articles', 16,1);
		END
		ELSE IF (dbo.GetFreeBlogArticlesCount(@BlogId) >= 100)
			SET @IsArticleBlocked = 1;
		
	INSERT INTO dbo.Articles 
	(BlogId, Title, Content, IsBlocked)
	VALUES (@BlogId, @Title, @Content, @IsArticleBlocked)

	COMMIT;
	RETURN SCOPE_IDENTITY();
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

GO
CREATE OR ALTER PROCEDURE UnlockActicles
	(@blogId INT)
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;

	UPDATE dbo.Articles SET IsBlocked = 0 WHERE BlogId = @blogId AND IsBlocked = 1;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

GO
CREATE OR ALTER PROCEDURE UpdateArticleAverageRating
	(@articleId INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @rating FLOAT;

	SELECT @rating = AVG(CAST(Mark as FLOAT)) FROM dbo.ArticleRating WHERE ArticleId = @articleId;
	UPDATE dbo.Articles SET AverageRating = @rating WHERE Id = @articleId

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

GO
CREATE OR ALTER PROCEDURE RateArticle
	(@articleId INT,
	 @userId INT,
	 @mark INT)
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
		
	IF NOT EXISTS(SELECT * from dbo.ArticleRating WHERE UserId = @userId AND ArticleId = @articleId)
		INSERT INTO dbo.ArticleRating
		(ArticleId, UserId, Mark)
		VALUES (@articleId, @userId, @mark);
	ELSE
		UPDATE dbo.ArticleRating 
		SET Mark = @mark 
		WHERE ArticleId = @articleId AND UserId = @userId
	
	EXEC UpdateArticleAverageRating @articleId;
	
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

GO
CREATE OR ALTER PROCEDURE CommentArticle
	(@articleId INT,
	 @userId INT,
	 @comment TEXT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
	
	INSERT INTO dbo.Comments
	(ArticleId, UserId, Coment)
	VALUES (@articleId, @userId, @comment)

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

GO
CREATE OR ALTER PROCEDURE DeleteComment
	(@commentId INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
		
	DELETE FROM dbo.Comments WHERE Id = @commentId;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

GO
CREATE OR ALTER PROCEDURE DeleteRating
	(@ratingId INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
		
	DELETE FROM dbo.ArticleRating WHERE Id = @ratingId;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

GO
CREATE OR ALTER PROCEDURE DeleteArticle
	(@articleId INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
		
	DECLARE @commentId INT;
	DECLARE @ratingId INT;
	DECLARE Comments CURSOR
		FOR SELECT Id FROM Comments WHERE ArticleId = @articleId;

	OPEN Comments;
	FETCH NEXT FROM Comments INTO @commentId;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC DeleteComment @commentId;
		FETCH NEXT FROM Comments INTO @commentId;
	END 

	CLOSE Comments;
	DEALLOCATE Comments;

	DECLARE Ratings CURSOR
		FOR SELECT Id FROM ArticleRating WHERE ArticleId = @articleId;

	OPEN Ratings;
	FETCH NEXT FROM Ratings INTO @ratingId;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC DeleteRating @ratingId;
		FETCH NEXT FROM Ratings INTO @ratingId;
	END 

	CLOSE Ratings;
	DEALLOCATE Ratings; 

	DELETE FROM dbo.Articles WHERE Id = @articleId;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

--Blogs

GO
CREATE OR ALTER PROCEDURE CreateBlog
	(@Name VARCHAR(50),
	 @UserId INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	INSERT INTO dbo.Blogs 
	(Name, UserId, IsPaid)
	VALUES (@Name, @UserId, 0);

	COMMIT
	RETURN SCOPE_IDENTITY();
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError;
END CATCH

GO
CREATE OR ALTER PROCEDURE PayBlog
	(@BlogId INT)
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;

	UPDATE dbo.Blogs SET IsPaid = 1 WHERE Id = @BlogId;
	
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError;
END CATCH

GO
CREATE OR ALTER PROCEDURE DeleteBlog
	(@blogId INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
		
	DECLARE @articleId INT;
	DECLARE Articles CURSOR
		FOR SELECT Id FROM Articles WHERE BlogId = @blogId;

	OPEN Articles;
	FETCH NEXT FROM Articles INTO @articleId;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC DeleteArticle @articleId;
		FETCH NEXT FROM Articles INTO @articleId;
	END 

	CLOSE Articles;
	DEALLOCATE Articles;

	DELETE FROM dbo.Blogs WHERE Id = @blogId;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH

--Users

GO
CREATE OR ALTER PROCEDURE CreateUser
	(@Name VARCHAR(50),
    @Login VARCHAR(50),
    @Password VARCHAR(50),
    @Email VARCHAR(50))
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;

    INSERT INTO dbo.Users 
	(Name, Login, Password, Email)
	VALUES (@Name, @Login, @Password, @Email)

	COMMIT
	RETURN SCOPE_IDENTITY();
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError;
END CATCH

GO
CREATE OR ALTER PROCEDURE DeleteUser
	(@userId INT)
AS
BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @blogId INT;
	DECLARE @ratingId INT;
	
	DECLARE Blogs CURSOR
		FOR SELECT Id FROM Blogs WHERE UserId = @userId;

	OPEN Blogs;
	FETCH NEXT FROM Blogs INTO @blogId;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC DeleteBlog @blogId;
		FETCH NEXT FROM Blogs INTO @blogId;
	END 

	DECLARE @commentId INT;
	DECLARE Comments CURSOR
		FOR SELECT Id FROM Comments WHERE UserId = @userId;

	OPEN Comments;
	FETCH NEXT FROM Comments INTO @commentId;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC DeleteComment @commentId;
		FETCH NEXT FROM Comments INTO @commentId;
	END 

	CLOSE Comments;
	DEALLOCATE Comments;

	CLOSE Blogs;
	DEALLOCATE Blogs;

	DECLARE Ratings CURSOR
		FOR SELECT Id FROM ArticleRating WHERE UserId = @userId;

	OPEN Ratings;
	FETCH NEXT FROM Ratings INTO @ratingId;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC DeleteRating @ratingId;
		FETCH NEXT FROM Ratings INTO @ratingId;
	END 

	CLOSE Ratings;
	DEALLOCATE Ratings; 

	DELETE FROM dbo.Users WHERE Id = @userId;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	EXEC HandleError
END CATCH
