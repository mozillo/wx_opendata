require "spec_helper"
appid = ''
appsecret = ''
token_file = '/tmp/weapp_access_token'
tk = WxOpendata::Token.new(appid, appsecret, token_file)
service = WxOpendata::Service.new

RSpec.describe WxOpendata do
  it "1. should return corrent length access_token" do
    token = tk.token
    expect(token.size).to be > 120
  end

  it "2. should return activity id" do
    token = tk.token
    activity_id = service.create_activity_id(token)
    expect(activity_id.size).to be > 10
  end

  it '3.1 should return get_wx_acode_unlimit pic path' do
    token = tk.token
    pic = service.get_wx_acode_unlimit(token, { width: 100, scene: 'uid=12345678' })
    expect(pic).to include('/var')
  end

  it '3.2 should return get_wx_acode pic path' do
    token = tk.token
    pic = service.get_wx_acode(token)
    expect(pic).to include('/var')
  end
  
  it '3.3 should return create_wx_aqrcode pic path' do
    token = tk.token
    pic = service.create_wx_aqrcode(token)
    expect(pic).to include('/var')
  end

  it '4. should return ok if content is: Mot最棒' do
    token = tk.token
    isOk = service.msg_sec_check(token, "Mot最棒")
    expect(isOk).to eq(true)
  end
  it '5.1 should return risky content if content is: 特3456书yuuo莞6543李zxcz蒜7782法fgnv级' do
    token = tk.token
    isOk = service.msg_sec_check(token, "特3456书yuuo莞6543李zxcz蒜7782法fgnv级")
    expect(isOk).to eq(false)
  end

  it '5.2 should return risky content if content is: 完2347全dfji试3726测asad感3847知qwez到' do
    token = tk.token
    isOk = service.msg_sec_check(token, "完2347全dfji试3726测asad感3847知qwez到")
    expect(isOk).to eq(false)
  end

  # it '6. send message template to user and should return ok' do
  #   isOk = service.send_template_message(token, {
  #     touser: '',
  #     template_id: '',
  #     form_id: '',
  #     data: {
  #     },
  #     emphasis_keyword: ''
  #   })
  #   expect(isOk).to eq(true)
  # end
end
