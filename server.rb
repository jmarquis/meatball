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
