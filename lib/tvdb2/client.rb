require 'httparty'
require 'uri'
require 'memoist'
require 'tvdb2/request_error'
require 'tvdb2/tvdb_struct'
require 'tvdb2/api'

# Module that works like a namespace of the library.
# @author Enrico Pilotto
module Tvdb2

  # This class works as a client to retrieve data from TVDB json api version 2.
  # Make http requests to
  # [https://api.thetvdb.com](https://api.thetvdb.com/swagger).
  #
  # This class cache all http requests so only the first time a request is made
  # ([Memoist gem](https://github.com/matthewrudy/memoist) is used).
  # @see https://api.thetvdb.com/swagger TVDB api version 2 documentation
  class Client

    # The language in which you want get data.
    # @example
    #   got = client.best_search('Game of Thrones')
    #   puts got.name         # print 'Game of Thrones'
    #   client.language = :it # change language to italian
    #   got.series!           # make a request to get new data
    #   puts got.name         # print 'Il Trono di Spade'
    attr_accessor :language

    extend Memoist
    include HTTParty
    base_uri 'https://api.thetvdb.com'

    include Tvdb2::API

    # Create an object client. Take 2 keyword arguments:
    #
    # @param [String] apikey your tvdb apikey (you can get one at
    #   https://thetvdb.com/?tab=apiregister). Required.
    # @param [Symbol, String] language the language in which you want get data.
    #   You can change later. Optional. Default is `nil` that is `EN`.
    def initialize(apikey: '6F6E61197C18C895', language: nil)
      @language = language
      response = post('/login', apikey: apikey)
      raise RequestError.new(response) if response.code != 200
      @token = response.parsed_response['token']
    end

    # Refresh your api token.
    #
    # @return [String] the new token
    def refresh_token!
      response = get('/refresh_token')
      raise RequestError.new(response) if response.code != 200
      @token = response['token']
      return @token
    end

    # Inside the block change the language in which you want get data.
    #
    # @example
    #   got = client.best_search('Game of Thrones')
    #   client.with_language(:it) do |c|
    #     ep = got['1x1'] # Get episode data in italian
    #     puts ep.name    # print the title of episode 1x1 in italian
    #   end
    #   ep = got['1x1']   # Get episode data in default language
    #   puts ep.name      # print the title of episode 1x1 in english
    #
    # @param [Symbol, String] locale the language in which you want get data.
    # @yield block called with the selected language.
    def with_language(locale, &block)
      tmp_language = @language
      @language = locale.to_s
      block.call(self)
      @language = tmp_language
    end


    # Helper method to get the full url of an image from the relative path
    # retrieved from api.
    #
    # @example
    #   got = client.best_search('Game of Thrones')
    #   puts got.posters.first.fileName # posters/121361-1.jpg
    #   puts TVDB.image_url(got.posters.first.fileName) # http://thetvdb.com/banners/posters/121361-1.jpg
    #   # or
    #   puts got.posters.first.fileName_url # http://thetvdb.com/banners/posters/121361-1.jpg
    #
    # @param [String] path the relative path of an image.
    # @return [String] the complete url of the image.
    def self.image_url(path)
      URI::join("https://thetvdb.com/banners/", path).to_s
    end

    protected

    # :nodoc:
    # language param is required to invalidate memoist cache on different language
    def get(path, params = {}, language = @language)
      self.class.get(URI.escape(path), headers: build_headers, query: params)
    end
    memoize :get

    # :nodoc:
    def post(path, params = {}, language = @language)
      self.class.post(URI.escape(path), headers: build_headers, body: params.to_json)
    end
    memoize :post

    # :nodoc:
    def build_result(path, params = {}, return_type = nil, &block)
      response = get(path, params, @language)
      if response.code === 200
        return block.call(response['data'])
      elsif response.code === 404
        return return_type
      else
        raise RequestError.new(response)
      end
    end

    # :nodoc:
    def build_object_result(path, params = {}, klass = TvdbStruct)
      build_result(path, params, nil) do |data|
        klass.new(self, data)
      end
    end

    # :nodoc:
    def build_array_result(path, params = {}, klass = TvdbStruct)
      build_result(path, params, []) do |data|
        data.map{|x| klass.new(self, x)}
      end
    end

    private

    # :nodoc:
    def build_headers
      headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
      headers.merge!('Accept-Language': @language.to_s) if @language
      headers.merge!('Authorization': "Bearer #{@token}") if @token
      return headers
    end

  end
end

# Alias of {Client}
TVDB = Tvdb2::Client
