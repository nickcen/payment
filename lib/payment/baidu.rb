# encoding:utf-8

module Payment
  module Baidu

    class << self
      attr_accessor :spNo, :key
    end

    def self.payment(out_trade_no, total_fee, notify_url, subject, body, spUno = nil, spNo = nil, key = nil)
      # begin
      order_create_time = Time.now.strftime('%Y%m%d%H%M%S')
      params = {
        'service_code' => 1,
        'sp_no' => spNo || Payment::Baidu.spNo,
        'sp_uno' => spUno,
        'sp_request_type' => 2,
        'order_create_time' => order_create_time,
        'order_no' => out_trade_no,
        'goods_desc' => body.encode('gbk'),
        'goods_name' => subject.encode('gbk'),
        'goods_url' => 'http://www.edaixi.com',
        'total_amount' => total_fee,
        'currency' => 1,
        'pay_type' => 2,
        'input_charset' => 1,
        'return_url' => notify_url,
        'sign_method' => 1,
        'version' => 2,
      }

      string = params.sort.map do |key, value|
        "#{key}=#{value}"
      end.join('&')

      sign = Digest::MD5.hexdigest("#{string}&key=#{key || Payment::Baidu.key}")

      params['goods_desc'] = CGI::escape(params['goods_desc'])
      params['goods_name'] = CGI::escape(params['goods_name'])

      string = params.sort.map do |key, value|
        "#{key}=#{value}"
      end.join('&')

      %Q(#{string}&sign=#{sign})
      # rescue Exception => e
        # nil
      # end
    end
  end
end