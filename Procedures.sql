USE Task_DB;
--Users

--Blogs

GO
CREATE OR ALTER PROCEDURE CheckBlogForPaid(@articleId int)
AS
BEGIN
	DECLARE @count INT;
    DECLARE @blogId INT;
    DECLARE @blogIsPaid BIT;
    SELECT @blogId = BlogId FROM dbo.Articles WHERE Id = @articleId;
	SELECT @count = COUNT(Id) FROM dbo.Articles WHERE BlogId = @blogId;
    SELECT @blogIsPaid = IsPaid FROM dbo.Blogs WHERE Id = @blogId
	IF(@count > 100 AND @blogIsPaid)
	BEGIN
		UPDATE dbo.Articles
		SET IsBlocked = 1
		WHERE Id = @articleId
	ENd
END