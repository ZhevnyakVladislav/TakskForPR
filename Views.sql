USE Task_DB;

GO
CREATE OR ALTER VIEW ViewAllFreeBlogs
	AS 
	SELECT *
	FROM dbo.Blogs
	WHERE IsPaid = 0

GO 
CREATE OR ALTER VIEW viewArticles
AS 
SELECT Articles.Title, 
	Articles.Content, 
	Articles.CreatedAt, 
	Blogs.Name, 
	Users.Login,
	Count(Comments.Id) as 'Comment Count'
FROM dbo.Articles
	JOIN Blogs ON Articles.BlogId = Blogs.Id
	JOIN Users ON Blogs.UserId = Users.Id
	LEFT JOIN Comments ON Comments.ArticleId = Articles.Id
GROUP BY Articles.Title, Articles.Content, Blogs.Name;


GO
CREATE OR ALTER VIEW viewFreeBlogs
AS
SELECT Blogs.Id , 
  Blogs.Name,
  Blogs.IsPaid ,
  Users.Login,
  SUM(IIF(BlogArticles.IsBlocked = 1, 1, 0)) as 'Blocked articles count',
  SUM(IIF(BlogArticles.IsBlocked = 0, 1, 0)) as 'Free articles count',
  COUNT(BlogArticles.Id) as 'Total articles count',
  AVG(IIF(BlogArticles.AverageRating IS NOT NULL, BlogArticles.AverageRating, NULL)) as 'Blog average rating'
FROM Blogs
JOIN Users ON Users.Id = Blogs.UserId
LEFT JOIN Articles BlogArticles ON BlogArticles.BlogId = Blogs.Id
WHERE Blogs.IsPaid = 0
GROUP BY Blogs.Id, Blogs.Name, Blogs.IsPaid, Users.Login;

GO
CREATE OR ALTER VIEW viewUsers
AS
SELECT Users.Id,
	Users.Login,
	Users.Name,
	AVG(CASE WHEN BlogArticles.AverageRating IS NOT NULL THEN BlogArticles.AverageRating END) as 'Average rating'
FROM Users
JOIN Blogs ON Blogs.UserId = Users.Id
LEFT JOIN Articles BlogArticles ON BlogArticles.BlogId = Blogs.Id
GROUP BY Users.Id, Users.Login, Users.Name;
