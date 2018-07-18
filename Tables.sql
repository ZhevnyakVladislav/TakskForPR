	USE Task_DB;

GO
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name='Users')
CREATE TABLE Users
    (Id INTEGER IDENTITY(1,1) PRIMARY KEY NOT NULL ,
    Name VARCHAR(50) NOT NULL,
    Login VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE,
    CreatedAt DATETIME,
    UpdatedAt DATETIME)

GO
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name='Blogs')
CREATE TABLE Blogs
    (Id INTEGER IDENTITY(1,1) PRIMARY KEY NOT NULL,
    UserId INTEGER FOREIGN KEY (UserId) REFERENCES USERS(Id) NOT NULL,
    Name VARCHAR(50),
    IsPaid BIT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME)

GO
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name='Articles')
CREATE TABLE Articles
    (Id INTEGER IDENTITY(1,1) PRIMARY KEY NOT NULL,
    BlogId INTEGER FOREIGN KEY (BlogId) REFERENCES Blogs(Id) NOT NULL,
    Title VARCHAR(50) NOT NULL,
    IsBlocked BIT NOT NULL,
    Content TEXT,
	AverageRaing FLOAT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME)

GO
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name='Comments')
CREATE TABLE Comments (
	Id INTEGER IDENTITY(1,1) PRIMARY KEY NOT NULL,
    UserId INTEGER FOREIGN KEY (UserId) REFERENCES Users(Id) NOT NULL,
    ArticleId INTEGER FOREIGN KEY (ArticleId) REFERENCES Articles(Id) NOT NULL,
    Coment TEXT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME)

GO
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name='ArticleRating')
CREATE TABLE ArticleRating (
	Id INTEGER IDENTITY(1,1) PRIMARY KEY NOT NULL,
    UserId INTEGER FOREIGN KEY (UserId) REFERENCES Users(Id) NOT NULL UNIQUE,
    ArticleId INTEGER FOREIGN KEY (ArticleId) REFERENCES Articles(Id) NOT NULL,
	Mark INT CHECK (Mark >= 1 AND Mark <= 6),
	CreatedAt DATETIME,
    UpdatedAt DATETIME)