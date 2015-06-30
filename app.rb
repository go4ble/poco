# let Bundler handle all requires
require 'bundler'
Bundler.require(:default)

use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET'] || raise('no COOKIE_SECRET')

get '/' do
  if session['access_token']
    graph = Koala::Facebook::API.new(session['access_token'])
    @profile = graph.get_object('me', fields: 'email')
  end
  erb :index
end

get '/login' do
  # generate a new oauth object with your app data and callback url
  session['oauth'] = Koala::Facebook::OAuth.new(ENV['FB_APP_ID'], ENV['FB_APP_SECRET'], "#{request.base_url}/callback")
  # redirect to facebook to get your code
  redirect session['oauth'].url_for_oauth_code(permissions: 'email')
end

get '/logout' do
  session['oauth'] = nil
  session['access_token'] = nil
  redirect '/'
end

# method to handle the redirect from facebook back to you
get '/callback' do
  # get the access token from facebook with your code
  session['access_token'] = session['oauth'].get_access_token(params[:code])
  redirect '/'
end
