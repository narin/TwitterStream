# Twitter Stream

## Technologies
* Python
* MySQL

## Installation
* Install the following python packages if you do not already have them:
```
$ pip install MySQL-python
$ pip install oauth2
```
* Update `TwitterStream.py` with your Twitter DEV Keys and Access Tokens
* Update `TwitterStream.py` with your MySQL db info
* Run `schema.sql` to create the MySQL db schema
* Run the script to start the TwitterStreamer
```
$ python TwitterStream.py
```

## Queries
The queries you requested can be found in `queries.sql`.

## Additional Considerations
If I needed to be able to search the bodies of the tweets for words, I would add a FULLTEXT index on the `tweet.text` column, which would make text search much faster, utilizing the `MATCH` comparison operator instead of `LIKE`.

## Notes
* The twitter streaming API sends back tweets very quickly.  Resolving a shortened URL takes some time, so in this script it is possible that we "fall behind" the speed of the streaming API.  This results in an IncompleteRead error, after which I restart the stream.  Since we are just using this stream as sample data, I didn't think it was important to stay 100% up to speed with the streaming API.  If I was required to do it though, one solution I thought of is putting the URL INSERT in an async method, which would allow us to keep up with the API.
* Emojis, which of course are commonly used in tweets, cause some issues inserting into MySQL by default. To solve this issue, I had to ensure that the character set for the database is `utf8mb4`, as well as specificaly set any columns which might contain emojies to this character set.
