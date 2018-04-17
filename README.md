# session-validator-client-ruby ![Build status](https://travis-ci.org/emartech/session-validator-client-ruby.svg?branch=master)

Ruby client for Emarsys session validator service.

## Install

```bash
gem install session-validator-client
```

## Usage

setup up the following environment variables:

* `KEY_POOL`
* `SESSION_VALIDATOR_KEYID`
* `SESSION_VALIDATOR_URL`

```ruby
require "session_validator"

client = SessionValidator::Client.new
client.valid?("staging_int_5ad5f96f307cf9.61063404")
```

## Running tests

```bash
rspec
```
