USE Task_DB;

DECLARE @userCount INT = 5;
DECLARE @blogCount INT = 100;
DECLARE @i INT = 0;
DECLARE @userId INT;

SELECT @userCount = COUNT(*) FROM Users;

WHILE @i < @blogCount
BEGIN
	DECLARE @blogId INT;

	IF (@i % (@blogCount / @userCount) = 0)
	BEGIN
		DECLARE @offset INT = CAST(@i AS FLOAT) / 100 * @userCount;
		SELECT @userId = Id FROM Users ORDER BY Id OFFSET @offset ROWS FETCH NEXT 1 ROWS ONLY;
	END

	EXEC @blogId = CreateBlog 'Blog', @userId;

	SET @i = @i + 1;
END