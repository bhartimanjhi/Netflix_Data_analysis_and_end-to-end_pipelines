SELECT * FROM netflix_raw
where show_id='s5023';
use master;

-- Handling Foreign characters

-- DROP TABLE netflix_raw;

create table netflix_raw (
    show_id VARCHAR(10),
    type VARCHAR(10),
    title NVARCHAR(200),
    director VARCHAR(250),
    cast varchar(1000),
    country varchar(150),
    date_added varchar(20),
    release_year int,
    rating varchar(20),
    duration varchar(10),
    listed_in varchar(10),
    description varchar(500)
);
ALTER TABLE netflix_raw MODIFY COLUMN listed_in VARCHAR(500);

-- Removing duplicates
select show_id, count(*) from netflix_raw
group by show_id
having count(*)>1;

alter table netflix_raw
add primary key(show_id);

CREATE TABLE netflix_stg AS
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY title, `type` ORDER BY show_id) AS rn
    FROM netflix_raw
)
SELECT 
    show_id,
    type,
    title,
    STR_TO_DATE(date_added, '%M %e, %Y') AS date_added,
    release_year,
    rating,
    CASE WHEN duration IS NULL THEN rating ELSE duration END AS duration,
    description
FROM cte;

select * from netflix_stg;


-- New table for listed in, director, country,cast
CREATE TABLE netflix_directors AS
WITH RECURSIVE split_cte AS (
    -- Step 1: Take entire director string
    SELECT 
        show_id,
        SUBSTRING_INDEX(director, ',', 1) AS director,
        SUBSTRING(director, LENGTH(SUBSTRING_INDEX(director, ',', 1)) + 2) AS remaining
    FROM netflix_raw

    UNION ALL

    -- Step 2: Keep splitting remaining values
    SELECT
        show_id,
        SUBSTRING_INDEX(remaining, ',', 1),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_cte
    WHERE remaining <> ''
)
SELECT 
    show_id,
    TRIM(director) AS director
FROM split_cte
WHERE director <> '';
select * from netflix_directors;


CREATE TABLE netflix_country AS
WITH RECURSIVE split_country AS (
    -- Step 1: split first country
    SELECT 
        show_id,
        SUBSTRING_INDEX(country, ',', 1) AS country,
        SUBSTRING(country, LENGTH(SUBSTRING_INDEX(country, ',', 1)) + 2) AS remaining
    FROM netflix_raw

    UNION ALL

    -- Step 2: split remaining
    SELECT
        show_id,
        SUBSTRING_INDEX(remaining, ',', 1),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_country
    WHERE remaining <> ''
)
SELECT 
    show_id,
    TRIM(country) AS country
FROM split_country
WHERE country <> '';

select * from netflix_country;



CREATE TABLE netflix_cast AS
WITH RECURSIVE split_cast AS (
    -- Step 1: split first cast member
    SELECT 
        show_id,
        SUBSTRING_INDEX(cast, ',', 1) AS cast_member,
        SUBSTRING(cast, LENGTH(SUBSTRING_INDEX(cast, ',', 1)) + 2) AS remaining
    FROM netflix_raw

    UNION ALL

    -- Step 2: keep splitting remaining
    SELECT
        show_id,
        SUBSTRING_INDEX(remaining, ',', 1),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_cast
    WHERE remaining <> ''
)
SELECT 
    show_id,
    TRIM(cast_member) AS cast_member
FROM split_cast
WHERE cast_member <> '';

select * from netflix_cast;


CREATE TABLE netflix_genre AS
WITH RECURSIVE split_genre AS (
    -- Step 1: split first genre
    SELECT 
        show_id,
        SUBSTRING_INDEX(listed_in, ',', 1) AS genre,
        SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS remaining
    FROM netflix_raw

    UNION ALL

    -- Step 2: split remaining genres
    SELECT
        show_id,
        SUBSTRING_INDEX(remaining, ',', 1),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_genre
    WHERE remaining <> ''
)
SELECT 
    show_id,
    TRIM(genre) AS genre
FROM split_genre
WHERE genre <> '';

select * from netflix_genre
order by show_id desc;

-- Populate missing values in country, duration, columns
CREATE TABLE net_country (
    director VARCHAR(255),
    country VARCHAR(255)
);

ALTER TABLE net_country 
CHANGE director show_id VARCHAR(50);

insert into net_country 
select show_id, m.country
from netflix_raw nr
inner join ( select director, country from netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director, country) m on nr.director=m.director
where nr.country is null;

select * from net_country;


-- netflix data analysis
/* 1. For each director, count the number of movies and TV shows created by them in separate columns,
   for directors who have created TV shows and movies both */
SELECT 
    nd.director,
    COUNT(DISTINCT CASE WHEN n.type = 'Movie' THEN n.show_id END) AS no_of_movies,
    COUNT(DISTINCT CASE WHEN n.type = 'TV Show' THEN n.show_id END) AS no_of_tvshows
FROM netflix_stg n
INNER JOIN netflix_directors nd 
    ON n.show_id = nd.show_id
GROUP BY nd.director
HAVING 
    COUNT(DISTINCT n.type) > 1;  

-- 2. top 3 countries have highest no. of comedy movies
select nc.country, count(distinct ng.show_id) as no_of_movies
from netflix_genre ng
inner join netflix_country nc on ng.show_id=nc.show_id
inner join netflix_stg n on ng.show_id=n.show_id
where ng.genre='Comedies' and n.type='Movie'
group by nc.country
order by no_of_movies desc
limit 3;

-- 3 for each year (as per date added to netflix), which director has maximum number of movies released
with cte as (
select nd.director, year(date_added) as date_year, count(n.show_id) as no_of_movies
from netflix_stg n
inner join netflix_directors nd on n.show_id=nd.show_id
where type='Movie'
group by nd.director, year(date_added)
)
select * ,
row_number() over(partition by date_year order by no_of_movies desc, director) as rn
from cte
order by date_year, no_of_movies desc;


-- 4 what is average duration of movies in each genre
SELECT 
    ng.genre,
    AVG(CAST(REPLACE(n.duration, ' min', '') AS UNSIGNED)) AS avg_duration
FROM netflix_stg n
INNER JOIN netflix_genre ng 
    ON n.show_id = ng.show_id
WHERE n.type = 'Movie'
GROUP BY ng.genre;

-- --5 find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them
SELECT 
    nd.director,
    SUM(CASE WHEN ng.genre = 'Comedies' THEN 1 ELSE 0 END) AS comedy_movies,
    SUM(CASE WHEN ng.genre = 'Horror Movies' THEN 1 ELSE 0 END) AS horror_movies
FROM netflix_stg n
INNER JOIN netflix_genre ng 
    ON n.show_id = ng.show_id
INNER JOIN netflix_directors nd 
    ON n.show_id = nd.show_id
WHERE n.type = 'Movie'
  AND ng.genre IN ('Comedies', 'Horror Movies')
GROUP BY nd.director
HAVING COUNT(DISTINCT ng.genre) = 2
order by director;

