module Tvdb2

  # This class rappresent a series episode retrieved from TVDB api.
  class Episode

    # All episode fields returned from TVDB api.
    FIELDS = [
      :absoluteNumber, :airedEpisodeNumber, :airedSeason,
      :airsAfterSeason, :airsBeforeEpisode, :airsBeforeSeason, :direcotor,
      :directors, :dvdChapter, :dvdDiscid, :dvdEpisodeNumber, :dvdSeason,
      :episodeName, :filename, :firstAired, :guestStars, :id, :imdbId,
      :lastUpdated, :lastUpdatedBy, :overview, :productionCode, :seriesId,
      :showUrl, :siteRating, :siteRatingCount, :thumbAdded, :thumbAuthor,
      :thumbHeight, :thumbWidth, :writers, :errors
    ]

    attr_reader *FIELDS

    alias_method :name, :episodeName
    alias_method :number, :airedEpisodeNumber
    alias_method :seasonNumber, :airedSeason

    # @param [Client] tvdb a TVDB api client.
    # @param [Hash] data the data retrieved from api.
    #
    # @note The Episode object may not have all fields filled because it can be
    #   initialized from not completed data like when is build from a call like
    #   `series.episodes` (`GET /series/{id}/episodes`): in this case the api
    #   call return a subset of all avaiable data for the episodes. To get the
    #   complete data of a specific episode use `#episode!` method.
    # @note You should never need to create this object manually.
    def initialize(tvdb, data = {})
      @tvdb = tvdb
      FIELDS.each do |field|
        instance_variable_set("@#{field}", data[field.to_s])
      end
    end

    # Get all data for this episode. Calling api endpoint `GET /episodes/{id}`.
    #
    # @return [Episode] the episode object with all fields filled from
    #   the api response.
    # @raise [RequestError]
    def episode!
      if self.lastUpdated.nil?
        e = @tvdb.episode(self.id)
        FIELDS.each do |field|
          instance_variable_set("@#{field}", e.send(field))
        end
      end
      return self
    end
    alias_method :get_data!, :episode!

    # @return [String] the episode number with the "_x_" syntax:
    #   `"#{season_number}x#{episode_number}` (3x9)".
    def x
      "#{self.airedSeason}x#{self.airedEpisodeNumber}"
    end

  end
end
