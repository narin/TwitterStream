# Most Popular URL in last 60 min
SELECT t.resolved_url,
	   COUNT(t.resolved_url) AS 'Occurences'
FROM (SELECT resolved_url, record_creation_datetime
      FROM tweetstream.url
      WHERE record_creation_datetime > CURRENT_TIMESTAMP - INTERVAL 1 HOUR
		AND resolved_url <> '') t
GROUP BY resolved_url
ORDER BY COUNT(t.resolved_url) DESC
LIMIT 1

# User with the most tweets in the last 30 min
SELECT t.user_id,
	   u.username,
	   COUNT(t.user_id) AS 'Tweets'
FROM (SELECT user_id, record_creation_datetime
      FROM tweetstream.tweet
      WHERE record_creation_datetime > CURRENT_TIMESTAMP - INTERVAL 1 HOUR) t
JOIN tweetstream.user u on t.user_id = u.id
GROUP BY t.user_id
ORDER BY COUNT(t.user_id)  DESC
LIMIT 1

# Number of occurances of 'http://en.wikipedia.org'
select COUNT(*)
FROM tweetstream.url
WHERE resolved_url LIKE 'http://en.wikipedia.org%'

# Users who have tweeted a link to 'http://en.wikipedia.org' in the last 48 hours
SELECT us.id, us.username, ur.resolved_url
FROM tweetstream.url ur
JOIN tweetstream.tweet t on ur.tweet_id = t.id
JOIN tweetstream.user us on t.user_id = us.id
WHERE resolved_url LIKE 'http://en.wikipedia.org%'
	AND ur.record_creation_datetime > CURRENT_TIMESTAMP - INTERVAL 48 HOUR
