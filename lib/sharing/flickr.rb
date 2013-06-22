require 'flickraw'

module Sharing
  class Flickr
    def initialize(api_key, secret, access_token, access_secret)
      FlickRaw.api_key = api_key
      FlickRaw.shared_secret = secret
      @access_token = access_token
      @access_secret = access_secret
    end

    def upload(file_name)
      client.upload_photo file_name, :is_public => true, :title => 'Change brazil!', :tags => 'changebrazil'
    end

    def set_coordinates(photo_id, latitude, longitude)
      return if latitude.nil? || longitude.nil?
      client.photos.geo.setLocation :photo_id => photo_id,
                                    :lat => latitude.to_f,
                                    :lon => longitude.to_f
    end

    def random_photo_url
      @photos ||= client.photos.search(:user_id => "97874346@N07")
      photo = @photos.photo[Random.rand(@photos.count)]
      FlickRaw.url_b(photo)
    end

    def photo_url(photo_id)
      info = client.photos.getInfo(:photo_id => photo_id)
      FlickRaw.url_b(info)
    end

    private

    def client
      unless @client
        @client ||= FlickRaw::Flickr.new
        @client.access_token = @access_token
        @client.access_secret = @access_secret
      end
      @client
    end
  end
end
