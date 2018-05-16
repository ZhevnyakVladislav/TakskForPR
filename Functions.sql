USE Task_DB;

--Users

GO
CREATE OR ALTER FUNCTION CreateUser
(    @Name VARCHAR(50),
    @Login VARCHAR(50),
    @Password VARCHAR(50),
    @Email VARCHAR(50))
RETURNS INT
AS BEGIN
    INSERT INTO dbo.Users VALUES (@Name, @Login, @Password, @Email)

    RETURN SELECT Id From dbo.Users WHERE Name = @Name
END