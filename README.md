# Session Validator Client Ruby ![Build Status](https://github.com/emartech/session-validator-client-ruby/actions/workflows/ruby.yml/badge.svg)

Ruby client for Emarsys session validator service.

## Install

```bash
gem install session-validator-client
```

## Usage

Copy `.env.example` to `.env` and set the necessary values for usage in your service.

### Create client
```ruby
require "session_validator"

client = SessionValidator::Client.new
```

### Requests without Escher
For mTLS on GAP.

```ruby
require "session_validator"

client = SessionValidator::Client.new(use_escher: false)
```

### Validating a single MSID
```ruby
client.valid?("staging_int_5ad5f96f307cf9.61063404")
```

### Batch validating multiple MSIDs
Returns an array of the invalid MSIDs.
```ruby
client.filter_invalid(["staging_int_5ad5f96f307cf9.61063404", "staging_int_5ad5f96f307cf9.61063405"])
```

## Local development

### Running tests
```bash
make test
```
