module Tvdb2

  # This class rappresent a series episode retrieved from TVDB api.
  class Episode

    # Fields returned from api endpoint `GET /series/{id}/episodes`
    INDEX_FIELDS = [
      :absoluteNumber, :airedEpisodeNumber, :airedSeason,:dvdEpisodeNumber,
      :dvdSeason, :episodeName, :firstAired, :id, :lastUpdated, :overview
    ]

    # Other fields with {INDEX_FIELDS} returned from api endpoint `GET
    # /episodes/{id}`
    SHOW_FIELDS = [
      :airsAfterSeason, :airsBeforeEpisode, :airsBeforeSeason, :direcotor,
      :directors, :dvdChapter, :dvdDiscid, :filename, :guestStars, :imdbId,
      :lastUpdatedBy, :productionCode, :seriesId, :showUrl, :siteRating,
      :siteRatingCount, :thumbAdded, :thumbAuthor, :thumbHeight, :thumbWidth,
      :writers
    ]

    # All possible data fields returned from api for a series.
    FIELDS = INDEX_FIELDS + SHOW_FIELDS

    attr_reader :absoluteNumber, :airedEpisodeNumber, :airedSeason,
      :airsAfterSeason, :airsBeforeEpisode, :airsBeforeSeason, :direcotor,
      :directors, :dvdChapter, :dvdDiscid, :dvdEpisodeNumber, :dvdSeason,
      :episodeName, :filename, :firstAired, :guestStars, :id, :imdbId,
      :lastUpdated, :lastUpdatedBy, :overview, :productionCode, :seriesId,
      :showUrl, :siteRating, :siteRatingCount, :thumbAdded, :thumbAuthor,
      :thumbHeight, :thumbWidth, :writers

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

    alias_method :name, :episodeName
    alias_method :number, :airedEpisodeNumber
    alias_method :seasonNumber, :airedSeason

    # @param [Client] client a TVDB api client.
    # @param [Hash] data the data retrieved from api.
    #
    # @note The {Episode} object may not have all fields filled because it can
    #   be initialized from not completed data like when is build from the call
    #   {Series#episodes} (`GET /series/{id}/episodes`): in this case the api
    #   call return a subset of all avaiable data for the episodes
    #   ({INDEX_FIELDS}). But no warries! When you call a method to get one
    #   {SHOW_FIELDS} the library automatically call the endpoint `GET
    #   /episodes/{id}` to retrieve the missing fields.
    # @note You should never need to create this object manually.
    def initialize(client, data = {})
      @client = client
      FIELDS.each do |field|
        instance_variable_set("@#{field}", data[field.to_s])
      end
      @completed = {@client.language => data.key?('seriesId')}
    end

    # @return [String] the episode number with the "_x_" syntax:
    #   `"#{season_number}x#{episode_number}` (3x9)".
    def x
      "#{self.airedSeason}x#{self.airedEpisodeNumber}"
    end

    # @param [Boolean] retrieve_all_fields if true retrieve all fields
    #   (from api) of the episode.
    # @return [Hash] the episode to hash.
    def to_h(retrieve_all_fields: false)
      get_all_fields! if retrieve_all_fields
      hash = {}
      FIELDS.each do |field|
        hash[field.to_sym] = instance_variable_get("@#{field}")
      end
      hash[:name] = @episodeName
      hash[:x] = self.x
      return hash
    end

    private

    # Get all data fields for this episode. Calling api endpoint `GET
    # /episodes/{id}`.
    #
    # @return [Episode] the episode object with all fields filled from
    #   the api response.
    # @raise [RequestError]
    def get_all_fields!
      e = @client.episode(@id)
      FIELDS.each do |field|
        instance_variable_set("@#{field}", e.send(field))
      end
      return self
    end

  end
end
