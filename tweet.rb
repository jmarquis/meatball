require 'twitter'
require_relative 'entity'

if rand.round(2) == 1

  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  tweet = MeatballEntity.generate 280
  p "TWEETING: #{tweet}"

  client.update tweet

  p 'Tweet successful!'

else
  p 'No tweet this time around.'
end
