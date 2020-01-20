require 'twitter'
require_relative 'entity'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "zWXYgNpw0vc0xVL1k8Wo5lbHF"
  config.consumer_secret     = "iSVYYLYUDqA3uognR8tkJd1GDRJxt9EyUFOGejBLCxTXbRyWL5"
  config.access_token        = "1219380938980909059-dctgC2WxyiCg4A5lWrXtM4Pmcw2gvN"
  config.access_token_secret = "BVVBaHtEL8ujF6daVaygCAoknPBknQgJhqrMbKaGJ8hwJ"
end

tweet = MeatballEntity.generate 280
p "TWEETING: #{tweet}"

client.update tweet
