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
	(Name, Login, Password, Email, CreatedAt) 
	VALUES (@Name, @Login, @Password, @Email, GETDATE())	
END

--Blogs

GO
CREATE OR ALTER PROCEDURE CreateBlog
	(@Name VARCHAR(50),
	@UserId INT)
AS
BEGIN
	INSERT INTO dbo.Blogs 
	(Name, UserId, CreatedAt)
	VALUES (@Name, @UserId, GETDATE());
END

GO
CREATE OR ALTER PROCEDURE PayBlog
	(@BlogId INT)
AS
BEGIN
	UPDATE dbo.Blogs SET IsPaid = 1 WHERE Id = @BlogId;
	UPDATE dbo.Articles SET IsBlocked = 1 WHERE BlogId = @BlogId;
END

--Atricles

GO
CREATE OR ALTER PROCEDURE CreateArticle
	(@BlogId INT,
	@Title VARCHAR(50),
	@Content TEXT)
AS
BEGIN
	DECLARE @IsBlogPaid BIT;
	DECLARE @count INT;
	DECLARE @IsArticleBlocked BIT;
	SET @IsArticleBlocked = 0;

	SELECT @IsBlogPaid = IsPaid FROM dbo.Blogs WHERE Id = @BlogId;
	SELECT @count = COUNT(*) FROM dbo.Articles WHERE BlogId = @BlogId;
	
	IF(IsBlogPaid = 0 AND @count > 100)
		BEGIN
			SET @IsArticleBlocked = 0;
		END

	INSERT INTO dbo.Articles 
	(BlogId, Title, Content, IsBlocked, CreatedAt)
	VALUES (@BlogId, @Title, @Content, @IsArticleBlock, GETDATE())
END

--Common

GO
CREATE OR ALTER PROCEDURE SetCreatedAt
	(@tableName VARCHAR(20))
AS
BEGIN
	DECLARE @Cmd nvarchar(150) = 'UPDATE QUOTENAME(@tableName) SET CreatedAt = GETDATE() WHERE ID IN (SELECT DISTINCT ID FROM Inserted);'
	EXEC @sp_executesql @Cmd, @tableName;
END

GO
CREATE OR ALTER PROCEDURE SetUpdatedAt
	(@tableName VARCHAR(20))
AS
BEGIN
	DECLARE @Cmd nvarchar(150) = 'UPDATE QUOTENAME(@tableName) SET CreatedAt = GETDATE() WHERE ID IN (SELECT DISTINCT ID FROM Inserted);'
	EXEC @sp_executesql @Cmd, @tableName;
END