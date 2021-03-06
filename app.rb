# let Bundler handle all requires
require 'bundler'
Bundler.require(:default)

require './lib/whitelist'
require './lib/mc_client'

use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET'] || raise('no COOKIE_SECRET')

get '/' do
  if session['access_token']
    graph = Koala::Facebook::API.new(session['access_token'])
    @profile = graph.get_object('me', fields: 'email')
    @profile['authorized'] = Whitelist::exists?(@profile['email'])
  end
  erb :index
end

get '/login' do
  # generate a new oauth object with your app data and callback url
  session['oauth'] = Koala::Facebook::OAuth.new(ENV['FB_APP_ID'], ENV['FB_APP_SECRET'], "#{request.base_url}/fb_callback")
  # redirect to facebook to get your code
  redirect session['oauth'].url_for_oauth_code(permissions: 'email')
end

get '/logout' do
  session['oauth'] = nil
  session['access_token'] = nil
  redirect '/'
end

# method to handle the redirect from facebook back to you
get '/fb_callback' do
  # TODO handle various responses
  # get the access token from facebook with your code
  session['access_token'] = session['oauth'].get_access_token(params[:code])
  redirect '/'
end

get '/mc_api/:cmd' do
  if session['access_token']
    graph = Koala::Facebook::API.new(session['access_token'])
    @profile = graph.get_object('me', fields: 'email')
    if Whitelist::exists?(@profile['email'])
      mc_response = McClient::send(params['cmd'])
      if mc_response.nil?
        halt 408
      else
        return mc_response
      end
    end
  end
  halt 403
end
