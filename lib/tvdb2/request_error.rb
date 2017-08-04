module Tvdb2

  # Exception raised when an http request to an endpoint return a status code
  # different from 200 or 404.
  class RequestError < StandardError

    attr_reader :response, :code, :error

    # @param [HTTParty::Response] response the HTTParty response object.
    def initialize(response)
      super(response['Error'] || response.message)
      @response = response
      @code = response.code
      @error = response['Error']
    end

  end

end
