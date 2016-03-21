import oauth2
import urllib2
import json
import httplib
import urlparse
import requests
import MySQLdb
import time

# Twitter API Keys for OAuth
consumer = oauth2.Consumer(
	key = '<INSERT CONSUMER KEY>',
	secret = '<INSERT CONSUMER SECRET>'
)
token = oauth2.Token(
	key = '<INSERT ACCESS TOKEN KEY>',
	secret = '<INSERT ACCESS TOKEN SECRET>'
)

# Twitter Streaming API endpoint
api_endpoint= "https://stream.twitter.com/1.1/statuses/sample.json"

# MySQL Connection Info
db = MySQLdb.connect(host="localhost",
					 user="root",
					 passwd="<INSERT PASSWORD>",
					 db="tweetstream")

cur = db.cursor()

db.set_character_set('utf8mb4')
cur.execute('SET NAMES utf8mb4')
cur.execute("SET CHARACTER SET utf8mb4")
cur.execute("SET character_set_connection=utf8mb4")


def getTweetStream():
	# Set up OAuth Request
	signature_method_hmac_sha1 = oauth2.SignatureMethod_HMAC_SHA1()
	oauth_request = oauth2.Request.from_consumer_and_token(
		consumer,
		token=token,
		http_method='GET',
		http_url=api_endpoint
	)
	oauth_request.sign_request(signature_method_hmac_sha1, consumer, token)

	# Execute request with error handling
	try:
		res = urllib2.urlopen(oauth_request.to_url())
		for r in res:
			tweet = json.loads(r)
			# All valid tweets should have an entities object
			if 'entities' in tweet:
				# We only care about tweets that contain URLs
				if tweet["entities"]["urls"]:
					insertTweet(tweet)

	except Exception:
		import traceback
		print('Generic exception: ' + traceback.format_exc())
		# There is occasionally an IncompleteRead error that occurs because we
		# are falling behind the stream speed due to the time it takes to
		# resolve the shortened URL and do a db insert.  In this case, we restart
		# the stream.
		print('Exception Occurred.  Attempting to continue...')
		getTweetStream()

def insertTweet(tweet):
	userid = tweet["user"]["id"]
	username = tweet["user"]["screen_name"]
	name = tweet["user"]["name"]
	profile_img_url = tweet["user"]["profile_image_url"]
	tweet_id = tweet["id"]
	tweet_text = tweet["text"]
	creation_datetime = time.strftime('%Y-%m-%d %H:%M:%S')

	# Insert User
	cur.execute(
		"INSERT IGNORE INTO user (id, username, name, profile_img_url, record_creation_datetime) VALUES (%s,%s,%s,%s,%s)", (userid, username, name, profile_img_url, creation_datetime)
	)

	# Insert Tweet
	cur.execute(
		"INSERT INTO tweet (id, text, user_id, record_creation_datetime) VALUES (%s,%s,%s,%s)", (tweet_id, tweet_text, userid, creation_datetime)
	)

	# Insert URLs
	for url in tweet["entities"]["urls"]:
		original_url = url["url"]
		resolved_url = unshorten_url(original_url)

		cur.execute(
			"INSERT INTO url (url, resolved_url, tweet_id, record_creation_datetime) VALUES (%s,%s,%s,%s)", (original_url, resolved_url, tweet_id, creation_datetime)
		)

	db.commit()

	print('Inserted Tweet: %s - %s' % (username, tweet_text))

def unshorten_url(url):
	try:
		resolved_url = requests.head(url, allow_redirects=True,timeout=5).url
		return resolved_url
	except Exception, e:
		print('Error Resolving URL.  Skipping...')
		return ''

if __name__ == '__main__':
	getTweetStream()
