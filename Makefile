.PHONY: test sh

test:
	docker compose run --rm app bash -c "bundle install && rspec"

sh:
	docker compose run --rm app bash -c "bundle install && bash"
