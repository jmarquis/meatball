require 'open-uri'
require 'nokogiri'
require 'json'
require 'uri'
require 'net/https'

class BingError < StandardError
end

class MeatballEntity

  BING_KEY = 'aaf10f9661404d7a88e6ae5af6acdea7'
  BING_URI = 'https://api.cognitive.microsoft.com'
  BING_PATH = '/bing/v7.0/search'

  URL_BLACKLIST = [
    'youtube.com',
    'youtu.be',
    'quizlet.com'
  ]

  SENTENCE_BLACKLIST = [
    'masturbat',
    'fuck',
    'cunt',
    'panties',
  ]

  # Returns true if successful, false if not
  def self.learn term = nil
    tries = 0
    while tries < 10
      tries += 1

      begin
        final_term = term.nil? ? generate(120) : term
        results = search final_term
        result_key, result_url = choose_result results
        doc = fetch result_url
        text = scrape doc
        save result_key, text
      rescue BingError => e
        p "Error talking to Bing: #{e}"
        break
      rescue => e
        p "Oh no! #{e.message}"
        next
      end

      p 'Learn successful!'
      return true
    end

    p 'Learn failed!'
    return false
  end

  def self.generate len
    output = `python3 meatball.py #{len}`.strip
    raise 'Failed to generate a decent string.' if output.empty? || output == 'None' || SENTENCE_BLACKLIST.any? { |pattern| output.include?(pattern) }
    p "GENERATED: #{output}"
    output
  end

  def self.search term
    p "Searching for '#{term}' ..."

    request_url = URI(BING_URI + BING_PATH + "?q=" + URI.encode_www_form_component(term))
    request = Net::HTTP::Get.new(request_url)
    request['Ocp-Apim-Subscription-Key'] = BING_KEY

    response = Net::HTTP.start(request_url.host, request_url.port, use_ssl: request_url.scheme == 'https') do |http|
      http.request(request)
    end

    parsed_response = JSON(response.body)

    raise BingError, parsed_response['error']['message'] if parsed_response['error']

    JSON(response.body)['webPages']['value']
  end

  def self.choose_result results
    result_url = results.sample['url']
    result_key = result_url.gsub(/[^0-9A-Za-z]/, '')

    raise "Blacklisted! #{result_url}" if URL_BLACKLIST.any? { |pattern| result_url.include?(pattern) }
    raise "Already parsed! #{result_url}" if File::exist? "./sources/#{result_key}"

    return result_key, result_url
  end

  def self.fetch url
    p "Fetching #{url} ..."
    Nokogiri::HTML(OpenURI.open_uri(url))
  end

  def self.scrape doc
    text = ''
    doc.css('body').css('p, h1, h2, h3, h4, h5, h6').each do |txt|
      txtstring = txt.text
      txtstring.strip!
      period = ['.', ',', ';', '!', '?'].include?(txtstring[-1]) ? '' : '.'
      text += txtstring + period + "\n"
    end
    text
  end

  def self.save key, text
    Dir::mkdir('./sources') if !Dir::exist? './sources'
    File.write("./sources/#{key}.txt", text)
  end

end
