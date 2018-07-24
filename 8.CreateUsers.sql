USE Task_DB;

DECLARE @userCount INT = 5;
DECLARE @i INT = 0;
DECLARE @currUserCount INT;;

SELECT @currUserCount = COUNT(*) FROM dbo.Users;

WHILE  @i < @userCount
BEGIN
	DECLARE @userId INT;
	DECLARE @login VARCHAR(50) = 'UserLogin' + CAST(@currUserCount + @i AS varchar);
	DECLARE @email VARCHAR(50) = 'UserEmail' + CAST(@currUserCount + @i AS varchar);

	EXEC  @userId = CreateUser 'UserName1', @login,'pASsword', @email;
	
	SET @i = @i + 1;
END