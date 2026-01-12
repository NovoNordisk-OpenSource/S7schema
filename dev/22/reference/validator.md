# Internal validator based on a JSON schema

Based on a JSON schema, [ajv](https://ajv.js.org) is used to create a
validator object in Javascript that can be used to check an input yaml.
This is done in a
[`V8::v8()`](https://jeroen.r-universe.dev/V8/reference/V8.html)
context, and stored inside the `context` property of the the object.

See [json-schema.org](https://json-schema.org) on how to specify a JSON
schema.

## Usage

``` r
validator(schema)
```

## Arguments

- schema:

  `character(1)` path to a JSON schema.

## Value

New `validator` object

## Properties

- context:

  [`V8::v8()`](https://jeroen.r-universe.dev/V8/reference/V8.html)
  context with a validator object based on the schema
