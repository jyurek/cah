require 'rubygems'
require 'bundler'
Bundler.require

use Rack::Static, :urls => ['/css', '/js', '/images'], :root => 'public'
set :views, File.dirname(__FILE__) + '/templates'

get '/' do
  erb :home
end
