#let Bundler handle all requires
require 'bundler'
Bundler.require(:default)

FB_APP_ID = '1465168160462768'
FB_APP_SECRET = '9920f20cfd4574e64cf61a82b726ccae'

use Rack::Session::Cookie, secret: '96a5699ca5c72572d9ee7ef8458c77e3cd0779fd6ba3ae15612db7221be1fe54070e53d037bab3eb06ac73438429cf2d39c1584754a69b6747025527c35f55bd'

get '/' do
  if session['access_token']
    graph = Koala::Facebook::API.new(session['access_token'])
    @profile = graph.get_object('me', fields: 'email')
  end
  erb :index
end

get '/login' do
  # generate a new oauth object with your app data and callback url
  session['oauth'] = Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET, "#{request.base_url}/callback")
  # redirect to facebook to get your code
  redirect session['oauth'].url_for_oauth_code(permissions: 'email')
end

get '/logout' do
  session['oauth'] = nil
  session['access_token'] = nil
  redirect '/'
end

#method to handle the redirect from facebook back to you
get '/callback' do
  #get the access token from facebook with your code
  session['access_token'] = session['oauth'].get_access_token(params[:code])
  redirect '/'
end
