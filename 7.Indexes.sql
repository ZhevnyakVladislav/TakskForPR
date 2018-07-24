USE Task_DB;

CREATE INDEX IX_BlogId
ON Articles(Id, BlogId);

CREATE INDEX IX_AverageRating
ON Articles(BlogId, AverageRating);

CREATE INDEX IX_IsBlocked
ON Articles(Id, BlogId, AverageRating, IsBlocked);

CREATE INDEX IX_UserId
ON Blogs(UserId);

CREATE INDEX IX_UserId
ON ArticleRating(UserId)

CREATE INDEX IX_ArticleId
ON ArticleRating(ArticleId)

CREATE INDEX IX_ArticleId 
ON Comments(ArticleId);

CREATE INDEX IX_UserId
ON Comments(UserId)
