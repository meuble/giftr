#encoding: utf-8

module Giftr

  class SenderBase
    def initialize
    end

    def send(pair)
      raise "Should be overridden"
    end
  end

end