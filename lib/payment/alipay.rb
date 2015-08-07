# encoding:utf-8

require 'openssl'
require 'base64'

module Payment
  module Alipay

    class << self
      attr_accessor :partner, :key
    end

    def self.payment(out_trade_no, total_fee, notify_url, subject, body, partner = nil, seller_id = nil, key = nil)
      begin
        params = {
          'partner' => partner || Payment::Alipay.partner,
          'seller_id' => seller_id || Payment::Alipay.partner,
          'out_trade_no' => out_trade_no,
          'subject' => subject,
          'body' => body,
          'total_fee' => total_fee,
          'notify_url' => notify_url,
          'service' => 'mobile.securitypay.pay',
          'payment_type'   => '1',
          '_input_charset' => 'utf-8',
          'it_b_pay' => '30m',
          'show_url' => 'm.alipay.com',
        }

        string = params.map { |key, value| %Q(#{key}="#{value}") }.join('&')

        rsa = OpenSSL::PKey::RSA.new(key || Payment::Alipay.key)

        sign = CGI.escape(Base64.strict_encode64(rsa.sign('sha1', string.force_encoding("utf-8"))))

        %Q(#{string}&sign="#{sign}"&sign_type="RSA")
      rescue Exception => e
        nil
      end
    end
  end
end