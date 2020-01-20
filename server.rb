require 'sinatra'
require "sinatra/reloader" if development?
require 'open-uri'
require 'nokogiri'

set :bind, '0.0.0.0'

get '/' do
  @text = `python3 meatball.py`.strip
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
