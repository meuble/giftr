#encoding: utf-8

require 'yaml'
require 'base64'
require 'fileutils'

module Giftr

  # Records who gives to whom, so next year's previous_receiver can be filled in.
  # The file is Base64-encoded so a glance at it doesn't spoil the surprise.
  module DrawLog
    module_function

    def write(path, pairs, time = Time.now)
      raise "#{path} already exists, refusing to overwrite a previous draw" if File.exist?(path)
      data = {
        :date => time.strftime('%Y-%m-%d %H:%M'),
        :pairs => pairs.map { |p| {:giver => p[:giver][:name], :receiver => p[:receiver][:name]} }
      }
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, Base64.encode64(YAML.dump(data)))
    end

    def read(path)
      YAML.load(Base64.decode64(File.read(path)))
    end

    # Returns people with previous_receiver set from the log.
    # previous_receiver = the person they received a gift from (the giver in the log).
    # People absent from the log (newcomers) lose any stale previous_receiver.
    def apply(people, log)
      received_from = log[:pairs].map { |p| [p[:receiver], p[:giver]] }.to_h
      people.map do |person|
        person = person.reject { |k, _| k == :previous_receiver }
        received_from.key?(person[:name]) ? person.merge(:previous_receiver => received_from[person[:name]]) : person
      end
    end
  end

end
