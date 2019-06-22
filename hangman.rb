require 'sinatra'

get '/' do

  locals = {:message => message}

  erb :index, :locals => locals
end