module BillingService
  class Result < ::Hash
    SUCCESS_FLAG = '0'.freeze

    def initialize(result)
      super nil # Or it will call `super result`

      self[:raw] = result
      
      if result['business'].class == Hash
        result['business']['head'].each_pair do |k, v|
          self[k] = v
        end if result['business']['head'].present?
        result['business']['body'].each_pair do |k, v|
          self[k] = v
        end if result['business']['body'].present?
      end
    end

    def success?
      self['returncode'].to_s == SUCCESS_FLAG
    end

    def returnmsg
      self['returnmsg']
    end
  end
end