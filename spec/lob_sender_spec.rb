#encoding: utf-8

require File.join(File.dirname(__FILE__), 'spec_helper')

describe Giftr::LobSender do
  let(:config_path) { File.join(File.dirname(__FILE__), 'config', 'lob.yml') }

  describe "#initialize" do
    it "should initialize Lob with api_key" do
      ls = Giftr::LobSender.new(:config_path => config_path)
      expect(ls.lob).to be_a(Lob::PostcardsApi)
      expect(ls.lob.api_client.config.username).to eq("test_4f7e1328726da23787389a90e478b")
    end
  end

  describe "#send" do
    before :each do
      @ls = Giftr::LobSender.new(:config_path => config_path)
    end

    it "should send postcard to giver address with receiver name on the back" do
      address = {:name => "ToAddress", :address_line1 => "120, avenue Martin", :address_city => "Paris", :address_country => "FR", :address_zip => 75010}
      expect(@ls.lob).to receive(:create) do |postcard|
        expect(postcard).to be_a(Lob::PostcardEditable)
        expect(postcard.to.name).to eq("ToAddress")
        expect(postcard.to.address_city).to eq("Paris")
        expect(postcard.to.address_zip).to eq("75010")
        expect(postcard.to.address_country).to eq("FR")
        expect(postcard.front).to eq(Giftr::LobSender::DEFAULT_FRONT)
        expect(postcard.back).to include("Titi")
      end
      @ls.send({:giver => {:name => "Toto", :address => address}, :receiver => {:name => 'Titi'}})
    end

    it "should accept legacy address keys and use giver name by default" do
      address = {:address_line1 => "120, avenue Martin", :city => "Paris", :country => "FR", :zip => 75010}
      expect(@ls.lob).to receive(:create) do |postcard|
        expect(postcard.to.name).to eq("Toto")
        expect(postcard.to.address_city).to eq("Paris")
        expect(postcard.to.address_zip).to eq("75010")
        expect(postcard.to.address_country).to eq("FR")
      end
      @ls.send({:giver => {:name => "Toto", :address => address}, :receiver => {:name => 'Titi'}})
    end

    it "should escape HTML in the message" do
      expect(@ls.lob).to receive(:create) do |postcard|
        expect(postcard.back).to include("Ti&lt;b&gt;ti")
      end
      @ls.send({:giver => {:name => "Toto", :address => {:address_line1 => "1 rue X"}}, :receiver => {:name => 'Ti<b>ti'}})
    end
  end
end
