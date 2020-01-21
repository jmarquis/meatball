require 'sinatra'
require "sinatra/reloader" if development?
require 'open-uri'
require 'nokogiri'
require 'json'
require 'uri'
require 'net/https'
require_relative 'entity'

set :bind, '0.0.0.0'

get '/' do

  if !params[:url].nil?
    begin
      result_key = params[:url].gsub(/[^0-9A-Za-z]/, '')
      doc = MeatballEntity.fetch params[:url]
      text = MeatballEntity.scrape doc
      MeatballEntity.save result_key, text
      return redirect '/'
    rescue
      return erb :fail
    end
  end

  if !params[:term].nil?
    if MeatballEntity.learn params[:term]
      return redirect '/'
    else
      return erb :fail
    end
  end

  tries = 0
  while tries < 10
    tries += 1
    @text = ''

    begin
      @text = MeatballEntity.generate 280
      return erb :index
    rescue
      next
    end

  end

  erb :initial

end
