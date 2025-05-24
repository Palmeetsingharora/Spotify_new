SELECT * FROM public.spotify
LIMIT 100


--EXPLORATORY DATA ANALYSIS(EDA):

--HOW MANY ROWS ARE IN THE DATASET:
SELECT COUNT(*)
FROM spotify;

--NUMBER OF UNIQUE ARTIST:
SELECT COUNT(DISTINCT artist)
FROM spotify;

--NUMBER OF UNIQUE ALBUMS:
SELECT COUNT(DISTINCT album)
FROM spotify;

--NUMBER OF UNIQUE Album Type:
SELECT COUNT(DISTINCT album_type)
FROM spotify;

--Types of Albums:
SELECT DISTINCT album_type
FROM spotify;

--What is the Maximum Duration of a song:
SELECT MAX(duration_min)
FROM spotify;

--What is the Minimum Duration of a song:
SELECT MIN(duration_min)
FROM spotify;

--What is the Average Duration of a song:
SELECT AVG(duration_min)
FROM spotify;

--Now checking what all songs have 0 min duration:
SELECT *
FROM spotify
where duration_min='0';

--Removing these min duration songs which have a duration of 0:
DELETE FROM spotify
WHERE duration_min='0';

--Checking again After DELETING:
SELECT *
FROM spotify
where duration_min='0';

--HOW Many total channels we have?
SELECT count(DISTINCT channel) 
FROM spotify;

--What are the top 10 tracks played?
SELECT track
FROM spotify
LIMIT 10;

--Which is the most used platform for playing songs?
SELECT DISTINCT most_playedon
from spotify;

select stream from spotify

--DATA ANALYSIS:
-------------------------------------------------------------------------
--Retrieve the names of all tracks that have more than 1 billion streams?
SELECT track
from spotify 
where stream>1000000000

--List all the albums along with their respective artists:?
select Distinct album, artist
from spotify;

--Get the total number of comments for the tracks where licensed='True'
SELECT sum(comments), track
from spotify
where licensed='True'
group by track;

--Find all the tracks that belongs to the album type single?
SELECT track
FROM spotify
WHERE album_type='single'

--Count the total number of tracks by each artist?
SELECT count(track), artist
FROM spotify
group by artist
order by artist;

--calculate the average danceability of tracks in each album?
SELECT AVG(danceability), album
FROM spotify
group by album
ORDER BY 1 DESC;

--Find the top 5 tracks with the highest energy value:
SELECT DISTINCT track, MAX(energy) as highest_energy
FROM spotify 
GROUP BY track
ORDER BY 2 DESC
limit 5;

--List all thee tracks along with their views and likes where official_video='True'
SELECT 
	DISTINCT track, 
	SUM(views) as total_views,
	SUM(likes) AS total_likes
	from spotify
where official_video='True'
GROUP BY track;

--For each album, calculate the total views of all associated tracks
SELECT DISTINCT album, sum(views) as total_views, track
from spotify
group by album, track;


--Retrieve the track names that have been streamed on spotify more than Youtube:
select * from 
(select DISTINCT track, stream, most_playedon,

	COALESCE(SUM(CASE WHEN most_playedon='Youtube' THEN stream END),0) AS streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_playedon='Spotify' THEN stream END),0)AS streamed_on_spotify

from spotify
GROUP BY track, stream,most_playedon
) as p1
where 
	streamed_on_youtube>streamed_on_spotify
	AND
	streamed_on_youtube<>0;



--fIND THE TOP 3 MOST VIEWED TRACKS FOR EACH ARTIST USING WINDOW FUNCTIONS:

WITH ranking_artist
AS
(SELECT artist, track, sum(views) as total_views,
DENSE_RANK() OVER(PARTITION BY artist order by sum(views) desc) as rank
from spotify
GROUP BY artist, track
ORDER BY artist, 3 DESC

)
SELECT * FROM ranking_artist 
where rank<=3;

--Write a query to find the tracks where the liveness score is above average:

select track, artist from spotify
where liveness>(SELECT avg(liveness) FROM spotify)

--Use a WITH(CTE) clause to calculate the diffference between the highest and lowest energy values for tracks in each album.
WITH CTE
AS
(
SELECT album,MAX(energy) as max_ener, MIN(energy) as min_ener
FROM spotify
GROUP BY album
)
SELECT album, max_ener - min_ener as difference_energy
from CTE;
--

--WHO ARE THE MOST PLAYED ARTIST :
select artist, duration_min
from spotify
order by duration_min desc
limit 30;

-- Who are the Top Artists by Total Streams and Average Engagement:
SELECT artist, 
SUM(stream) AS total_stream, 
AVG(duration_min),
COUNT(DISTINCT track) AS total_track,
SUM(views) AS total_views,
SUM(likes) AS total_likes,
sum(comments) AS total_comments
FROM spotify
GROUP BY artist
ORDER BY total_stream DESC
LIMIT 10;


--Checking Correlation between are more energetic songs are more liked by listners;

SELECT ROUND(CORR(energy, likes)::NUMERIC, 2) AS corr_ener_lik
FROM spotify;

--Checking Correlation between are more loudness songs gives more energy to listners;
SELECT ROUND(CORR(loudness, energy)::NUMERIC,2) AS corr_loud_pref
FROM spotify;

--In which song should we invest for the music video investment?
SELECT 
    track, 
    artist, 
    stream, 
    views, 
    likes, 
    comments,
    ROUND(((likes + comments) / NULLIF(views, 0))::NUMERIC, 4) AS engagement_score
FROM spotify
WHERE official_video = 'False'
ORDER BY stream DESC, engagement_score DESC
LIMIT 10;

---END OF THE PROJECT