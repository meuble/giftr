#encoding: utf-8

require File.dirname(__FILE__) + '/spec_helper'

describe SenderBase do
  describe "#send" do
    it "should raise error" do
      expect {SenderBase.new.send}.to raise_error
    end
  end
end