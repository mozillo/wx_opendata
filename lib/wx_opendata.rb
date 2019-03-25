require "wx_opendata/version"
require 'wx_opendata/service'
require 'wx_opendata/token'

module WxOpendata
  class AccessTokenExpiredError < StandardError; end
  class InvalidCredentialError < StandardError; end
  class ServiceNotAvailableError < StandardError; end
  class InvalidParametersError < StandardError; end
  class ErrCodeError < StandardError; end

  class<< self
  end
end

