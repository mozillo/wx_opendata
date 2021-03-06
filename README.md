# WxOpendata
微信小程序后端使用的API，目前只支持一部分。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wx_opendata'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wx_opendata

## Usage
### 接口
详情请参考 **spec/wx_opendata_spec.rb** 用例
目前支持
* create_activity_id
* get_wx_acode_unlimit
* get_wx_acode
* create_wx_aqrcode
* msg_sec_check
* send_template_message
### 签名

### 客服消息

### 消息推送

在config/initializers下面创建 wx_opendata.rb
复制配置进去，填写你的appid, appsecret
```ruby
require 'wx_opendata'
appid = ''
appsecret = ''
token_file = '/tmp/weapp_access_token'
$wx_token = WxOpendata::Token.new(appid, appsecret, token_file)
$wx_service = WxOpendata::Service.new
```
在你的API下面,如果要获取activity_id, 只要通过$wx_service调用create_activity_id即可
```ruby
def get_wx_activity_id
  render json: {
    activity_id: $wx_service.create_activity_id($wx_token.token)
  }
end
```
其他api用法请参考 **spec/wx_opendata_spec.rb** 
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mozillo/wx_opendata. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the WxOpendata project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/wx_opendata/blob/master/CODE_OF_CONDUCT.md).
