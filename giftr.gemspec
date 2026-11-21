Gem::Specification.new do |s|
  s.name        = "giftr"
  s.version     = "0.0.0"
  s.platform    = Gem::Platform::RUBY

  s.summary     = "Giftr - Decide who gives and who receives gifts with ease"
  s.description = "Giftr is a simple gem to let anyone organize gifting event. With simple config files, it possible to shuffle around participants to assign each of them another participant to make a gift to. The format allow for couple or previous event exclusion, and support postcard to be sent through a Lob sender. Other sender are easily configurable."

  s.authors     = ["Stéphane Akkaoui"]
  s.email       = ["s.akkaoui@foreverbije.com"]

  s.homepage    = "https://rubygems.org/gems/giftr"
  s.license     = "MIT"

  s.files       = Dir["lib/**/*.rb"]
end
