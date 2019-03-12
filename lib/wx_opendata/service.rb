require 'rest_client'
require 'mime/types'
require 'json'

module WxOpendata
  BASE_URL = 'https://api.weixin.qq.com/'.freeze
  class Service
    attr_accessor :content_type

    # 发送模板消息
    def send_template_message(token, params)
      raise InvalidParametersError unless params[:touser] && params[:template_id] && params[:form_id]
      url = "cgi-bin/message/wxopen/template/send?access_token=#{token}"
      touser = params[:touser]
      template_id = params[:template_id]
      form_id = params[:form_id]
      page = params[:page] || 'pages/index/main'
      data = params[:data] || { keyword1: { value: 'Test Message Template' } }
      emphasis_keyword = params[:emphasis_keyword] || "keyword1.DATA"
      p = { touser: touser, template_id: template_id, form_id: form_id, page: page, data: data, emphasis_keyword: emphasis_keyword }
      jsondata = post(url, p)
      begin
        raise ErrCodeError, 'template_id不正确' if jsondata['errcode'] == 40037
        raise ErrCodeError, 'form_id不正确，或者过期' if jsondata['errcode'] == 41028
        raise ErrCodeError, 'form_id已被使用' if jsondata['errcode'] == 41029
        raise ErrCodeError, 'page不正确' if jsondata['errcode'] == 41030
        raise ErrCodeError, '接口调用超过限额（目前默认每个帐号日调用限额为100万）' if jsondata['errcode'] == 45009
        jsondata['errcode'] == 0
      rescue ErrCodeError => e
        p "#{e.class}: #{e.message}"
      end
    end

    # 检查一段文本是否含有违法违规内容
    def msg_sec_check(token, content)
      url = "wxa/msg_sec_check?access_token=#{token}"
      p = { content: content }
      jsondata = post(url, p)
      return true if jsondata['errcode'] == 0
      return false if jsondata['errcode'] == 87014
    end

    # 校验一张图片是否含有违法违规内容
    def img_sec_check
    end
    
    # 创建被分享动态消息的 activity_id
    def create_activity_id(token)
      url = "cgi-bin/message/wxopen/activityid/create?access_token=#{token}"
      jsondata = get(url)
      raise ServiceNotAvailableError if jsondata['errcode'] != 0
      jsondata['activity_id']
    end

    # 获取小程序二维码，适用于需要的码数量较少的业务场景
    def create_wx_aqrcode(token, params = {})
      url = "cgi-bin/wxaapp/createwxaqrcode?access_token=#{token}"
      path = params[:path] || 'pages/index/main'
      width = params[:width] || 430
      p = { path: path, width: width }
      data = post(url, p)
      raise InvalidCredentialError if data['errcode'] == 45029
      tmpfile(data)
    end

    # 获取小程序码，适用于需要的码数量较少的业务场景
    def get_wx_acode(token, params = {})
      url = "wxa/getwxacode?access_token=#{token}"
      path = params[:path] || 'pages/index/main'
      width = params[:width] || 430
      auto_color = params[:auto_color] || false
      line_color = params[:line_color] || {"r": 0,"g": 0,"b": 0}
      is_hyaline = params[:is_hyaline] || true
      p = { path: path, width: width, auto_color: auto_color, line_color: line_color, is_hyaline: is_hyaline }
      data = post(url, p)
      raise InvalidCredentialError if data['errcode'] == 45029
      tmpfile(data)
    end
    
    # 获取小程序码，适用于需要的码数量极多的业务场景。通过该接口生成的小程序码，永久有效，数量暂无限制。
    def get_wx_acode_unlimit(token, params = {})
      url = "wxa/getwxacodeunlimit?access_token=#{token}"
      scene = params[:scene] || 'api'
      page = params[:page] || 'pages/index/main'
      width = params[:width] || 430
      auto_color = params[:auto_color] || false
      line_color = params[:line_color] || {"r": 0,"g": 0,"b": 0}
      is_hyaline = params[:is_hyaline] || true
      p = { scene: scene, page: page, width: width, auto_color: auto_color, line_color: line_color, is_hyaline: is_hyaline }
      data = post(url, p)
      raise InvalidCredentialError if data['errcode'] == 45009 || data['errcode'] == 41030
      tmpfile(data)
    end

    # 下发小程序和公众号统一的服务消息
    def send_uniform_message
    end
    

    protected
    def get(url)
      url = BASE_URL + url
      resp = RestClient.get url
      format_result(resp)
    end

    def post(url, params)
      url = BASE_URL + url
      resp = RestClient.post url, params.to_json, {accept: :json}
      format_result(resp)
    end

    def format_result(resp)
      @content_type = resp.headers[:content_type]
      if resp.headers[:content_type].include? "application/json".freeze
        JSON.parse resp.body
      else
        resp.body
      end
    end

    def current_req_type
      @content_type
    end

    def tmpfile(data)
      tmpname = (Time.now.to_i + rand(1000...9999)).to_s
      ext = '.' + MIME::Types[current_req_type].first.extensions.first 
      f = Tempfile.new([tmpname, ext], Dir.tmpdir)
      # f.binmode
      f.write(data)
      f.flush
      f.path
    end

  end
end