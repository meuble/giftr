#encoding: utf-8

require File.join(File.dirname(__FILE__), 'spec_helper')

describe LobSender do
  describe "#initialize" do
    it "should initialize Lob with api_key" do
      ls = LobSender.new(:config_path => File.join(File.dirname(__FILE__), 'config', 'lob.yml'))
      ls.lob 
      expect(ls.lob).not_to be_nil
      expect(ls.lob.options[:api_key]).to eq("test_4f7e1328726da23787389a90e478b")
    end
  end

  describe "#send" do
    before :each do
      @ls = LobSender.new(:config_path => File.join(File.dirname(__FILE__), 'config', 'lob.yml'))
    end

    it "should send postcard" do
      address = {:name =>  "ToAddress", :address_line1 => "120, avenue Martin", :city => "Paris", :country => "FRANCE", :zip => 75010}
      postcards = double()
      postcards.should_receive(:create).with(
        "Toto",
        address, hash_including(:front => an_instance_of(String), :message => an_instance_of(String))
      )
      @ls.lob.stub(:postcards => postcards)
      @ls.send({:giver => {:name => "Toto", :address => address}, :receiver => {:name => 'Titi'}})
    end
  end
end