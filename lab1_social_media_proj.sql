USE master;
GO

IF DB_ID('SocialMediaDB') IS NULL
    BEGIN
        CREATE DATABASE SocialMediaDB;
    END;
GO

USE SocialMediaDB;
GO


IF OBJECT_ID('dbo.Users', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Users
        (
            id         INT IDENTITY (1,1) PRIMARY KEY,
            username   VARCHAR(50) NOT NULL,
            email      VARCHAR(50) NOT NULL,
            password   VARCHAR(50) NOT NULL,
            created_at DATETIME    NOT NULL DEFAULT SYSUTCDATETIME()
        );
    END;
GO


IF OBJECT_ID('dbo.Posts', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Posts
        (
            id         INT IDENTITY (1,1) PRIMARY KEY,
            user_id    INT          NOT NULL,
            content    VARCHAR(500) NOT NULL,
            created_at DATETIME     NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT FK_Posts_Users
                FOREIGN KEY (user_id)
                    REFERENCES dbo.Users (id)
        );
    END;
GO

/* Comment */
IF OBJECT_ID('dbo.Comment', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Comment
        (
            id         INT IDENTITY (1,1) PRIMARY KEY,
            post_id    INT          NOT NULL,
            user_id    INT          NOT NULL,
            content    VARCHAR(500) NOT NULL,
            created_at DATETIME     NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT FK_Comment_Users
                FOREIGN KEY (user_id)
                    REFERENCES dbo.Users (id),

            CONSTRAINT FK_Comment_Posts
                FOREIGN KEY (post_id)
                    REFERENCES dbo.Posts (id)
        );
    END;
GO

/* Follow (many-to-many: user follows user) */
IF OBJECT_ID('dbo.Follow', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Follow
        (
            follower_id INT      NOT NULL,
            followee_id INT      NOT NULL,
            created_at  DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT PK_Follow
                PRIMARY KEY (follower_id, followee_id),

            CONSTRAINT FK_Follow_Follower
                FOREIGN KEY (follower_id)
                    REFERENCES dbo.Users (id),

            CONSTRAINT FK_Follow_Followee
                FOREIGN KEY (followee_id)
                    REFERENCES dbo.Users (id)
        );
    END;
GO

/* LikePost (many-to-many: users like posts) */
IF OBJECT_ID('dbo.LikePost', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.LikePost
        (
            user_id  INT      NOT NULL,
            post_id  INT      NOT NULL,
            liked_at DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT PK_LikePost
                PRIMARY KEY (user_id, post_id),

            CONSTRAINT FK_LikePost_Users
                FOREIGN KEY (user_id)
                    REFERENCES dbo.Users (id),

            CONSTRAINT FK_LikePost_Posts
                FOREIGN KEY (post_id)
                    REFERENCES dbo.Posts (id)
        );
    END;
GO

/* LikeComment (many-to-many: users like comments) */
IF OBJECT_ID('dbo.LikeComment', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.LikeComment
        (
            user_id    INT      NOT NULL,
            comment_id INT      NOT NULL,
            liked_at   DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT PK_LikeComment
                PRIMARY KEY (user_id, comment_id),

            CONSTRAINT FK_LikeComment_Users
                FOREIGN KEY (user_id)
                    REFERENCES dbo.Users (id),

            CONSTRAINT FK_LikeComment_Comments
                FOREIGN KEY (comment_id)
                    REFERENCES dbo.Comment (id)
        );
    END;
GO

/* Media (1 post can have many media files: images/videos) */
IF OBJECT_ID('dbo.Media', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Media
        (
            id          INT IDENTITY (1,1) PRIMARY KEY,
            post_id     INT          NOT NULL,
            file_url    VARCHAR(300) NOT NULL,
            media_type  VARCHAR(50)  NOT NULL, -- 'image', 'video', etc.
            uploaded_at DATETIME     NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT FK_Media_Posts
                FOREIGN KEY (post_id)
                    REFERENCES dbo.Posts (id)
        );
    END;
GO

/* Messages (DMs between two users) */
IF OBJECT_ID('dbo.Messages', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Messages
        (
            id          INT IDENTITY (1,1) PRIMARY KEY,
            sender_id   INT           NOT NULL,
            receiver_id INT           NOT NULL,
            content     VARCHAR(1000) NOT NULL,
            sent_at     DATETIME      NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT FK_Messages_Sender
                FOREIGN KEY (sender_id)
                    REFERENCES dbo.Users (id),

            CONSTRAINT FK_Messages_Receiver
                FOREIGN KEY (receiver_id)
                    REFERENCES dbo.Users (id)
        );
    END;
GO

/* Groups (like community/groups feature) */
IF OBJECT_ID('dbo.Groups', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Groups
        (
            id          INT IDENTITY (1,1) PRIMARY KEY,
            name        VARCHAR(150) NOT NULL,
            description VARCHAR(500) NULL,
            owner_id    INT          NOT NULL, -- who created / owns the group
            created_at  DATETIME     NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT FK_Groups_Owner
                FOREIGN KEY (owner_id)
                    REFERENCES dbo.Users (id)
        );
    END;
GO

/* GroupMembers (many-to-many: users join groups) */
IF OBJECT_ID('dbo.GroupMembers', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.GroupMembers
        (
            group_id  INT      NOT NULL,
            user_id   INT      NOT NULL,
            joined_at DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),

            CONSTRAINT PK_GroupMembers
                PRIMARY KEY (group_id, user_id),

            CONSTRAINT FK_GroupMembers_Groups
                FOREIGN KEY (group_id)
                    REFERENCES dbo.Groups (id),

            CONSTRAINT FK_GroupMembers_Users
                FOREIGN KEY (user_id)
                    REFERENCES dbo.Users (id)
        );
    END;
GO

