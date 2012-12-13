require 'rubygems'
require 'bundler/setup'

set :views, settings.root + '/templates'

get '/' do
  erb :home
end
