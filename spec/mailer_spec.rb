#encoding: utf-8

require File.join(File.dirname(__FILE__), 'spec_helper')

describe Giftr::Mailer do
  before :each do
    @mailer = Giftr::Mailer.new(:smtp_option => {}, :config_path => File.join(File.dirname(__FILE__), 'config', 'mailer.yml'))
  end

  describe "#send" do
    it "should send email" do
      expect(Pony).to receive(:mail)
      @mailer.send({:giver => {:email => "toto@titi.fr"}, :receiver => {:name => "Tata"}})
    end

    it "should send email to giver email" do
      expect(Pony).to receive(:deliver) do |mail|
        expect(mail.to).to eq(["toto@titi.fr"])
      end
      @mailer.send({:giver => {:email => "toto@titi.fr"}, :receiver => {:name => "Tata"}})
    end

    it "should send receiver name in body" do
      expect(Pony).to receive(:deliver) do |mail|
        expect(mail.body).to match("Tata")
      end
      @mailer.send({:giver => {:email => "toto@titi.fr"}, :receiver => {:name => "Tata"}})
    end

    it "should use subject and body from config, replacing %{receiver}" do
      mailer = Giftr::Mailer.new(:config_path => File.join(File.dirname(__FILE__), 'config', 'mailer.yml'))
      mailer.instance_variable_set(:@subject, "Lutin pour %{receiver}")
      mailer.instance_variable_set(:@body, "Tu offres à %{receiver}, 100% secret")
      expect(Pony).to receive(:deliver) do |mail|
        expect(mail.subject).to eq("Lutin pour Tata")
        expect(mail.body.decoded).to eq("Tu offres à Tata, 100% secret")
      end
      mailer.send({:giver => {:email => "toto@titi.fr"}, :receiver => {:name => "Tata"}})
    end
  end
end