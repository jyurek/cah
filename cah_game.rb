require 'rubygems'
require 'bundler'
Bundler.require

class CahGame < Sinatra::Base
  register Sinatra::JstPages
  serve_jst '/js/jst.js'

  set :views, File.dirname(__FILE__) + '/templates'

  get '/' do
    erb :home
  end
end
