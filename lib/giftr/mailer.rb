require 'pony'

module Giftr
  # Email sender. Message settings come from the mailer config file:
  #   :from:    sender address (defaults to the SMTP user_name)
  #   :subject: email subject
  #   :body:    email body; %{receiver} is replaced by the receiver's name
  class Mailer < SenderBase
    DEFAULT_SUBJECT = "[Lutin de Noël] Vous savez à qui offrir un cadeau !"
    DEFAULT_BODY = "Bonjour !\n\nLa personne à qui vous devez faire un cadeau est : %{receiver} !\n\n-- \nLe lutin"

    def initialize(options = {})
      @config = YAML.load_file(options[:config_path] || File.join(Dir.pwd, 'config', 'mailer.yml'))
      @smtp_options = options[:smtp_options] || @config[:smtp_options]
      @from = @config[:from] || @smtp_options[:user_name]
      @subject = @config[:subject] || DEFAULT_SUBJECT
      @body = @config[:body] || DEFAULT_BODY
    end

    def send(pair)
      Pony.mail(to: pair[:giver][:email], via: :smtp, via_options: @smtp_options,
                from: @from,
                charset: 'UTF-8',
                subject: fill(@subject, pair),
                body: fill(@body, pair))
    end

    private

    def fill(text, pair)
      text.gsub('%{receiver}', pair[:receiver][:name])
    end
  end
end
