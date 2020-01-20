require 'nokogiri'
require 'json'
require 'uri'
require 'net/https'
require 'pry'
require 'open-uri'

key = 'aaf10f9661404d7a88e6ae5af6acdea7'
uri = 'https://api.cognitive.microsoft.com'
path = '/bing/v7.0/search'

blacklist = [
  'youtube.com',
  'youtu.be',
  'quizlet.com'
]

# get a search string
term = `python3 meatball.py`
term.strip!
term = 'wint dril' if term.empty?

# get search results
uri = URI(uri + path + "?q=" + URI.encode_www_form_component(term))
request = Net::HTTP::Get.new(uri)
request['Ocp-Apim-Subscription-Key'] = key
response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(request)
end

# load a random one and parse it
result_url = JSON(response.body)['webPages']['value'].sample['url']
p "Parsing #{result_url}..."
if blacklist.any? { |blacklisted_term| result_url.include?(blacklisted_term) }
  p 'Blacklisted!'
  exit
end
doc = Nokogiri::HTML(OpenURI.open_uri(result_url))

text = ''
doc.css('body').css('p, h1, h2, h3, h4, h5, h6').each do |txt|
  txtstring = txt.text
  txtstring.strip!
  period = txtstring[-1] == '.' ? '' : '.'
  text += txtstring + period + "\n"
end

result_key = result_url.gsub(/[^0-9A-Za-z]/, '')

# write it to the sources
File.write("./sources/#{result_key}.txt", text)

p 'Done!'
