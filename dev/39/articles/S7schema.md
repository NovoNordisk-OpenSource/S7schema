# S7schema

## Introduction

S7schema provides a generic way of working with yaml config files. The
main functionality is captured in the
[`S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.md)
which we will explore in this vignette.

## Configuration and schema

First we find the example configuration and schema files that will be
used to demonstrate
[`S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.md).

``` r
ex_config <- system.file("examples/config.yml", package = "S7schema")
ex_schema <- system.file("examples/schema.json", package = "S7schema")
```

`schema.json` defines a very simple configuration file, that only
consists of one entry (`my_config_var`) which is a single number:

``` json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "title": "My config schema",
  "description": "Simple example schema with one allowed entry",
  "type": "object",
  "properties": {
    "my_config_var": {
      "description": "My only configuration variable",
      "type": "number"
    }
  },
  "additionalProperties": false
}
```

Our initial `config.yml` defines this entry to have the value `1`:

``` yaml
my_config_var: 1 
```

Which is obviously a valid configuration. But to check it
programmatically we can also use the one-shot validation function
[`validate_yaml()`](https://novonordisk-opensource.github.io/S7schema/reference/validate_config.md):

``` r
validate_yaml(file = ex_config, schema = ex_schema)
```

## Work with a configuration

Alternatively we can load, validate, and write the configuration with
the
[`S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.md)
class. To load it simple create a new `S7schema` object based on the
same config and schema files as above:

``` r
config <- S7schema(file = ex_config, schema = ex_schema)
print(config)
#> <S7schema::S7schema> List of 1
#>  $ my_config_var: int 1
#>  @ schema   : chr "/home/runner/work/_temp/Library/S7schema/examples/schema.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x56122270ad40> 
#>  @ .file    : chr "/home/runner/work/_temp/Library/S7schema/examples/config.yml"
```

Here you can see that `config` is a S7 object, that itself is a `list`
containing the content of `config.yml`. Which can be further seen by
inspecting the class:

``` r
class(config)
#> [1] "S7schema::S7schema" "list"               "S7_object"
```

Since it is a list, it is very easy to access the value of
`my_config_var` directly:

``` r
config$my_config_var
#> [1] 1
```

And similarly to overwrite the value:

``` r
config$my_config_var <- 2
validate(config)
print(config)
#> <S7schema::S7schema> List of 1
#>  $ my_config_var: num 2
#>  @ schema   : chr "/home/runner/work/_temp/Library/S7schema/examples/schema.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x5612230c5950> 
#>  @ .file    : chr "/home/runner/work/_temp/Library/S7schema/examples/config.yml"
```

Note that validation is not automatically triggered when updating a
value, which is why it is needed to call it explicitly.

This is also why we can update with an illegal entry below, but then get
an error when validating the updated object:

``` r
config$my_config_var <- "abc"
validate(config)
#> Error in `use_validator()`:
#> ! Validation failed for
#>   /home/runner/work/_temp/Library/S7schema/examples/config.yml
#> /my_config_var must be number
#> ✖ type: number
```

To save a configuration use
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.md):

``` r
write_config(
  x = config,
  file = "my/config.yml"
)
```

This is just a wrapper around
[`yaml::write_yaml()`](https://yaml.r-lib.org/reference/write_yaml.html),
but have the advantage that the `S7schema` input is always validated
before the file is created.
