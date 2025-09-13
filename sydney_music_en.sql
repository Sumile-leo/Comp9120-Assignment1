-- ===================================================
-- COMP9120 Assignment 1 Database Design (Sydney Music)
-- English comments
-- ===================================================

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
-- Album table
---------------------------------------------------
CREATE TABLE Album (
    album_id SERIAL,
    release_date DATE NOT NULL,
    CONSTRAINT pk_album PRIMARY KEY (album_id)
);

---------------------------------------------------
-- Track table
---------------------------------------------------
CREATE TABLE Track (
    track_id SERIAL,
    title VARCHAR(200) NOT NULL,
    duration INTERVAL NOT NULL,
    genre VARCHAR(100) NOT NULL,
    album_id INT NOT NULL,
    CONSTRAINT pk_track PRIMARY KEY (track_id),
    CONSTRAINT fk_track_album FOREIGN KEY (album_id) REFERENCES Album(album_id) ON DELETE CASCADE
);

---------------------------------------------------
-- Artist table
---------------------------------------------------
CREATE TABLE Artist (
    artist_id SERIAL,
    full_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    login_name VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(50),
    CONSTRAINT pk_artist PRIMARY KEY (artist_id),
    CONSTRAINT uq_artist_login UNIQUE (login_name)
);

---------------------------------------------------
-- Contributed relationship (Artist ↔ Track)
---------------------------------------------------
CREATE TABLE Contributed (
    artist_id INT NOT NULL,
    track_id INT NOT NULL,
    role VARCHAR(100) NOT NULL,
    CONSTRAINT pk_contributed PRIMARY KEY (artist_id, track_id),
    CONSTRAINT fk_contributed_artist FOREIGN KEY (artist_id) REFERENCES Artist(artist_id) ON DELETE CASCADE,
    CONSTRAINT fk_contributed_track FOREIGN KEY (track_id) REFERENCES Track(track_id) ON DELETE CASCADE
);

---------------------------------------------------
-- Customer table
---------------------------------------------------
CREATE TABLE Customer (
    customer_id SERIAL,
    full_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    login_name VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(50),
    age INT,
    birth_date DATE,
    CONSTRAINT pk_customer PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_login UNIQUE (login_name),
    CONSTRAINT ck_customer_age CHECK (age >= 0)
);

---------------------------------------------------
-- Staff table
---------------------------------------------------
CREATE TABLE Staff (
    staff_id SERIAL,
    full_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    login_name VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(50),
    address VARCHAR(300),
    compensation NUMERIC,
    CONSTRAINT pk_staff PRIMARY KEY (staff_id),
    CONSTRAINT uq_staff_login UNIQUE (login_name),
    CONSTRAINT ck_staff_comp CHECK (compensation > 0 AND compensation <= 200000)
);

---------------------------------------------------
-- Review table
---------------------------------------------------
CREATE TABLE Review (
    review_id SERIAL,
    customer_id INT NOT NULL,
    track_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    created_date DATE NOT NULL,
    created_time TIME NOT NULL,
    CONSTRAINT pk_review PRIMARY KEY (review_id),
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_track FOREIGN KEY (track_id) REFERENCES Track(track_id) ON DELETE CASCADE,
    CONSTRAINT ck_review_rating CHECK (rating BETWEEN 1 AND 5)
);

---------------------------------------------------
-- Remove relationship (Staff ↔ Review)
---------------------------------------------------
CREATE TABLE Remove (
    staff_id INT NOT NULL,
    review_id INT NOT NULL,
    removal_reason TEXT,
    removal_date DATE NOT NULL,
    removal_time TIME NOT NULL,
    CONSTRAINT pk_remove PRIMARY KEY (staff_id, review_id),
    CONSTRAINT fk_remove_staff FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE CASCADE,
    CONSTRAINT fk_remove_review FOREIGN KEY (review_id) REFERENCES Review(review_id) ON DELETE CASCADE
);

---------------------------------------------------
-- Playlist table
---------------------------------------------------
CREATE TABLE Playlist (
    playlist_id SERIAL,
    customer_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    CONSTRAINT pk_playlist PRIMARY KEY (playlist_id),
    CONSTRAINT fk_playlist_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    CONSTRAINT uq_playlist_name UNIQUE (customer_id, name)
);

---------------------------------------------------
-- PlaylistItem table (playlist-track mapping with order)
---------------------------------------------------
CREATE TABLE PlaylistItem (
    playlist_id INT NOT NULL,
    track_id INT NOT NULL,
    position INT NOT NULL,
    CONSTRAINT pk_playlistitem PRIMARY KEY (playlist_id, track_id),
    CONSTRAINT fk_playlistitem_playlist FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id) ON DELETE CASCADE,
    CONSTRAINT fk_playlistitem_track FOREIGN KEY (track_id) REFERENCES Track(track_id) ON DELETE CASCADE,
    CONSTRAINT uq_playlistitem_position UNIQUE (playlist_id, position)
);

---------------------------------------------------
-- Listens_to table (Customer ↔ Track with times)
---------------------------------------------------
CREATE TABLE Listens_to (
    customer_id INT NOT NULL,
    track_id INT NOT NULL,
    times INT DEFAULT 0,
    CONSTRAINT pk_listens PRIMARY KEY (customer_id, track_id),
    CONSTRAINT fk_listens_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_listens_track FOREIGN KEY (track_id) REFERENCES Track(track_id) ON DELETE CASCADE
);
