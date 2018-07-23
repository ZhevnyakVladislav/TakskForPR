USE Task_DB;

CREATE INDEX i1 
ON Articles(CreatedAt);

CREATE INDEX i2 
ON Articles(BlogId);

CREATE INDEX i3 
ON Comments(ArticleId);

CREATE INDEX i2 
ON Articles(BlogId);

CREATE INDEX i4
ON Blogs(UserId);

