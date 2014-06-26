# Description:
#   Pokemon fun!
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   pokefact - get a random pokefact!
#
# Author:
#   eliperkins


getTwitterToken = (key, secret, callback) =>
  console.log "Attempting to get token"
  grant_type=client_credentials

  auth_header = new Buffer("#{encodeURIComponent key}:#{encodeURIComponent secret}").toString('base64')
  console.log "Twitter auth header:" + auth_header
  payload = 'grant_type=client_credentials'

  msg.http('https://api.twitter.com/oauth2/token')
    .header('Authorization', "Basic #{auth_header}")
    .header('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8')
    .post payload, (err, res, body) ->
      console.log "twitter response:"
      console.log res

      return callback err if err or not res.data.access_token
      callback null, res.data.access_token

module.exports = (robot) ->

  robot.respond /pokefact/i, (msg) ->

    unless key = env.process.TWITTER_API_KEY
      return msg.reply "Missing TWITTER_API_KEY env variable"

    unless secret = env.process.TWITTER_API_SECRET
      return msg.reply "Missing TWITTER_API_SECRET env variable"

    # Token is not required, will go get one if needed
    unless process.env.TWITTER_BEARER_TOKEN
      getTwitterToken secret, key, (err, token) ->
        if err
          return msg.reply "Failed to authenticate to Twitter API."

        msg.http('https://api.twitter.com/1.1/statuses/user_timeline.json')
          .header('Authorization', "Bearer #{token}")
          .header('Accept-Encoding': 'gzip')
          .get (err, res, body) ->
            console.log "Got tweets!"
            console.log "response:"
            console.log res
            console.log "body:"
            console.log body

#
#     msg.http('https://api.twitter.com/1/statuses/user_timeline.json')
#       .query(screen_name: 'pokefacts', count: 100)
#       .get() (err, res, body) ->
#         tweets = JSON.parse(body)
#         msg.send tweets.length
#         if tweets? and tweets.length > 0
#           tweet = msg.random tweets
#           while(tweet.text.toLowerCase().indexOf('#pokefact') == -1)
#             tweet = msg.random tweets
#           msg.send "PokeFACT: " + tweet.text.replace(/\#pokefact/i, "");
#         else
#           msg.reply "Couldn't find a PokeFACT"
