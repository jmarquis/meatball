exit unless rand.round(3) > 0.995

require 'tweetkit'
require_relative 'entity'

client = Tweetkit::Client.new do |config|
  config.bearer_token = ENV['BEARER_TOKEN']
  config.consumer_key = ENV['API_KEY']
  config.consumer_secret = ENV['API_KEY_SECRET']
  config.access_token = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

tweet = MeatballEntity.generate 280
p "TWEETING: #{tweet}"

client.post_tweet(text: tweet)

p 'Tweet successful!'
