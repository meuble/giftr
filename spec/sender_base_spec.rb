#encoding: utf-8

require File.join(File.dirname(__FILE__), 'spec_helper')

describe Giftr::SenderBase do
  describe "#send" do
    it "should raise error" do
      expect {Giftr::SenderBase.new.send({})}.to raise_error(RuntimeError, "Should be overridden")
    end
  end
end