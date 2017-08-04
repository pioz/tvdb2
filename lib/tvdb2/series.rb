module Tvdb2

  # This class rappresent a series retrieved from TVDB api.
  class Series

    # All series fields returned from TVDB api.
    FIELDS = [
      :added, :airsDayOfWeek, :airsTime, :aliases, :banner, :firstAired, :genre,
      :id, :imdbId, :lastUpdated, :network, :networkId, :overview, :rating,
      :runtime, :seriesId, :seriesName, :siteRating, :siteRatingCount, :status,
      :zap2itId, :errors
    ]

    attr_reader *FIELDS

    alias_method :name, :seriesName

    # @param [Client] tvdb a TVDB api client.
    # @param [Hash] data the data retrieved from api.
    #
    # @note The {Series} object may not have all fields filled because it
    #   can be initialized from not completed data like when is build from a
    #   call like {Client#search} (`GET /search/series`): in this case the api
    #   call return a subset of all avaiable data for the series. To get the
    #   complete data of a specific episode use {Series#series!} method.
    # @note You should never need to create this object manually.
    def initialize(tvdb, data = {})
      @tvdb = tvdb
      FIELDS.each do |field|
        instance_variable_set("@#{field}", data[field.to_s])
      end
    end

    # Get all data for this series. Calling api endpoint `GET /series/{id}`.
    #
    # @return [Series] the {Series} object with all fields filled
    #   from the api response.
    # @raise [RequestError]
    def series!
      if self.added.nil?
        s = @tvdb.series(self.id)
        FIELDS.each do |field|
          instance_variable_set("@#{field}", s.send(field))
        end
      end
      return self
    end
    alias_method :get_data!, :series!

    # @return [TvdbStruct] return the summary of the series.
    # @raise [RequestError]
    def series_summary
      @tvdb.series_summary(self.id)
    end

    # Retrieve the episodes of the series.
    #
    # @param params (see API#episodes)
    # @option params (see API#episodes)
    # @return [Array<Episode>]
    # @raise [RequestError]
    def episodes(params = {})
      return @tvdb.episodes(self.id, params) if params && params.key?(:page)
      episodes = []
      page = 1
      loop do
        params.merge!(page: page)
        result = @tvdb.episodes(self.id, params)
        episodes += result
        page += 1
        break if result.size < 100
      end
      return episodes.sort_by{|x| [x.airedSeason, x.airedEpisodeNumber]}
    end

    # @return [Array<TvdbStruct>] the list of actors in the series.
    # @raise [RequestError]
    def actors
      @tvdb.actors(self.id)
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
      @tvdb.images_summary(self.id)
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
      @tvdb.images(self.id, params)
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

  end
end
