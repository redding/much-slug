module MuchSlug
  module Configs
    def self.new
      Hash.new{ |h, k| h[k] = {} }
    end
  end
end
