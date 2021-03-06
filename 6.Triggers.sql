USE Task_DB;

--Users

GO
CREATE OR ALTER TRIGGER trigger_SetUserCreatedTime
ON dbo.Users
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM inserted;
    EXEC SetCreatedAt 'Users', @Id;
END

GO
CREATE OR ALTER TRIGGER trigger_SetUserUpdatedTime
ON dbo.Users
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON;
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM inserted;
    EXEC SetUpdatedAt 'Users', @Id;
END

--Blogs

GO
CREATE OR ALTER TRIGGER trigger_SetBlogCreatedTime
ON dbo.Blogs
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
    EXEC SetCreatedAt 'Blogs', @Id;
END
    
GO
CREATE OR ALTER TRIGGER trigger_SetBlogUpdatedTime
ON dbo.Blogs
AFTER UPDATE AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM inserted;
    EXEC SetUpdatedAt 'Blogs', @Id;

	IF(UPDATE(IsPaid))
		EXEC UnlockActicles @Id;
END


--Articles

GO
CREATE OR ALTER TRIGGER trigger_SetArticleCreatedTime
ON dbo.Articles
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
    EXEC SetCreatedAt 'Articles', @Id;
END
    
GO
CREATE OR ALTER TRIGGER trigger_SetArticleUpdatedTime
ON dbo.Articles
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON;
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
    EXEC SetUpdatedAt 'Articles', @Id;
END

GO
CREATE OR ALTER TRIGGER trigger_SetArticlerRatingCreatedTime
ON dbo.ArticleRating
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON
	DECLARE @Id INT;
	DECLARE @ArticleId INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
    EXEC SetCreatedAt 'ArticleRating', @Id;
END
    
GO
CREATE OR ALTER TRIGGER trigger_SetArticleRatingUpdatedTime
ON dbo.ArticleRating
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON;
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
    EXEC SetUpdatedAt 'ArticleRating', @Id;
END

--Comments

GO
CREATE OR ALTER TRIGGER trigger_SetCommentCreatedTime
ON dbo.Comments
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
    EXEC SetCreatedAt 'Comments', @Id;
END
    
GO
CREATE OR ALTER TRIGGER trigger_SetCommentUpdatedTime
ON dbo.Comments
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON;
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
    EXEC SetUpdatedAt 'Comments', @Id;
END