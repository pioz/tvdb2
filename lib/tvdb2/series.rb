module Tvdb2

  # This class rappresent a series retrieved from TVDB api.
  class Series

    # Fields returned from api endpoint `GET /search/series` (search)
    INDEX_FIELDS = [
      :aliases, :banner, :firstAired, :id, :network, :overview, :seriesName,
      :status, :slug
    ]

    # Other fields with {INDEX_FIELDS} returned from api endpoint `GET
    # /series/{id}`
    SHOW_FIELDS = [
      :added, :airsDayOfWeek, :airsTime, :genre, :imdbId, :lastUpdated,
      :networkId, :rating, :runtime, :seriesId, :siteRating, :siteRatingCount,
      :zap2itId
    ]

    # All possible data fields returned from api for a series.
    FIELDS = INDEX_FIELDS + SHOW_FIELDS

    attr_reader :added, :airsDayOfWeek, :airsTime, :aliases, :banner,
      :firstAired, :genre, :id, :imdbId, :lastUpdated, :network, :networkId,
      :overview, :rating, :runtime, :seriesId, :seriesName, :siteRating,
      :siteRatingCount, :status, :slug, :zap2itId
    # FIELDS.each do |field|
    #   attr_reader field
    # end

    INDEX_FIELDS.each do |field|
      define_method field do
        if !@completed.keys.include?(@client.language)
          get_all_fields!
          @completed[@client.language] = true
        end
        return instance_variable_get("@#{field}")
      end
    end

    SHOW_FIELDS.each do |field|
      define_method field do
        if !@completed.keys.include?(@client.language) || !@completed[@client.language]
          get_all_fields!
          @completed[@client.language] = true
        end
        return instance_variable_get("@#{field}")
      end
    end

    alias_method :name, :seriesName

    # @param [Client] client a TVDB api client.
    # @param [Hash] data the data retrieved from api.
    #
    # @note The {Series} object may not have all fields filled because it can
    #   be initialized from not completed data like when is build from the call
    #   {Client#search} (`GET /search/series`): in this case the api call return
    #   a subset of all avaiable data for the series ({INDEX_FIELDS}). But no
    #   warries! When you call a method to get one {SHOW_FIELDS} the library
    #   automatically call the endpoint `GET /series/{id}` to retrieve the
    #   missing fields.
    # @note You should never need to create this object manually.
    def initialize(client, data = {})
      @client = client
      FIELDS.each do |field|
        instance_variable_set("@#{field}", data[field.to_s])
      end
      @completed = {@client.language => data.key?('added')}
    end

    # @return [TvdbStruct] return the summary of the series.
    # @raise [RequestError]
    def series_summary
      @client.series_summary(self.id)
    end
    alias_method :summary, :series_summary

    # Retrieve the episodes of the series.
    #
    # @param params (see API#episodes)
    # @option params (see API#episodes)
    # @return [Array<Episode>]
    # @raise [RequestError]
    def episodes(params = {})
      return @client.episodes(self.id, params) if params && params.key?(:page)
      episodes = []
      page = 1
      loop do
        params.merge!(page: page)
        result = @client.episodes(self.id, params)
        episodes += result
        page += 1
        break if result.size < 100
      end
      return episodes.sort_by{|x| [x.airedSeason, x.airedEpisodeNumber]}
    end

    # @return [Array<TvdbStruct>] the list of actors in the series.
    # @raise [RequestError]
    def actors
      @client.actors(self.id)
    end

    # Get the episode of the series identified by the index.
    # @param [String, Integer] index the index of the episode to retrieve. Can be and
    #   Integer (`absoluteNumber`) or a String
    #   `"#{season_number}x#{episode_number}"` (3x9).
    # @return [Episode] the episode.
    # @raise [RequestError]
    #
    # @example
    #   got = client.best_search('Game of Thrones')
    #   puts got[29].name
    #   puts got['3x9'].name
    def [](index)
      episodes = self.episodes
      if index.is_a?(Integer)
        return episodes.select{|e| e.absoluteNumber == index}.first
      else
        series, ep = index.split('x')
        return episodes.select{|e| e.airedSeason == series.to_i && e.airedEpisodeNumber == ep.to_i}.first
      end
    end

    # @!group Instance Method Summary to retrieve images

    # @return [Array<TvdbStruct>] the image summary of the series.
    # @raise [RequestError]
    def images_summary
      @client.images_summary(self.id)
    end

    # Retrieve the images of the series.
    #
    # @param params (see API#images)
    # @option params (see API#images)
    # @return [Array<TvdbStruct>] the list of images.
    # @raise [RequestError]
    #
    # @example
    #   got = client.best_search('Game of Thrones')
    #   puts got.images(keyType: 'poster').first.fileName_url # print the url of a poster of the series
    def images(params)
      @client.images(self.id, params)
    end

    # @return [Array<TvdbStruct>] the list of fanart images.
    # @raise [RequestError]
    def fanarts
      self.images(keyType: 'fanart')
    end

    # @return [Array<TvdbStruct>] the list of poster images.
    # @raise [RequestError]
    def posters
      self.images(keyType: 'poster')
    end

    # @param [Integer] season If present return the images only for that
    #   `season` number.
    # @return [Array<TvdbStruct>] the list of season images.
    # @raise [RequestError]
    def season_images(season: nil)
      r = self.images(keyType: 'season')
      r.select!{|x| x.subKey == season.to_s} if season
      r.sort{|x,y| x.subKey <=> y.subKey}
    end

    # @param [Integer] season if present return the images only for that
    #   `season` number.
    # @return [Array<TvdbStruct>] the list of season wide images.
    # @raise [RequestError]
    def seasonwide_images(season: nil)
      r = self.images(keyType: 'seasonwide')
      r.select!{|x| x.subKey == season.to_s} if season
      r.sort{|x,y| x.subKey <=> y.subKey}
    end

    # @return [Array<TvdbStruct>] the list of banner images of the
    #   series.
    # @raise [RequestError]
    def banners
      self.images(keyType: 'series')
    end

    # @param [Boolean] random If `true` return a random banner image url.
    # @return [String] the banner image url of the series.
    # @raise [RequestError]
    def banner_url(random: false)
      if random
        b = self.banners.shuffle.first
        b ? b.url : nil
      else
        @banner ? Client.image_url(@banner) : nil
      end
    end

    # @param [Boolean] random If `true` return a random poster image url.
    # @return [String] the poster image url of the series.
    # @raise [RequestError]
    def poster_url(random: false)
      ps = self.posters
      ps.shuffle! if random
      ps.first ? ps.first.url : nil
    end

    # @!endgroup

    # @param [Boolean] episodes if true include all episodes
    #   ({Episode#to_h}) on the hash.
    # @param [Boolean] retrieve_all_fields if true retrieve all fields
    #   (from api) of the series.
    # @return [Hash] the series to hash.
    def to_h(episodes: false, retrieve_all_fields: false)
      get_all_fields! if retrieve_all_fields
      hash = {}
      FIELDS.each do |field|
        hash[field.to_sym] = instance_variable_get("@#{field}")
      end
      hash[:name] = @seriesName
      hash[:poster_url] = self.poster_url
      hash[:banner_url] = self.banner_url
      hash[:episodes] = self.episodes.map(&:to_h) if episodes
      return hash
    end

    private

    # Get all data fields for this series. Calling api endpoint `GET
    # /series/{id}`.
    #
    # @return [Series] the {Series} object with all fields filled
    #   from the api response.
    # @raise [RequestError]
    def get_all_fields!
      s = @client.series(@id)
      FIELDS.each do |field|
        instance_variable_set("@#{field}", s.instance_variable_get("@#{field}"))
      end
      return self
    end

  end
end
