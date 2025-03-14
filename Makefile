.PHONY: build install test sh

build: ; docker compose build
install: ; docker compose run --rm app bundle install
test: ; docker compose run --rm app bundle exec rspec
sh: ; docker compose run --rm app sh
