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
	VALUES (@Name, @UserId);
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
	DECLARE @IsArticleBlocked BIT = 1;

	SELECT @IsBlogPaid = IsPaid FROM dbo.Blogs WHERE Id = @BlogId;
	SELECT @count = COUNT(*) FROM dbo.Articles WHERE BlogId = @BlogId;
	
	IF(@IsBlogPaid = 0 AND @count > 100)
		BEGIN
			SET @IsArticleBlocked = 1;
		END
		
	INSERT INTO dbo.Articles 
	(BlogId, Title, Content, IsBlocked)
	VALUES (@BlogId, @Title, @Content, @IsArticleBlocked)
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