require 'ostruct'

module Tvdb2
  # OpenStruct that define `_url` methods to get url from images relative paths
  # returned from api.
  #
  # @example
  #   got = client.best_search('Game of Thrones')
  #   puts got.posters.first.fileName     # print relative path posters/121361-1.jpg
  #   puts got.posters.first.fileName_url # print url https://thetvdb.com/banners/posters/121361-1.jpg
  class TvdbStruct < OpenStruct

    # @param [Client] tvdb a TVDB api client. Only to compatibily with {Client}
    #   and {Episode} constructor.
    # @param [Hash] hash the optional hash, if given, will generate attributes
    #   and values (can be a Hash, an OpenStruct or a Struct).
    #
    # @note You should never need to create this object manually.
    def initialize(tvdb = nil, hash = {})
      super(hash)
    end

    # @!parse
    #  # @return [String] the url string of relative image path stored in
    #  #  `image` field. `nil` if `image` field is `nil`.
    #  def image_url; end
    #  # @return [String] the url string of relative image path stored in
    #  #  `fileName` field. `nil` if `fileName` field is `nil`.
    #  def fileName_url; end
    #  # @return [String] the url string of relative image path stored in
    #  #  `thumbnail` field. `nil` if `thumbnail` field is `nil`.
    #  def thumbnail_url; end
    %w(image fileName thumbnail).each do |field|
      define_method "#{field}_url" do
        self.send(field) ? Client.image_url(self.send(field)) : nil
      end
    end
    alias_method :url, :fileName_url

  end
end
