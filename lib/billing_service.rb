require "billing_service/result"
require "billing_service/client"
require "billing_service/version"

module BillingService
  class << self
    attr_accessor :tax_rate, :gateway_url, :devkey
  end
end
