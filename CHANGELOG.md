# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-31

### Added
- Initial release of YGOPRODECK Elixir API client
- Support for fetching cards by ID or exact name
- Support for searching cards with parameters (fuzzy name, type, race, attribute, etc.)
- Pluggable HTTP client architecture (Finch and Req adapters)
- Structured error handling (`:not_found`, `:rate_limited`, `:api_error`, `:network_error`)
