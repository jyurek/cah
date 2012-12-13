require 'rubygems'
require 'bundler/setup'
require 'sinatra'

use Rack::Static, :urls => ['/css', '/js', '/images'], :root => 'public'
set :views, settings.root + '/templates'

get '/' do
  erb :home
end
