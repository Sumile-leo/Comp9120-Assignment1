-- ===================================================
-- COMP9120 Assignment 1 数据库设计 (Sydney Music)
-- 作者: leo
-- ===================================================

-- 为了避免重复运行报错，先删除所有表
DROP TABLE IF EXISTS Remove CASCADE;
DROP TABLE IF EXISTS PlaylistItem CASCADE;
DROP TABLE IF EXISTS Playlist CASCADE;
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Listens_to CASCADE;
DROP TABLE IF EXISTS Contributed CASCADE;
DROP TABLE IF EXISTS Staff CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Artist CASCADE;
DROP TABLE IF EXISTS Track CASCADE;
DROP TABLE IF EXISTS Album CASCADE;

---------------------------------------------------
-- 专辑表 Album
-- 每张专辑至少有一首歌
---------------------------------------------------
CREATE TABLE Album (
    album_id SERIAL PRIMARY KEY,   -- 专辑ID (主键)
    release_date DATE NOT NULL     -- 发行日期
);

---------------------------------------------------
-- 歌曲表 Track
-- 每首歌属于至少一个专辑
---------------------------------------------------
CREATE TABLE Track (
    track_id SERIAL PRIMARY KEY,          -- 歌曲ID (主键)
    title VARCHAR(200) NOT NULL,          -- 歌曲标题
    duration INTERVAL NOT NULL,           -- 歌曲时长
    genre VARCHAR(100) NOT NULL,          -- 歌曲类型
    album_id INT NOT NULL REFERENCES Album(album_id) ON DELETE CASCADE
        -- 外键: 所属专辑
);

---------------------------------------------------
-- 艺术家表 Artist
---------------------------------------------------
CREATE TABLE Artist (
    artist_id SERIAL PRIMARY KEY,         -- 艺术家ID (主键)
    full_name VARCHAR(200) NOT NULL,      -- 全名
    email VARCHAR(200) NOT NULL,          -- 邮箱
    login_name VARCHAR(100) UNIQUE NOT NULL, -- 登录名 (唯一)
    password VARCHAR(100) NOT NULL,       -- 密码
    mobile_number VARCHAR(50)             -- 手机号
);

---------------------------------------------------
-- 贡献关系 Contributed
-- 表示某艺术家在某首歌中的角色 (歌手、作曲等)
---------------------------------------------------
CREATE TABLE Contributed (
    artist_id INT NOT NULL REFERENCES Artist(artist_id) ON DELETE CASCADE,
    track_id INT NOT NULL REFERENCES Track(track_id) ON DELETE CASCADE,
    role VARCHAR(100) NOT NULL,           -- 艺术家角色
    PRIMARY KEY (artist_id, track_id)     -- 联合主键
);

---------------------------------------------------
-- 顾客表 Customer
---------------------------------------------------
CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,       -- 顾客ID (主键)
    full_name VARCHAR(200) NOT NULL,      -- 全名
    email VARCHAR(200) NOT NULL,          -- 邮箱
    login_name VARCHAR(100) UNIQUE NOT NULL, -- 登录名 (唯一)
    password VARCHAR(100) NOT NULL,       -- 密码
    mobile_number VARCHAR(50),            -- 手机号
    age INT CHECK (age >= 0),             -- 年龄 (必须大于等于0)
    birth_date DATE                       -- 出生日期
);

---------------------------------------------------
-- 员工表 Staff
-- 薪资必须 >0 且 ≤200000
---------------------------------------------------
CREATE TABLE Staff (
    staff_id SERIAL PRIMARY KEY,          -- 员工ID (主键)
    full_name VARCHAR(200) NOT NULL,      -- 全名
    email VARCHAR(200) NOT NULL,          -- 邮箱
    login_name VARCHAR(100) UNIQUE NOT NULL, -- 登录名 (唯一)
    password VARCHAR(100) NOT NULL,       -- 密码
    mobile_number VARCHAR(50),            -- 手机号
    address VARCHAR(300),                 -- 地址
    compensation NUMERIC CHECK (compensation > 0 AND compensation <= 200000)
        -- 薪资范围约束
);

