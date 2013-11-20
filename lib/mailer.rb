#encoding: utf-8

require "pony"

class Mailer < SenderBase
  def initialize(options = {})
    @config = YAML.load_file(options[:config_path] || File.dirname(__FILE__) + '/../config/mailer.yml')
    @smtp_options = options[:smtp_options] || @config[:smtp_options]
  end

  def send(pair)
    Pony.mail(:to => pair[:giver][:email], :via => :smtp, :via_options => @smtp_options,
      :from => 'sakkaoui@gmail.com',
      :subject => "[Lutin de noël] Vous savez à qui offrir un cadeau !", :body => "Bonjour ! Vous devez faire un cadeau à #{pair[:receiver][:name]}")
  end
end