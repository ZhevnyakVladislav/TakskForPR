Use Task_DB;

DECLARE @userCount INT;
DECLARE @userId INT;
DECLARE @blogId INT;


SELECT @userCount = COUNT(*) FROM dbo.Users;

DECLARE @login VARCHAR(50) = 'UserLogin' + CAST(@userCount as varchar);
DECLARE @email VARCHAR(50) = 'UserEmail' + CAST(@userCount as varchar);

EXEC  @userId = CreateUser 'UserName', @login,'password', @email;

EXEC @blogId = CreateBlog 'Blog', @userId;


EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';
EXEC CreateArticle @blogId, 'Article', 'dawdawdawdawddawd';

--EXEC PayBlog @blogId; it's work
