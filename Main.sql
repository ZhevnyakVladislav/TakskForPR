Use TASk_DB;

DECLARE @userCount INT = 5;
DECLARE @blogCount INT = 100;
DECLARE @articleCount INT = 10000;
DECLARE @i INT = 1;
DECLARE @currUserCount INT;;

SET NOCOUNT ON;

DECLARE @userIds TABLE (Id int);
DECLARE @blogIds TABLE (Id int);
DECLARE @articleIds TABLE (Id int);

SELECT @currUserCount = COUNT(*) FROM dbo.Users;

WHILE  @i < @userCount
BEGIN
	DECLARE @userId INT;
	DECLARE @login VARCHAR(50) = 'UserLogin' + CAST(@currUserCount + @i AS varchar);
	DECLARE @email VARCHAR(50) = 'UserEmail' + CAST(@currUserCount + @i AS varchar);

	EXEC  @userId = CreateUser 'UserName1', @login,'pASsword', @email;
	INSERT @userIds(id) values(@userId);
	SET @i = @i + 1;
END

SET @i = 0;

WHILE @i < @blogCount
BEGIN
	DECLARE @blogId INT;

	IF (@i % (@blogCount / @userCount) = 0)
	BEGIN
		DECLARE @offset INT = CAST(@i AS FLOAT) / 100 * @userCount;
		SELECT @userId = Id FROM @userIds ORDER BY Id OFFSET @offset ROWS FETCH NEXT 1 ROWS ONLY;
	END

	EXEC @blogId = CreateBlog 'Blog', @userId;
	INSERT @blogIds(id) values(@blogId);
	SET @i = @i + 1;
END

SET @i = 0;

WHILE @i < @articleCount
BEGIN
	DECLARE @articleId INT;

	IF (@i % (@articleCount / @blogCount) = 0)
	BEGIN
		SET @offset = CAST(@i AS FLOAT) / @articleCount * @blogCount;
		SELECT @blogId = Id FROM @blogIds ORDER BY Id OFFSET @offset ROWS FETCH NEXT 1 ROWS ONLY;
	END

	EXEC @articleId = CreateArticle @blogId, 'Article', 'Content';
	INSERT @articleIds(id) values(@articleId);
	SET @i = @i + 1;
END

SET @i = 0;

WHILE @i < @articleCount
BEGIN
	SELECT @articleId = Id FROM @articleIds ORDER BY Id OFFSET @i ROWS FETCH NEXT 1 ROWS ONLY;
	SELECT TOP (1) @userId = Id FROM @userIds ORDER BY RAND();

	DECLARE @RandomMark INT = ROUND(((5 - 1 - 1) * RAND() + 1), 0)

	EXEC RateArticle @articleId, @userId, @RandomMark;
	EXEC CommentArticle @articleId, @userId, 'Comment';
	SET @i = @i + 1
END

--EXEC PayBLog @blogId;

