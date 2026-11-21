#encoding: utf-8

require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'giftr', 'draw_log')
require 'tmpdir'

describe Giftr::DrawLog do
  let(:pairs) { [{:giver => {:name => "A"}, :receiver => {:name => "B"}}, {:giver => {:name => "B"}, :receiver => {:name => "A"}}] }

  it "should write a log that does not show names in clear and reads back" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'logs', 'test.draw')
      Giftr::DrawLog.write(path, pairs)
      expect(File.read(path)).not_to include("receiver")
      expect(Giftr::DrawLog.read(path)[:pairs]).to eq([{:giver => "A", :receiver => "B"}, {:giver => "B", :receiver => "A"}])
    end
  end

  it "should refuse to overwrite an existing log" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'test.draw')
      Giftr::DrawLog.write(path, pairs)
      expect { Giftr::DrawLog.write(path, pairs) }.to raise_error(RuntimeError)
    end
  end

  it "should set previous_receiver to the person each one received from" do
    people = [{:name => "A"}, {:name => "B"}, {:name => "C"}]
    log = {:pairs => [{:giver => "A", :receiver => "B"}, {:giver => "B", :receiver => "C"}, {:giver => "C", :receiver => "A"}]}
    expect(Giftr::DrawLog.apply(people, log)).to eq([{:name => "A", :previous_receiver => "C"}, {:name => "B", :previous_receiver => "A"}, {:name => "C", :previous_receiver => "B"}])
  end

  it "should clear previous_receiver for people absent from the log" do
    people = [{:name => "A", :previous_receiver => "X"}, {:name => "B"}, {:name => "D", :previous_receiver => "A"}]
    log = {:pairs => [{:giver => "A", :receiver => "B"}, {:giver => "B", :receiver => "A"}]}
    expect(Giftr::DrawLog.apply(people, log)).to eq([{:name => "A", :previous_receiver => "B"}, {:name => "B", :previous_receiver => "A"}, {:name => "D"}])
  end
end
