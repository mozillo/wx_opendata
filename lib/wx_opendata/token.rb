module WxOpendata
  
  WX_ACCESS_TOKEN = 'https://api.weixin.qq.com/cgi-bin/token'.freeze

  class Token
    attr_reader :appid, :secret, :token_file, :access_token, :token_expires_in, :store_token_at

    def initialize(appid, appsecret, token_file)
      @appid = appid
      @appsecret = appsecret
      @token_file = token_file
      @random_generator = Random.new
    end

    def token
      read_token_from_cache
      refresh_token if remain_seconds < @random_generator.rand(30..3 * 60)
      access_token
    end

    protected

    def refresh_token
      url = "#{WX_ACCESS_TOKEN}?grant_type=client_credential&appid=#{@appid}&secret=#{@appsecret}"
      resp = RestClient.get url
      store_token_to_cache(resp.body)
      read_token_from_cache
    end

    def read_token_from_cache
      token = read_token
      @token_expires_in = token.fetch('expires_in').to_i
      @store_token_at = token.fetch('store_token_at').to_i
      @access_token = token.fetch('access_token')
    rescue JSON::ParserError, Errno::ENOENT, KeyError, TypeError => e
      refresh_token
    end

    def store_token_to_cache(token)
      token_hash = JSON.parse token
      raise InvalidCredentialError unless token_hash['access_token']
      token_hash['store_token_at'.freeze] = Time.now.to_i
      write_token(token_hash.to_json)
    end

    def write_token(token)
      File.write(token_file, token)
    end

    def read_token
      JSON.parse File.read(token_file)
    end

    def remain_seconds
      token_expires_in - (Time.now.to_i - store_token_at.to_i)
    end

  end
end