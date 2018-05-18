USE Task_DB;

--Users

GO
CREATE OR ALTER TRIGGER trigger_SetUserCreatedTime
ON dbo.Users
FOR INSERT AS
BEGIN
    SET NOCOUNT ON
    UPDATE dbo.Users
	SET CreatedAt = GETDATE()
    WHERE ID IN (SELECT DISTINCT ID FROM Inserted)
END

GO
CREATE OR ALTER TRIGGER trigger_SetUserUpdatedTime
ON dbo.Users
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON
    UPDATE dbo.Users
    SET UpdatedAt = GETDATE()
    WHERE ID IN (SELECT DISTINCT ID FROM Inserted)
END

--Blogs

GO
CREATE OR ALTER TRIGGER trigger_SetBlogCreatedTime
ON dbo.Blogs
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON
    UPDATE dbo.Blogs
    SET 
		CreatedAt = GETDATE(),
		IsPaid = 0
    WHERE ID IN (SELECT DISTINCT ID FROM Inserted);
END
    
GO
CREATE OR ALTER TRIGGER trigger_SetBlogUpdatedTime
ON dbo.Blogs
AFTER UPDATE AS 
BEGIN
    SET NOCOUNT ON
    UPDATE dbo.Blogs
    SET UpdatedAt = GETDATE()
    WHERE ID IN (SELECT DISTINCT ID FROM Inserted)
END

--Articles

GO
CREATE OR ALTER TRIGGER trigger_CheckIfArticleBlocked
ON dbo.Articles
AFTER INSERT 
AS	
	BEGIN
		DECLARE @articleId INT
		SET NOCOUNT ON;
		SELECT @articleId = Id FROM inserted
		EXEC CheckBlogForPaid @articleId
	END

GO
CREATE OR ALTER TRIGGER trigger_SetArticleCreatedTime
ON dbo.Articles
AFTER INSERT AS
BEGIN
    UPDATE dbo.Articles
    SET CreatedAt = GETDATE()
    WHERE Id IN (SELECT DISTINCT Id FROM Inserted);
END

GO
CREATE OR ALTER TRIGGER trigger_SetArticleUpdatedTime
ON dbo.Articles
AFTER UPDATE AS 
BEGIN
    UPDATE dbo.Articles
    SET UpdatedAt = GETDATE()
    WHERE Id IN (SELECT DISTINCT Id FROM Inserted)
END