---------------------------------------------------
-- 评论表 Review
-- 顾客对歌曲的评论，包含评分和时间
---------------------------------------------------
CREATE TABLE Review (
    review_id SERIAL PRIMARY KEY,         -- 评论ID (主键)
    customer_id INT NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE,
    track_id INT NOT NULL REFERENCES Track(track_id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5), -- 评分 (1-5)
    comment TEXT,                         -- 可选评论
    created_date DATE NOT NULL,           -- 评论日期
    created_time TIME NOT NULL            -- 评论时间
);

---------------------------------------------------
-- 删除评论关系 Remove
-- 员工可删除评论，需记录原因和时间
---------------------------------------------------
CREATE TABLE Remove (
    staff_id INT NOT NULL REFERENCES Staff(staff_id) ON DELETE CASCADE,
    review_id INT NOT NULL REFERENCES Review(review_id) ON DELETE CASCADE,
    removal_reason TEXT,                  -- 删除原因
    removal_date DATE NOT NULL,           -- 删除日期
    removal_time TIME NOT NULL,           -- 删除时间
    PRIMARY KEY (staff_id, review_id)     -- 联合主键
);

---------------------------------------------------
-- 播放列表表 Playlist
-- 每个顾客的播放列表名字必须唯一
---------------------------------------------------
CREATE TABLE Playlist (
    playlist_id SERIAL PRIMARY KEY,       -- 播放列表ID (主键)
    customer_id INT NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    UNIQUE(customer_id, name)             -- 同一顾客不能有同名播放列表
);

---------------------------------------------------
-- 播放列表项 PlaylistItem
-- 表示某播放列表包含哪些歌曲，以及顺序
---------------------------------------------------
CREATE TABLE PlaylistItem (
    playlist_id INT NOT NULL REFERENCES Playlist(playlist_id) ON DELETE CASCADE,
    track_id INT NOT NULL REFERENCES Track(track_id) ON DELETE CASCADE,
    position INT NOT NULL,                -- 歌曲顺序
    PRIMARY KEY (playlist_id, track_id),
    UNIQUE(playlist_id, position)         -- 同一播放列表中顺序不能重复
);

---------------------------------------------------
-- 听歌记录 Listens_to
-- 顾客对某歌曲的收听次数
---------------------------------------------------
CREATE TABLE Listens_to (
    customer_id INT NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE,
    track_id INT NOT NULL REFERENCES Track(track_id) ON DELETE CASCADE,
    times INT DEFAULT 0,                  -- 收听次数
    PRIMARY KEY (customer_id, track_id)
);

---------------------------------------------------
-- 示例数据插入 (DML)
---------------------------------------------------

-- 插入专辑
INSERT INTO Album (release_date) VALUES ('2024-01-01');

-- 插入歌曲
INSERT INTO Track (title, duration, genre, album_id)
VALUES ('Song A', '00:03:45', 'Pop', 1);

-- 插入艺术家
INSERT INTO Artist (full_name, email, login_name, password, mobile_number)
VALUES ('Alice Smith', 'alice@example.com', 'alice123', 'pass123', '0400000000');

-- 艺术家参与歌曲
INSERT INTO Contributed (artist_id, track_id, role)
VALUES (1, 1, 'Singer');

-- 插入顾客
INSERT INTO Customer (full_name, email, login_name, password, mobile_number, age, birth_date)
VALUES ('Bob Lee', 'bob@example.com', 'bob123', 'pass456', '0411111111', 25, '2000-05-20');

-- 插入员工
INSERT INTO Staff (full_name, email, login_name, password, mobile_number, address, compensation)
VALUES ('Charlie Wu', 'charlie@example.com', 'charlie_staff', 'pass789', '0422222222', 'Sydney', 80000);

-- 顾客写评论
INSERT INTO Review (customer_id, track_id, rating, comment, created_date, created_time)
VALUES (1, 1, 5, 'Great song!', CURRENT_DATE, CURRENT_TIME);

-- 员工删除评论
INSERT INTO Remove (staff_id, review_id, removal_reason, removal_date, removal_time)
VALUES (1, 1, 'Inappropriate language', CURRENT_DATE, CURRENT_TIME);

-- 创建播放列表
INSERT INTO Playlist (customer_id, name) VALUES (1, 'My Favorites');

-- 添加歌曲到播放列表
INSERT INTO PlaylistItem (playlist_id, track_id, position) VALUES (1, 1, 1);

-- 顾客听歌次数
INSERT INTO Listens_to (customer_id, track_id, times) VALUES (1, 1, 10);
