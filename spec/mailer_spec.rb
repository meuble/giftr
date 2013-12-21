#encoding: utf-8

require File.join(File.dirname(__FILE__), 'spec_helper')

describe Mailer do
  before :each do
    @mailer = Mailer.new(:smtp_option => {}, :config_path => File.join(File.dirname(__FILE__), 'config', 'mailer.yml'))
  end

  describe "#send" do
    it "should send email" do
      Pony.should_receive(:mail)
      @mailer.send({:giver => {:email => "toto@titi.fr"}, :receiver => {:name => "Tata"}})
    end

    it "should send email to giver email" do
      Pony.should_receive(:deliver) do |mail|
        expect(mail.to).to eq(["toto@titi.fr"])
      end
      @mailer.send({:giver => {:email => "toto@titi.fr"}, :receiver => {:name => "Tata"}})
    end

    it "should send receiver name in body" do
      Pony.should_receive(:deliver) do |mail|
        expect(mail.body).to match("Tata")
      end
      @mailer.send({:giver => {:email => "toto@titi.fr"}, :receiver => {:name => "Tata"}})
    end
  end
end