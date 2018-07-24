uSE Task_DB;

DECLARE @blogCount INT;
DECLARE @articleCount INT = 7000;
DECLARE @commentCount INT = 10;
DECLARE @i INT = 0;
DECLARE @j INT = 0;
DECLARE @currUserCount INT;;
DECLARE @userId INT;
DECLARE @blogId INT;

SELECT @blogCount = COUNT(*) FROM Blogs;

WHILE @i < @articleCount
BEGIN
	DECLARE @articleId INT;

	IF (@i % (@articleCount / @blogCount) = 0)
	BEGIN
		DECLARE @offset INT = CAST(@i AS FLOAT) / @articleCount * @blogCount;
		SELECT @blogId = Id FROM Blogs ORDER BY Id OFFSET @offset ROWS FETCH NEXT 1 ROWS ONLY;
	END

	EXEC @articleId = CreateArticle @blogId, 'Article',	 'Content';

	IF(@articleId > 0)
	BEGIN 
		DECLARE @RandomMark INT = ROUND(((5 - 1 - 1) * RAND() + 1), 0)
		SELECT TOP 1 @userId = Id FROM Users ORDER BY NEWID();

		EXEC RateArticle @articleId, @userId, @RandomMark;

		SET @j = 0;

		WHILE @j < @commentCount
		BEGIN
			SELECT TOP 1 @userId = Id FROM Users ORDER BY NEWID();
			EXEC CommentArticle @articleId, @userId, 'Comment';

			SET @j = @j + 1;
		END
	END

	SET @i = @i + 1;
END