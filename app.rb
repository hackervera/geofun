require 'sinatra'
require 'typhoeus'
require 'json'

enable :sessions

authorize_url = "https://beta.geoloqi.com/oauth/authorize"
token_url = "https://api.geoloqi.com/1/oauth/token"
host = ENV["LOQIHOST"]
client_id, client_secret = ENV["LOQICLIENT"].split ":"
auth_redirect = "#{host}/auth"
token_redirect = "#{host}/token"

get "/" do
  unless session[:access_token]
    redirect "/request"
  end
  erb :main
end

get "/request" do

  #authorize_response = Typhoeus::Request.get("#{authorize_url}", :params => {:response_type => "code", :client_id => client_id, :redirect_uri => auth_redirect})
  response.redirect "#{authorize_url}?response_type=code&client_id=#{client_id}&redirect_uri=#{auth_redirect}"
end


get "/auth" do
  code = request.params["code"]
  token_response = Typhoeus::Request.post("#{token_url}", :params => {:grant_type => "authorization_code", :code => code, :redirect_uri => token_redirect, :client_id => client_id, :client_secret => client_secret})
  json_token = JSON.parse token_response.body
  access_token = json_token["access_token"]
  session[:access_token] = access_token
  redirect "/"
end

get "/location" do
  last_response = Typhoeus::Request.get("https://api.geoloqi.com/1/location/last?oauth_token=#{session[:access_token]}")
  last_json = JSON.parse last_response.body
  @lat = last_json["location"]["position"]["latitude"]
  @long =     last_json["location"]["position"]["longitude"]
  erb :location
end