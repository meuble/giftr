#encoding: utf-8

require 'yaml'
require 'awesome_print'

class Giftr
  attr_reader :people

  def initialize(config_path = nil)
    @people = YAML.load_file(config_path || File.join(File.dirname(__FILE__), '..', 'config', 'people.yml'))
  end

  def names
    @names ||= @people.inject([]) {|acc, e| acc << e[:name]}
  end

  def emails
    @emails ||= @people.inject([]) {|acc, e| acc << e[:email]}
  end

  def pairs
    begin
      givers = @people.dup.shuffle
      receivers = @people.dup.shuffle
      acc = []
      givers.zip(receivers).each {|e1, e2| acc << {:giver => e1, :receiver => e2}}
    end while !self.check_pairs(acc)
    acc
  end

  def check_pairs(pairs)
    each_pair_criteria = pairs.inject(true) {|acc, pair| acc = acc && self.check_pair(pair) }
    each_pair_criteria && has_circular_pairs?(pairs)
  end

  def check_pair(pair)
    return false if pair[:giver] == pair[:receiver]
    return false if !pair[:giver][:couple_id].nil? && pair[:giver][:couple_id] == pair[:receiver][:couple_id]
    return true
  end

  def has_circular_pairs?(pairs)
    names_pairs = pairs.map{ |pair| [pair[:giver][:name], pair[:receiver][:name]] }.map(&:sort)
    names_pairs.uniq.length == names_pairs.length
  end
end