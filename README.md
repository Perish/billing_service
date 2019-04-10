### 发票管理系统（发票通版）开票服务接口规范

**网上开票模块用于需要远程开票需求的使用者。初次使用时需要绑定应用，只有绑定了应用，应用发起的开票请求才能通过当前的税控盘进行开票。**

第一步：获得开发号，就可以通过开发号添加相关的开票应用。
在config/initializers里创建billing_service.rb
添加如下代码:
```ruby
    BillingService.tax_rate = TAX_RATE # TAX_RATE 是你填写的税率如：0.06
    BillingService.gateway_url = GATEWAY_URL # GATEWAY_URL 是你要配置的url
    BillingService.devkey = DEVKEY # DEVKEY 是开发号(可选)
```
第二步：通过开发号添加应用，拿到6位验证码
```ruby
# params: devkey 开发号key, qy_name 企业名称, appname 应用名
BillingService::Client.register_app(qy_name, appname, devkey = '')


BillingService::Client.register_app("开发号key", "企业名称", "应用名")
=>
{:raw=>{"business"=>{"version"=>"1.0", "head"=>{"devkey"=>"开发号key", "qy_name"=>"企业名称", "appname"=>"应用名"}, "body"=>{"appid"=>"appidasdfsdfsdf", "c_date"=>"2017-04-04 13:58:17", "crc"=>"156612", "returncode"=>"0", "returnmsg"=>"登记成功"}}}, "devkey"=>"开发号key", "qy_name"=>"企业名称", "appname"=>"应用名", "appid"=>"appidasdfsdfsdf", "c_date"=>"2017-04-04 13:58:17", "crc"=>"156612", "returncode"=>"0", "returnmsg"=>"登记成功"}

```
第三步，打开税控盘端，添加应用，会弹出窗口需要6位码，填写刚生成的，提交，添加应用成功。

第四步，发票开具
```ruby
# params:
# {
#   appid: "每个调用该接口的应用ID，唯一", 
#   inputs: {
#   sid: "每个应用对应交易流水号，在一个应用里面是不允许重复的", tax_rate: 税率, 
#   yylxdm: "应用类型代码", fplxdm: "发票类型代码", ghdwsbh: "购货单位识别号",
#   ghdwmc: "购货单位名称", ghdwdzdh: "购货单位地址电话", ghdwyhzh: "购货单位银行帐号", 
#   total_money: "总价格", bz: "备注", skr: "收款人", fhr: "复核人",
#   operator_name: "开票人", email: "收票人电子邮箱", phone: "收票人手机号码"
#   }
#   groups: [{
#   spmc: "商品名称", spsm: "商品税目", ggxh: "规格型号", dw: "单位",
#   spsl: "商品数量", money: "商品价格",
#   spbm: "商品编码", zxbm: "纳税人自行编码" 
#   }]
# }
BillingService::Client.send_invoice(appid, inputs = {}, groups = [])
```

第五步，查看发票详情
```ruby
BillingService::Client.search(appid, sid)
```