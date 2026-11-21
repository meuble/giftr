# Giftr

A small Secret Santa tool: it draws who gives a gift to whom and tells each giver by email (or by postcard with Lob).

## Rules of the draw

- Nobody gives to themselves.
- Partners (same `couple_id`) don't draw each other.
- No A ↔ B swaps within the same draw.
- Nobody repeats last year: you can't give again to the person you gave to last year, nor to the person who gave to you.

## Setup

Requires Ruby 4.0 (see `.ruby-version`).

```sh
bundle install
cp config/mailer.yml.example config/mailer.yml   # SMTP settings + message
cp config/people.yml.example config/people.yml   # participants
```

### People file

```yaml
- :name: Alice
  :email: alice@example.com
  :couple_id: smith               # optional, partners share the same id
  :previous_receiver: Bob         # optional, who gave Alice a gift last year
```

### Message

In `config/mailer.yml`, set `:from`, `:subject` and `:body`. `%{receiver}` is replaced by the receiver's name.

## Usage

```sh
bundle exec ruby giftr_launcher.rb config/people.yml          # dry run: checks config and draw, sends nothing
bundle exec ruby giftr_launcher.rb config/people.yml --send   # saves the draw in logs/, then sends the emails
```

The draw is never printed, so the organiser can take part too.

### Next year

Each sent draw is saved in `logs/` (encoded, so you won't see it by accident). Use it to fill in `previous_receiver`:

```sh
bundle exec ruby giftr_launcher.rb config/people.yml --apply-log logs/people_2026.draw
```

Keep the log file safe: it is not in git.

## Postcards (Lob)

`Giftr::LobSender` sends a postcard instead of an email. See `config/lob.yml.example`. Each person needs an `:address` with a two-letter `:address_country` (e.g. `FR`).

## Tests

```sh
bundle exec rspec
```
