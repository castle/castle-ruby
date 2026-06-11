# Fern SDK generator scaffold (proposal)

This directory is a **proposal** for generating the Castle Ruby SDK from a shared
OpenAPI spec using [Fern](https://buildwithfern.com/).

## Layout

- `fern.config.json` — Fern CLI configuration (organization and CLI version).
- `generators.yml` — generator definitions; defines the `ruby-sdk` group that
  runs the `fernapi/fern-ruby-sdk` generator against the spec.
- `openapi/openapi.yml` — the OpenAPI spec describing the Castle API
  (scoring, Lists, Privacy and Events endpoints).

## Usage

Install the Fern CLI:

```bash
npm install -g fern-api
```

Validate the spec and configuration:

```bash
fern check
```

Generate the Ruby SDK locally:

```bash
fern generate --group ruby-sdk --local
```

Generated output is written to `../generated/ruby` and is **not** committed to
this repository.
