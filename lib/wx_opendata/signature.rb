module WxOpendata
  module Signature
    token = "jxEPPsMsuxw2tnY4_Ss-4moPWh151NsQ"
    def check(signature, timestamp, nonce, encrypt)
      tmp_arr = [token, timestamp, nonce]
      tmp_arr << encrypt unless encrypt.nil?
      sign = tmp_arr.compact.collect(&:to_s).sort.join
      Digest::SHA1.hexdigest sign == signature
    end
  end
end