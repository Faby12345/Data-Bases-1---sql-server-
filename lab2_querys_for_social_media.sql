use SocialMediaDB;
go

/* Insert sample users */
INSERT INTO SocialMediaDB.dbo.Users (userame, email, password)
VALUES ('ana', 'ana@example.com', 'pass123'),
       ('mihai', 'mihai@example.com', 'pass456'),
       ('laura', 'laura@example.com', 'pass789');

/*
Explanation:a
- We don't insert id or created_at because:
  - id is IDENTITY(1,1) so SQL Server auto-generates it.
  - created_at has DEFAULT SYSUTCDATETIME().
*/


/* Insert sample posts. Each post belongs to a user_id from Users.id */
INSERT INTO dbo.Posts (user_id, content)
VALUES (11, 'Hello world, first post!'),
       (12, 'Does anyone know good SQL resources?'),
       (11, 'Today I learned about foreign keys.');



/*
Explanation:
- user_id is a FOREIGN KEY to Users(id)
- So post (user_id=1) means "user with id=1 wrote this post".
*/


/* Insert sample comments. Each comment belongs to a post and a user */
INSERT INTO dbo.Comment (post_id, user_id, content)
VALUES (4, 12, 'Nice post!'),
       (4, 13, 'Welcome :)'),
       (5, 11, 'Check out SQLServerTutorials.net maybe'),
       (6, 12, 'Foreign keys are pain but useful');
/*
Explanation:
- post_id FK -> Posts.id
- user_id FK -> Users.id
- So we are creating conversations across users.
*/


/* Insert sample follows (user follows user) */
INSERT INTO dbo.Follow (follower_id, followee_id)
VALUES (12, 11),
       (13, 11),
       (11, 12);

UPDATE dbo.Users
SET email = 'mihai@updated.example.com'
WHERE userame = 'mihai'
  AND email <> 'mihai@updated.example.com' -- relational operator <>
  AND email LIKE '%@example.com';


DELETE
FROM dbo.Comment
WHERE (
    -- condition 1: comment is from certain users we don't trust
    user_id IN (11, 12) -- IN
        AND content LIKE '%Welcome%' -- LIKE
    )
   OR (
    -- condition 2: content is NOT like anything meaningful
    NOT (content LIKE '%SQL%' OR content LIKE '%foreign key%') -- NOT + OR
    )
   OR (
          -- condition 3: created_at BETWEEN two timestamps
          created_at BETWEEN '2025-01-01' AND '2025-12-31'
          )
    AND created_at IS NOT NULL;

SELECT user_id AS active_user_id
FROM dbo.Posts
UNION  -- combines them with no duplicates
SELECT user_id AS active_user_id
FROM dbo.Comment;

SELECT user_id
FROM dbo.Posts
INTERSECT -- search for users that commented and posted
SELECT user_id
FROM dbo.Comment;

SELECT user_id
FROM dbo.Posts
EXCEPT -- search for users that posted but not commented
SELECT user_id
FROM dbo.Comment;

SELECT p.id AS post_id,
       u.userame,
       p.content,
       p.created_at
FROM dbo.Posts p
         INNER JOIN dbo.Users u -- selects only users that posted
                    ON p.user_id = u.id
ORDER BY p.created_at DESC;



SELECT u.userame,
       p.id AS post_id,
       p.content
FROM dbo.Users u
         LEFT JOIN dbo.Posts p -- selects all users  + all their posts if they have
                   ON p.user_id = u.id
ORDER BY u.userame;


SELECT c.id      AS comment_id,
       c.content AS comment_text,
       u.userame AS commenter
FROM dbo.Users u
         RIGHT JOIN dbo.Comment c -- selects all the comments + their users
                    ON c.user_id = u.id
ORDER BY c.id;


SELECT
    p.id AS post_id,
    p.content AS post_content,
    u.userame AS post_author,
    c.content AS comment_content,
    c.created_at AS comment_time
FROM dbo.Posts p
         FULL JOIN dbo.Comment c -- see all posts (with or without comments) + comments that don t have any posts then join users tio see their username
                   ON c.post_id = p.id
         LEFT JOIN dbo.Users u
                   ON p.user_id = u.id
ORDER BY post_id;


SELECT u.userame
FROM dbo.Users u
WHERE u.id IN ( -- select the users that have posted
    SELECT p.user_id
    FROM dbo.Posts p
);


SELECT p.id,
       p.content,
       p.created_at
FROM dbo.Posts p
WHERE EXISTS ( -- select the post + the info that have at least one comment
    SELECT 1
    FROM dbo.Comment c
    WHERE c.post_id = p.id
);


SELECT p.id AS post_id,
       p.content,
       cc.comment_count
FROM dbo.Posts p
         LEFT JOIN (
    SELECT post_id,
           COUNT(*) AS comment_count -- select all the posts + the number of comments that have that post
    FROM dbo.Comment
    GROUP BY post_id
) AS cc
                   ON p.id = cc.post_id
ORDER BY cc.comment_count DESC;


SELECT u.userame,
       COUNT(p.id) AS total_posts
FROM dbo.Users u
         LEFT JOIN dbo.Posts p
                   ON p.user_id = u.id -- how many posts does each user have
GROUP BY u.userame
ORDER BY total_posts DESC;


SELECT u.userame,
       COUNT(p.id) AS total_posts
FROM dbo.Users u
         JOIN dbo.Posts p
              ON p.user_id = u.id -- get all the users who have at least 2 posts
GROUP BY u.userame
HAVING COUNT(p.id) >= 2
ORDER BY total_posts DESC;

SELECT u.userame,
       AVG(LEN(p.content)) AS avg_length,
       MIN(LEN(p.content)) AS min_length,
       MAX(LEN(p.content)) AS max_length,
       COUNT(*) AS post_count
FROM dbo.Users u
         JOIN dbo.Posts p
              ON p.user_id = u.id -- get all the users who have the avg length of their posts > avg overall post length
GROUP BY u.userame
HAVING AVG(LEN(p.content)) > (
    SELECT AVG(LEN(p2.content))
    FROM dbo.Posts p2
);