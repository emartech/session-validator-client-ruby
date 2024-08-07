# session-validator-client-ruby ![Build status](https://travis-ci.org/emartech/session-validator-client-ruby.svg?branch=master)

Ruby client for Emarsys session validator service.

## Install

```bash
gem install session-validator-client
```

## Usage

Setup the following environment variables:

* `KEY_POOL`
* `SESSION_VALIDATOR_KEYID`
* `SESSION_VALIDATOR_URL`

### Validating a single Msid
`valid?(msid)` returns `true` if `msid` is valid

```ruby
require "session_validator"

client = SessionValidator::Client.new
client.valid?("staging_int_5ad5f96f307cf9.61063404")
```

### Batch validating multiple MSIDS
`filter_invalid(msids)` returns an array of the invalid MSIDS.

```ruby
require "session_validator"

client = SessionValidator::Client.new
client.filter_invalid(["staging_int_5ad5f96f307cf9.61063404", "staging_int_5ad5f96f307cf9.61063405"])
```

### Service Mesh 
if your service is running on GAP with service mesh enabled and you are accessing the 
session-validator-service directly (using its internal GAP url), then you can tell the
SessionValidator client not to use Escher.

```ruby
require "session_validator"

client = SessionValidator::Client.new(use_escher: false)
client.valid?("staging_int_5ad5f96f307cf9.61063404")
# or
client.filter_invalid(["staging_int_5ad5f96f307cf9.61063404", "staging_int_5ad5f96f307cf9.61063405"])
```

## Running tests

```bash
$ bundle install
$ rspec
```
