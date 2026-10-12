# Internal validator based on a JSON schema

Based on a JSON schema, [ajv](https://ajv.js.org) is used to create a
validator object in Javascript that can be used to check a
configuration. This is done in a QuickJS context
([QuickJSR::JSContext](https://rdrr.io/pkg/QuickJSR/man/JSContext.html)),
and stored inside the `context` property of the the object.

All YAML is parsed in R, so the validated data is exactly what R reads:

- Files are read with
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- `list` and `S7schema` objects are converted with
  [`to_yaml()`](https://novonordisk-opensource.github.io/S7schema/reference/to_yaml.md)
  and read back with
  [`yaml::yaml.load()`](https://yaml.r-lib.org/reference/yaml.load.html),
  so the validated data matches what
  [`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.md)
  writes.

The resulting `list` is converted to JSON with
[`jsonlite::toJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
and validated by ajv. The JavaScript side never parses YAML. `NA`,
`NaN`, and `Inf` values become `null` in the JSON sent to ajv.

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

  [QuickJSR::JSContext](https://rdrr.io/pkg/QuickJSR/man/JSContext.html)
  with a validator object based on the schema
