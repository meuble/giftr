#encoding: utf-8

require "pony"

class Mailer
  def initialize(smtp_options = nil)
    @config = YAML.load_file(config_path || File.dirname(__FILE__) + '/../config/people.yml')
    @smtp_options = smtp_options || @config[:smtp_options]
  end

  def send(pair)
    Pony.mail(:to => pair[:giver][:email], :via => :smtp, :via_options => @options,
      :from => 'sakkaoui@gmail.com',
      :subject => "[Lutin de noël] Vous savez à qui offrir un cadeau !", :body => "Bonjour ! Vous devez faire un cadeau à #{pair[:receiver][:name]}")
  end
end