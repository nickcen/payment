# encoding:utf-8

require 'rest-client'
require 'nokogiri'

module Payment
  module Wechat

    class << self
      attr_accessor :appid, :mch_id, :key
    end

    def self.payment_v4(out_trade_no, total_fee, notify_url, body, device_info, appid = nil, mch_id = nil, key = nil)
      begin
        nonce_str = Time.now.to_i      

        params = {
          appid: appid || Payment::Wechat.appid,
          mch_id: mch_id || Payment::Wechat.mch_id,
          body: body,
          device_info: device_info,
          out_trade_no: out_trade_no,
          nonce_str: nonce_str,
          total_fee: total_fee,
          notify_url: notify_url,
          spbill_create_ip: '196.168.1.1',
          trade_type: 'APP'
        }

        sign = self.sign(params, key)

        payload = "<xml>#{params.map { |k, v| "<#{k}>#{v}</#{k}>" }.join}<sign>#{sign}</sign></xml>"

        r = RestClient::Request.execute({
          method: :post,
          url: 'https://api.mch.weixin.qq.com/pay/unifiedorder',
          payload: payload,
          timeout: 2, 
          open_timeout: 3,
          headers: { content_type: 'application/xml' }
          })

        if r
          doc = Nokogiri::Slop(r)
          prepay_id = doc.xml.prepay_id.content

          params = {
            appid: appid || Payment::Wechat.appid,
            partnerid: mch_id || Payment::Wechat.mch_id,
            nonce_str: nonce_str,
            package: 'Sign=WXPay',
            timestamp: Time.now.to_i,
            prepayid: prepay_id
          }

          sign = self.sign(params, key)
          params[:sign] = sign
          params
        else
          nil
        end
      rescue Exception => e
        nil
      end
    end

    def self.sign(params, key = nil)
      string = params.sort.map do |key, value|
        "#{key}=#{value}"
      end.join('&')

      sign = Digest::MD5.hexdigest("#{string}&key=#{key || Payment::Wechat.key}").upcase
    end
  end
end