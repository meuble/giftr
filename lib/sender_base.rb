#encoding: utf-8

class SenderBase
  def initialize
  end

  def send(pair)
    raise "Should be overridden"
  end
end