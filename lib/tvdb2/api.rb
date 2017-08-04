require 'tvdb2/series'
require 'tvdb2/episode'

module Tvdb2
  # Methods in this module wrap the TVDB api endpoints.
  #
  # @todo Missing endpoints are:
  #
  #   * __Series__
  #       * filter: `GET /series/{id}/filter`
  #   * __Updates__
  #       * updadad: `GET /updated/query`
  #   * __Users__
  #       * user: `GET /user`
  #       * favorites: `GET /user/favorites`
  #       * delete favorites: `DELETE /user/favorites/{id}`
  #       * add favorites: `PUT /user/favorites/{id}`
  #       * ratings: `GET /user/ratings`
  #       * ratings with query: `GET /user/ratings/query`
  #       * delete rating: `DELETE /user/ratings/{itemType}/{itemId}`
  #       * add rating: `PUT /user/ratings/{itemType}/{itemId}/{itemRating}`
  module API

    # Perform a request to the endpoint `GET /languages`.
    #
    # @return [Array<TvdbStruct>] all available languages. These language
    #   abbreviations can be used in the Accept-Language header for routes that
    #   return translation records.
    # @raise [RequestError]
    def languages
      build_array_result('/languages')
    end

    # Perform a request to the endpoint `GET /languages/{id}`.
    #
    # @param [Integer] id language id.
    # @return [TvdbStruct] Information about a particular language.
    # @raise [RequestError]
    def language(id)
      build_object_result("/languages/#{id}")
    end

    # Perform a request to the endpoint `GET /search/series`.
    #
    # @param [Hash] params the params of the request.
    # @option params [String] :name name of the series to search for;
    # @option params [String] :imdbId IMDB id of the series;
    # @option params [String] :zap2itId Zap2it id of the series to search for.
    # @return [Array<Series>] list of series found.
    # @raise [RequestError]
    def search(params)
      build_array_result('/search/series', params, Series)
    end

    # @param [String] name name of the series to search for.
    # @return [Series] the series that best match the `name` passed as parameter.
    # @raise [RequestError]
    def best_search(name)
      results = search(name: name)
      chosen = results.select{|x| x.seriesName.downcase == name.downcase}.first
      chosen ||= results.select{|x| x.aliases.map(&:downcase).include?(name.downcase)}.first
      return chosen || results.first
    end

    # Perform a request to the endpoint `GET /series/{id}`.
    #
    # @param [Integer] id the id of the series.
    # @return [Series] a series record that contains all information
    #   known about a particular series id.
    # @raise [RequestError]
    def series(id)
      build_object_result("/series/#{id}", {}, Series)
    end

    # Perform a request to the endpoint `GET /series/{id}/episodes/summary`.
    #
    # @param [Integer] id the id of the series.
    # @return [TvdbStruct] a summary of the episodes and seasons
    #   available for the series.
    # @raise [RequestError]
    def series_summary(id)
      build_object_result("/series/#{id}/episodes/summary")
    end

    # Perform a request to the endpoint `GET /series/{id}/episodes`.
    #
    # @param [Integer] id the id of the series.
    # @param [Hash] params the params of the request to retrieve the episodes of
    #   the series.
    # @option params [String, Integer] :absoluteNumber absolute number of the
    #   episode;
    # @option params [String, Integer] :airedSeason aired season number;
    # @option params [String, Integer] :airedEpisode aired episode number;
    # @option params [String, Integer] :dvdSeason DVD season number;
    # @option params [String, Integer] :dvdEpisode DVD episode number;
    # @option params [String, Integer] :imdbId IMDB id of the series;
    # @option params [Integer] :page page of results to fetch (100
    #   episodes per page).
    # @return [Array<Episode>] episodes found.
    # @raise [RequestError]
    def episodes(id, params = {})
      if params.nil? || params.empty?
        build_array_result("/series/#{id}/episodes", {}, Episode)
      else
        build_array_result("/series/#{id}/episodes/query", params, Episode)
      end
    end

    # Perform a request to the endpoint `GET /series/{id}/actors`.
    #
    # @param [Integer] id the id of the series.
    # @return [Array<TvdbStruct>] actors for the given series id.
    # @raise [RequestError]
    def actors(id)
      build_array_result("/series/#{id}/actors")
    end

    # Perform a request to the endpoint `GET /episodes/{id}`.
    #
    # @param [Integer] id the id of the episode.
    # @return [Episode] the full information for a given episode id.
    # @raise [RequestError]
    def episode(id)
      build_object_result("/episodes/#{id}", {}, Episode)
    end

    # Perform a request to the endpoint `GET /series/{id}/images`.
    #
    # @param [Integer] id the id of the series.
    # @return [Array<TvdbStruct>] a summary of the images for a
    #   particular series.
    # @raise [RequestError]
    def images_summary(id)
      build_object_result("/series/#{id}/images")
    end

    # Perform a request to the endpoint `GET /series/{id}/images/query`.
    #
    # @param [Integer] id the id of the series.
    # @param [Hash] params the params of the request to retrieve the images.
    # @option params [String] :keyType type of image you're querying for
    #   (fanart, poster, season, seasonwide, series);
    # @option params [String] :resolution resolution to filter by (1280x1024 for
    #   example);
    # @option params [String] :subKey subkey for the above query keys.
    # @return [Array<TvdbStruct>] the images for a particular series.
    # @raise [RequestError]
    def images(id, params)
      build_array_result("/series/#{id}/images/query", params)
    end

  end
end
