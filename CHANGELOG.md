# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).
## Unreleased
### Added
- Specs for the railtie, the `bs_jwt:install` rake task, the factory defaults and the
  error paths of the JWKS lookup. SimpleCov measures the suite and fails it when line or
  branch coverage of `lib/` drops below 100%.
- CI comments the line and branch coverage on every pull request and uploads the HTML
  coverage report as a build artifact.

### Changed
- The gem is developed and tested with Ruby 4.0.6, `required_ruby_version` is `>= 3.2`.
- Updated the dependencies: `activesupport >= 7.0`, `faraday >= 2.0` (the `<= 2.0` upper
  bound is gone), `json-jwt >= 1.17`, and the development dependencies to their current
  versions (bundler 2.4+, factory_bot 6, pry-byebug 3.12, rake 13, rspec 3.13,
  rubocop 1.90, simplecov 1.1, webmock 3.26).
- The `bs_jwt:install` rake task writes to `$stdout` instead of `STDOUT`.

## [2.0.1] - 2018-07-23
No changes. Version 2.0.0 was accidentally deleted from ruby gems.

## [2.0.0] - 2018-07-13
### Removed
- Remove Authentication#buddy_id

## [1.2.0] - 2018-07-10
### Added
- Add issued_at to the authentication model

## [1.1.0] - 2018-07-09
### Added
- Authentication#to_h returns the instance attributes as hash.

### Changed
- Authentication.new now accepts an attribute hash.

## [1.0.3] - 2018-07-02
### Changed
- Rename factory authentication to bs_jwt_authentication.

## [1.0.2] - 2018-06-26
### Changed
- Set email and display_name in the authentication factory for better testing support.

## [1.0.1] - 2018-06-22
### Added
- `BsJwt.verify_and_decode/1` and `BsJwt.verify_and_decode_auth0_hash`, which basically do
the same as the bang version, but instead of raising exceptions, they return `nil`.

## [1.0.0] - 2018-06-22
### Added
- `Authentication` class, which is now returned by the `BsJwt.verify_and_decode!/1` and
`BsJwt.verify_and_decode_auth0_hash!/1` (formerly `process_auth0_hash/1`) in place of
a payload Hash.

### Changed
- `BsJwt.process_auth0_hash/1` has been renamed to `BsJwt.verify_and_decode_auth0_hash!/1`
- `BsJwt.process_jwt/1` has been renamed to `BsJwt.verify_and_decode!/1`
Due to the change in public method names, major version has been bumped to 1.

## Unreleased
### Added
- First version of this gem.
-----------------------------------------------------------------------------------------

Template:
## [0.0.0] - 2014-05-31
### Added
- something was added

### Changed
- something changed

### Deprecated
- something is deprecated

### Removed
- something was removed

### Fixed
- something was fixed

### Security
- a security fix

Following "[Keep a CHANGELOG](http://keepachangelog.com/)"
