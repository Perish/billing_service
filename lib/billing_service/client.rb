#coding: utf-8
module BillingService
  module Client

    # 注册应用 
    def self.register_app(qy_name, appname, devkey = '')
      devkey ||= BillingService.devkey
      xml = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.business(comment: '登记应用', id: 'DJAPP', version: '1.0') do
          xml.head do
            xml.devkey devkey 
            xml.qy_name qy_name
            xml.appname appname
          end
        end
      end
      res = BillingService::Result.new(
        Hash.from_xml(
          invoke_request(BillingService.gateway_url , "bw=#{xml.to_xml}")
        )
      )
      if res.success?
        pp "---请有效时长（2分钟内），在开票软件端添加应用时录入验证码：#{res["crc"]}"
        pp "～～过期后需重新调用接口申请。并且要保存返回的数据"
      else
        pp "发送登记出错，提示：#{res.returnmsg}"
      end
      res
    end

    # 开具发票
    # params:
    # =begin 
    # {
    #   appid: "每个调用该接口的应用ID，唯一", 
    #   inputs: {
    #   sid: "每个应用对应交易流水号，在一个应用里面是不允许重复的", tax_rate: 税率, 
    #   yylxdm: "应用类型代码", fplxdm: "发票类型代码", ghdwsbh: "购货单位识别号",
    #   ghdwmc: "购货单位名称", ghdwdzdh: "购货单位地址电话", ghdwyhzh: "购货单位银行帐号", 
    #   total_money: "总价格", bz: "备注", skr: "收款人", fhr: "复核人",
    #   operator_name: "开票人", GMF_DZYX: "收票人电子邮箱", GMF_SJHM: "收票人手机号码", total_money: "总价格"
    #   }
    #   groups: [{
    #   spmc: "商品名称", spsm: "商品税目", ggxh: "规格型号", dw: "单位",
    #   spsl: "商品数量", money: "商品价格",
    #   spbm: "商品编码", zxbm: "纳税人自行编码" 
    #   }]
    # }
    # =end
    def self.send_invoice(appid, inputs = {}, groups = [])
      tax_rate = inputs.delete(:tax_rate) || BillingService.tax_rate
      total_money = (BigDecimal.new(inputs[:total_money].to_s) / BigDecimal.new((1 + tax_rate).to_s)).round(2)
      total_tax = (BigDecimal.new(total_money.to_s) * BigDecimal.new(tax_rate.to_s)).round(2)
      xml = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.business(comment: '发票开具', id: 'FPKJ', version: '1.0') do
          xml.head do
            xml.appid appid
            xml.sid inputs.delete(:sid)
          end
          xml.body(yylxdm: '1') do
            xml.input do
              xml.fplxdm inputs[:fplxdm] || '026'
              xml.ghdwsbh inputs[:ghdwsbh] || ''
              xml.ghdwmc inputs[:ghdwmc] || ''
              xml.ghdwdzdh inputs[:ghdwdzdh] || ''
              xml.ghdwyhzh inputs[:ghdwyhzh] || ''
              xml.fyxm(count: "#{groups.size}") do
                groups.each_with_index do |g, i|
                  money = (BigDecimal.new(g[:money].to_s) / BigDecimal.new((1 + tax_rate).to_s)).round(2)
                  s_money = (BigDecimal.new(money.to_s) * BigDecimal.new(tax_rate.to_s)).round(2)
                  xml.group(xh: "#{i+1}") do
                    xml.fphxz 0
                    xml.spmc g[:name]
                    xml.spsm g[:spsm] || ''
                    xml.ggxh g[:ggxh] || ''
                    xml.dw g[:dw] || ''
                    xml.spsl g[:spsl] || 1
                    xml.dj money
                    xml.je money
                    xml.sl tax_rate
                    xml.se s_money
                    xml.hsbz 0
                    xml.spbm g[:spbm] 
                    xml.yhzcbs 0
                    xml.slbs ''
                    xml.zzstsgl ''
                  end
                end
              end
              xml.hjje total_money
              xml.hjse total_tax
              xml.jshj inputs[:total_money]
              xml.bz inputs[:bz] || ''
              xml.skr inputs[:skr] || '管理员'
              xml.fhr inputs[:fhr] || '管理员'
              xml.kpr inputs[:operator_name] || '殷齐雨'
              xml.GMF_DZYX inputs[:email]
              xml.GMF_SJHM inputs[:phone]
            end
          end
        end
      end

      BillingService::Result.new(
        Hash.from_xml(
          invoke_request(BillingService.gateway_url , "bw=#{xml.to_xml}")
        )
      )
    end

    # 查询开票结果
    # @required appid 应用代码, 用来标记不同的设备、不同的使用者，全局唯一
    # @required sid 交易流水id, 要查询的交易流水id，跟开票时使用的一样。
    def self.search(appid, sid)
      xml = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.business(comment: '查询开票结果', id: 'CXKPJG', version: '1.0') do
          xml.head do
            xml.appid appid
            xml.sid sid
          end
        end
      end
      BillingService::Result.new(
        Hash.from_xml(
          invoke_request(BillingService.gateway_url, "bw=#{xml.to_xml}")
        )
      )
    end

    private

    def self.invoke_request(url, payload, options = {})
      RestClient::Request.execute(
        { 
          method: :post,
          url: url, 
          payload: payload, 
          headers: { content_type: 'application/x-www-form-urlencoded;charset=utf-8' }
        }.merge(options)
      )
    end

  end
end