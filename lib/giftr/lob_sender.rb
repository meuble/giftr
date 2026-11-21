#encoding: utf-8

require 'cgi/escape'
require 'lob'

module Giftr

  # Postcard sender using Lob (lob gem >= 6).
  #
  # Config (config/lob.yml):
  #   :api_key: Lob API key (test_... or live_...)
  #   :from:    optional sender address (hash, same keys as below, or a Lob address id);
  #             required by Lob for postcards sent outside the US
  #   :front:   optional front artwork (URL, HTML or Lob template id)
  #
  # Each giver needs an :address with :name, :address_line1, [:address_line2], :address_city,
  # [:address_state], :address_zip and :address_country (2-letter code, e.g. FR).
  # Legacy keys :city, :state, :zip and :country are accepted too.
  class LobSender < SenderBase
    DEFAULT_FRONT = "https://www.lob.com/postcardfront.pdf"
    MESSAGE = "Bonjour !\n\nL'heureux élu qui recevra ton magnifique cadeau sera : %{receiver} \\o/.\nSi tu as la moindre question, n'hésite pas à revenir vers moi.\n\n--\nLe gentil lutin de noël"
    LEGACY_ADDRESS_KEYS = {:city => :address_city, :state => :address_state, :zip => :address_zip, :country => :address_country}

    attr_accessor :lob

    def initialize(options = {})
      @config = YAML.load_file(options[:config_path] || File.join(Dir.pwd, 'config', 'lob.yml'))
      lob_config = Lob::Configuration.new
      lob_config.username = @config[:api_key]
      self.lob = Lob::PostcardsApi.new(Lob::ApiClient.new(lob_config))
    end

    def send(pair, front = @config[:front] || DEFAULT_FRONT)
      postcard = {
        :to => lob_address({:name => pair[:giver][:name]}.merge(pair[:giver][:address])),
        :front => front,
        :back => back_html(MESSAGE.gsub('%{receiver}', pair[:receiver][:name]))
      }
      from = @config[:from]
      postcard[:from] = from.is_a?(Hash) ? lob_address(from) : from if from
      self.lob.create(Lob::PostcardEditable.new(postcard))
    end

    private

    def lob_address(address)
      attributes = address.map { |key, value| [LEGACY_ADDRESS_KEYS.fetch(key.to_sym, key.to_sym), value.to_s] }.to_h
      Lob::AddressEditable.new(attributes)
    end

    def back_html(message)
      "<html><body style='padding: 0.5in; font-size: 14px;'>#{CGI.escapeHTML(message).gsub("\n", '<br>')}</body></html>"
    end
  end

end
