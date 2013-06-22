#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'rubygems'
require 'sinatra'
require 'helpers/application_helper'
require 'helpers/image_helper'
require 'helpers/twitter_helper'
require 'helpers/url_helper'

configure do
  enable :sessions

  set :public_folder, Proc.new { File.join(root, "static") }

  set :flickr_api_key, ENV['FLICKR_API_KEY']
  set :flickr_secret, ENV['FLICKR_SECRET']
  set :flickr_access_token, ENV['FLICKR_ACCESS_TOKEN']
  set :flickr_access_secret, ENV['FLICKR_ACCESS_SECRET']
end

get '/' do
  haml :index, :locals => {
    :random_photo_url1 => flickr.random_photo_url,
    :random_photo_url2 => flickr.random_photo_url,
    :random_photo_url3 => flickr.random_photo_url }
end

post '/upload_from_mobile' do
  tempfile = params['photo'][:tempfile]
  file_name = tempfile.path

  resize(file_name)

  photo_id = flickr.upload file_name
  flickr.set_coordinates(photo_id, params[:latitude], params[:longitude])

  status(200)
end

post '/upload' do
  unless is_an_image? params[:photo]
    session[:error] = "Por favor, insira uma imagem"
    redirect '/'
  end

  tempfile = params['photo'][:tempfile]
  file_name = tempfile.path

  user_img = resize(file_name)

  photo = add_logo(user_img, params[:color_scheme])
  photo.write(file_name)

  photo_id = flickr.upload file_name
  session['set_coordinates'] = true

  redirect "/show/#{photo_id}"
end

get '/show/:photo_id' do
  haml :show, :locals => { :photo_url => flickr.photo_url(params[:photo_id]),
                           :photo_id => params[:photo_id],
                           :set_coordinates => session['set_coordinates'],
                           :random_photo_url1 => flickr.random_photo_url,
                           :random_photo_url2 => flickr.random_photo_url,
                           :random_photo_url3 => flickr.random_photo_url }
end

post '/coordinates/:photo_id/:latitude/:longitude' do
  flickr.set_coordinates(params[:photo_id], params[:latitude], params[:longitude])
end

get '/max_width' do
  content_type :json
  max_width_for(params[:width].to_i, params[:height].to_i, params[:banner_name]).to_json
end

get '/stylesheets/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end
