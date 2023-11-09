--create dim user
CREATE TABLE dim_user (
    id INT PRIMARY KEY,
    username VARCHAR,
    country VARCHAR
);

-- insert data into dim user
INSERT INTO dim_user (id, username, country)
SELECT
    ru.user_id as id,
    ru.user_name as username,
    ru.country
FROM raw_users ru;


--create dim_post
CREATE TABLE dim_post(
    id INT PRIMARY KEY,
    post_text VARCHAR,
    post_date DATE,
    user_id INT,
    like_id INT,
    like_date DATE
);

-- insert data into dim post
INSERT INTO dim_post (id, post_text, post_date, user_id, like_id, like_date)
SELECT
    rp.post_id as id,
    rp.post_text,
    rp.post_date,
    rp.user_id,
    rl.like_id,
    rl.like_date
FROM raw_posts rp
FULL JOIN raw_likes rl 
    on rl.post_id = rp.post_id ;


-- create dim_date
CREATE TABLE dim_date (
    like_date DATE,
    post_date DATE
);

-- insert data into dim_date
INSERT INTO dim_date (like_date, post_date)
SELECT
    rp.post_date,
    rl.like_date
FROM raw_posts rp
LEFT JOIN raw_likes rl
    on rl.post_id = rp.post_id;

-- create fact tabel named fact_post_performance
CREATE TABLE fact_post_performance (
    user_id INT PRIMARY KEY,
    count_likes INT,
    count_post INT,
);

-- insert data into fact_post_performance
INSERT INTO fact_post_performance (user_id, count_likes, count_post)
SELECT
    ru.user_id,
    COUNT(rl.like_id) as count_likes,
    COUNT(rp.post_id) as count_post
FROM raw_users ru
LEFT JOIN raw_posts rp
    on rp.user_id=ru.user_id
LEFT JOIN raw_likes rl
    on rl.user_id=ru.user_id
GROUP BY ru.user_id;


-- create table named fact_daily_posts
CREATE TABLE fact_daily_posts (
    user_id INT PRIMARY KEY,
    number_of_post INT,
    post_date DATE
);

-- insert data into fact_daily_posts
INSERT INTO fact_daily_posts (user_id, number_of_post, post_date)
SELECT
    ru.user_id,
    COUNT(rp.post_id) as number_of_post,
    rp.post_date
FROM raw_users ru
LEFT JOIN raw_posts rp
    on rp.user_id=ru.user_id
GROUP BY ru.user_id;
