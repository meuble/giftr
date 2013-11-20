#encoding: utf-8

require "lob"

class LobSender < SenderBase
  attr_accessor :lob

  def initialize(options = {})
    @config = YAML.load_file(options[:config_path] || File.dirname(__FILE__) + '/../config/lob.yml')
    self.lob = Lob(:api_key => @config[:api_key])
  end

  def send(pair, picture = "https://www.lob.com/postcardfront.pdf")
    self.lob.postcards.create(
      pair[:giver][:name],
      pair[:giver][:address],
      :message => "Bonjour !\n\nL'heureux élu qui recevra ton magnifique cadeau sera : #{pair[:receiver][:name]} \\o/.\nSi tu as la moindre question, n'hésite pas à revenir vers moi.\n\n--\nLe gentil lutin de noël",
      :front => picture
    )
  end
end