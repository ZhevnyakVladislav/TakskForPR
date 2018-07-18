Use Task_DB;

DECLARE @userCount INT;
DECLARE @UserId1 INT;
DECLARE @UserId2 INT;
DECLARE @blogId INT;
DECLARE @articleId INT;



SELECT @userCount = COUNT(*) FROM dbo.Users;

DECLARE @login1 VARCHAR(50) = 'UserLogin' + CAST(@userCount as varchar);
DECLARE @email1 VARCHAR(50) = 'UserEmail' + CAST(@userCount as varchar);
DECLARE @login2 VARCHAR(50) = 'UserLogin1' + CAST(@userCount as varchar);
DECLARE @email2 VARCHAR(50) = 'UserEmail1' + CAST(@userCount as varchar);

EXEC  @UserId1 = CreateUser 'UserName1', @login1,'password', @email1;
EXEC  @UserId2 = CreateUser 'UserName2', @login2,'password', @email2;

EXEC @blogId = CreateBlog 'Blog', @userId1;

EXEC @articleId = CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';

--EXEC PayBlog @blogId; it's work

SELECT * FROM GetArticlesCreatedLater(GETDATE());

EXEC RateArticle @articleId, @userId1, 4;
EXEC RateArticle @articleId, @userId2, 1;
--EXEC RateArticle @articleId, @userId1, 4; return exception user already exists
--EXEC RateArticle @articleId, @userId1, 6; return exception value should be <5 and >1

