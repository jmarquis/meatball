require 'sinatra'
require "sinatra/reloader" if development?
require 'open-uri'
require 'nokogiri'
require 'json'
require 'uri'
require 'net/https'

set :bind, '0.0.0.0'

get '/' do
  @text = `python3 meatball.py 280`.strip
  p @text
  erb :index
end

get '/test' do
  doc = Nokogiri::HTML(OpenURI.open_uri(params[:q]))

  text = ''
  doc.css('body').css('p, h1, h2, h3, h4, h5, h6').each do |txt|
    txtstring = txt.text
    txtstring.strip!
    period = txtstring[-1] == '.' ? '' : '.'
    text += txtstring + period + "<br>"
  end
  text
end

get '/learn' do

  @term = params[:term]
  if !Dir::exist? './sources'
    if @term.nil? || @term.empty?
      return erb :initial
    end

    Dir::mkdir './sources'
  end

  key = 'aaf10f9661404d7a88e6ae5af6acdea7'
  uri = 'https://api.cognitive.microsoft.com'
  path = '/bing/v7.0/search'

  blacklist = [
    'youtube.com',
    'youtu.be',
    'quizlet.com'
  ]

  tries = 0

  while true

    tries += 1
    if tries > 10
      return erb :fail
    end

    @term = params[:term] || ''

    # get a search string
    if @term.nil? || @term.empty?
      @term = `python3 meatball.py 60`
      @term.strip!

      next if @term == 'None'
      return erb :initial if @term == ''
    end

    p "Searching for '#{@term}' ..."

    # get search results
    uri = URI(uri + path + "?q=" + URI.encode_www_form_component(@term))
    request = Net::HTTP::Get.new(uri)
    request['Ocp-Apim-Subscription-Key'] = key
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    # pick a random one
    begin
      results = JSON(response.body)['webPages']['value']
      random_result = results.sample
      @result_url = random_result['url']
    rescue => e
      p e.message
      p JSON(response.body)
      next
    end

    result_key = @result_url.gsub(/[^0-9A-Za-z]/, '')

    if blacklist.any? { |pattern| @result_url.include?(pattern) }
      p "Blacklisted! #{@result_url}"
      next
    end

    if File::exist? "./sources/#{result_key}"
      p "Already parsed! #{@result_url}"
      next
    end

    begin
      # fetch and parse
      p "Fetching #{@result_url} ..."
      doc = Nokogiri::HTML(OpenURI.open_uri(@result_url))
    rescue e
      p e.message
      next
    end

    break

  end

  text = ''
  doc.css('body').css('p, h1, h2, h3, h4, h5, h6').each do |txt|
    txtstring = txt.text
    txtstring.strip!
    period = txtstring[-1] == '.' ? '' : '.'
    text += txtstring + period + "\n"
  end

  # write it to the sources
  File.write("./sources/#{result_key}.txt", text)

  if params[:term]
    return redirect '/learn'
  end

  erb :learn

end
