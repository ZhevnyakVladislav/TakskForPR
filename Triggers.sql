USE Task_DB;

--Users

GO
CREATE OR ALTER TRIGGER trigger_SetUserCreatedTime
ON dbo.Users
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
    EXEC SetCreatedAt 'Users', @Id;
END

GO
CREATE OR ALTER TRIGGER trigger_SetUserUpdatedTime
ON dbo.Users
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON;
	DECLARE @Id INT;
	SELECT DISTINCT @Id = Id FROM Inserted;
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
    EXEC SetCreatedAt 'dbo.Blogs', @Id;
END
    
GO
CREATE OR ALTER TRIGGER trigger_SetBlogUpdatedTime
ON dbo.Blogs
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON;
    EXEC SetUpdatedAt 'dbo.Blogs';
END

--Articles

GO
CREATE OR ALTER TRIGGER trigger_SetArticleCreatedTime
ON dbo.Articles
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
    EXEC SetCreatedAt 'dbo.Articles';
END

GO
CREATE OR ALTER TRIGGER trigger_SetArticleUpdatedTime
ON dbo.Articles
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @blogId INT;
    SELECT DISTINCT @blogId = Id FROM Inserted;
    --EXEC CheckIfBlogOverflow @blogId;
    EXEC SetUpdatedAt 'dbo.Articles';
END