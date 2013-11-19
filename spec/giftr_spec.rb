#encoding: utf-8

require File.dirname(__FILE__) + '/spec_helper'

describe Giftr do
  before :each do
    @gr = Giftr.new(File.dirname(__FILE__) + '/config/people.yml')
  end

  describe '#names' do
    it "should get names" do
      expect(@gr.names).to eq(["Stéphane", "Pierre", "Claire", "Michel", "Claire DS"])
    end
  end

  describe '#emails' do
    it "should get emails" do
      expect(@gr.emails).to eq(["stephane@imeuble.info", "pierre@imeuble.info", "claire@imeuble.info", "michel@imeuble.info", "claireds@imeuble.info"])
    end
  end

  describe '#pairs' do
    before :each do
      @pairs = @gr.pairs
    end

    it "should be an array" do
      expect(@pairs.is_a?(Array)).to be_true
    end

    it 'should not assigns 2 same receiver' do
      receivers = @pairs.inject([]) {|acc, e| acc << e[:receiver]}
      expect(receivers).to eq(receivers.uniq)
    end

    it 'should not assigns 2 same givers' do
      givers = @pairs.inject([]) {|acc, e| acc << e[:giver]}
      expect(givers).to eq(givers.uniq)
    end

    it 'should have as many pairs as people' do
      expect(@pairs.size).to eq(@gr.people.size)
    end

    it 'should be random' do
      expect(@pairs).not_to eq(@gr.pairs)
    end
  end

  describe "#check_pair" do
    it "should return false when giver is receiver" do
      expect(@gr.check_pair({:giver => {:name => "1"}, :receiver => {:name => "1"}})).to be_false
    end

    it "should return false when giver is in relationship with receiver" do
      expect(@gr.check_pair({:giver => {:name => "1", :couple_id => "toto"}, :receiver => {:name => "2", :couple_id => "toto"}})).to be_false
    end

    it "should return true when giver is not receiver" do
      expect(@gr.check_pair({:giver => {:name => "1"}, :receiver => {:name => "2"}})).to be_true
    end

    it "should return true when giver is not in relationship with the receiver" do
      expect(@gr.check_pair({:giver => {:name => "2", :couple_id => "titi"}, :receiver => {:name => "1", :couple_id => "toto"}})).to be_true
    end
  end

  describe "#check_pairs" do
    it 'should check each pairs' do
      pairs = [{:giver => {:name => "1"}, :receiver => {:name => "2"}}, {:giver => {:name => "3"}, :receiver => {:name => "4"}}, {:giver => {:name => "4"}, :receiver => {:name => "5"}}]
      pairs.each do |pair|
        @gr.should_receive(:check_pair).once.with(pair).and_return(true)
      end
      expect(@gr.check_pairs(pairs)).to be_true
    end

    it "should return true when all pairs are true" do
      pairs = [{:giver => {:name => "1"}, :receiver => {:name => "2"}}, {:giver => {:name => "3"}, :receiver => {:name => "6"}}, {:giver => {:name => "4"}, :receiver => {:name => "6"}}]
      expect(@gr.check_pairs(pairs)).to be_true
    end
    
    it "should return false when at least one pair is false" do
      pairs = [{:giver => {:name => "1"}, :receiver => {:name => "2"}}, {:giver => {:name => "6"}, :receiver => {:name => "6"}}, {:giver => {:name => "4"}, :receiver => {:name => "5"}}]
      expect(@gr.check_pairs(pairs)).to be_false
    end
  end
end