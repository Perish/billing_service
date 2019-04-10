module BillingService
  class Result < ::Hash
    SUCCESS_FLAG = '0'.freeze

    def initialize(result)
      super nil # Or it will call `super result`

      self[:raw] = result
      
      if result['business'].class == Hash
        result['business']['head'].each_pair do |k, v|
          self[k] = v
        end
        result['business']['body'].each_pair do |k, v|
          self[k] = v
        end
      end
    end

    def success?
      self['returncode'] == SUCCESS_FLAG
    end

    def returnmsg
      self['returnmsg']
    end
  end
end