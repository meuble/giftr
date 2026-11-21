require './lib/giftr'
require './lib/giftr/sender_base'
require './lib/giftr/mailer'
require './lib/giftr/draw_log'

# Usage:
#   bundle exec ruby giftr_launcher.rb [PEOPLE_FILE]          # dry run: validates config and draw, sends nothing
#   bundle exec ruby giftr_launcher.rb [PEOPLE_FILE] --send   # logs the draw, then really sends the emails
#   bundle exec ruby giftr_launcher.rb [PEOPLE_FILE] --apply-log logs/people_2026.draw
#                                     # next year: fill previous_receiver from that log
# PEOPLE_FILE defaults to config/people.yml. Email settings and message come from config/mailer.yml.

args = ARGV.dup
log_arg = (i = args.index('--apply-log')) ? args.slice!(i, 2)[1] || abort('Usage: --apply-log PATH') : nil
SEND = !args.delete('--send').nil?
abort("Unknown option(s): #{args.grep(/^--/).join(' ')}") unless args.grep(/^--/).empty?
CONFIG = args.first || File.join('.', 'config', 'people.yml')
abort("People file not found: #{CONFIG}") unless File.exist?(CONFIG)
LOG = File.join('.', 'logs', "#{File.basename(CONFIG, '.yml')}_#{Time.now.year}.draw")

if log_arg
  log = Giftr::DrawLog.read(log_arg)
  people = YAML.load_file(CONFIG)
  updated = Giftr::DrawLog.apply(people, log)
  missing = people.map { |p| p[:name] } - log[:pairs].map { |p| p[:receiver] }
  FileUtils.cp(CONFIG, "#{CONFIG}.bak")
  File.write(CONFIG, YAML.dump(updated))
  puts "Updated previous_receiver in #{CONFIG} from draw of #{log[:date]} (backup: #{CONFIG}.bak)."
  puts "Not in that draw, previous_receiver cleared: #{missing.join(', ')}" unless missing.empty?
  exit
end

giftr = Giftr::Event.new(CONFIG)
names = giftr.names

# Config sanity checks: a misspelled previous_receiver silently disables the constraint
errors = []
errors << "Duplicate names: #{names.select { |n| names.count(n) > 1 }.uniq}" if names.uniq.size != names.size
giftr.people.each do |p|
  errors << "Missing email for #{p[:name]}" if p[:email].to_s.strip.empty?
  if p[:previous_receiver] && !names.include?(p[:previous_receiver])
    errors << "#{p[:name]}: previous_receiver '#{p[:previous_receiver]}' matches no name"
  end
end
abort("Config errors:\n  " + errors.join("\n  ")) unless errors.empty?

pairs = giftr.pairs

# Re-check the draw independently before sending anything
# previous_receiver = who gave to that person last year
prev = giftr.people.to_h { |p| [p[:name], p[:previous_receiver]] }
couple = giftr.people.to_h { |p| [p[:name], p[:couple_id]] }
pairs.each do |pair|
  g, r = pair[:giver][:name], pair[:receiver][:name]
  abort('Invalid draw: someone gives to themselves') if g == r
  abort('Invalid draw: couple pairing') if couple[g] && couple[g] == couple[r]
  abort('Invalid draw: same pair as last year') if prev[r] == g
  abort('Invalid draw: return gift to last year giver') if prev[g] == r
end
abort('Invalid draw: not everyone gives/receives once') unless
  pairs.map { |p| p[:giver][:name] }.sort == names.sort && pairs.map { |p| p[:receiver][:name] }.sort == names.sort

puts "Draw OK for #{pairs.size} people (pairs kept secret)."

unless SEND
  puts "Dry run: nothing sent. Re-run with --send to log the draw to #{LOG} and email everyone."
  exit
end

abort("#{LOG} already exists: this year's draw was already sent. Move it away to redraw.") if File.exist?(LOG)
mailer = Giftr::Mailer.new # fail on bad SMTP config before logging
Giftr::DrawLog.write(LOG, pairs)
puts "Draw logged to #{LOG}"

pairs.each do |pair|
  puts "Envoi à #{pair[:giver][:name]}"
  mailer.send(pair)
end
puts 'Done.'
