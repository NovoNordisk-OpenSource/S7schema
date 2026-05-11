# Use S7schema in your package

## Introduction

If you maintain a package that requires a specific configuration format,
S7schema lets you define a validated config class with minimal code. By
extending `S7schema`, your package gets schema validation, YAML
reading/writing, and schema documentation for free.

## Define a schema

A JSON schema describes the structure and constraints of your
configuration. In a real package, the schema should live in `inst/`
(e.g. `inst/schema/my_schema.json`) so it ships with the package and can
be found via [`system.file()`](https://rdrr.io/r/base/system.file.html).

For this vignette we use the example schema bundled with S7schema:

``` r

schema_path <- system.file("examples/schema.json", package = "S7schema")
```

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

## Create a child class

The core pattern is to create an S7 class that inherits from `S7schema`
and hard-codes the schema path in its constructor:

``` r

my_config_class <- S7::new_class(
  name = "my_config_class",
  parent = S7schema::S7schema,
  constructor = function(file) {
    S7::new_object(
      .parent = S7schema::S7schema(
        file = file,
        schema = system.file("examples/schema.json", package = "S7schema")
      )
    )
  }
)
```

Users of your package only need to supply the config file path — the
schema is handled internally.

## Use the child class

### Construction

Creating an instance loads and validates the YAML file automatically:

``` r

config_path <- system.file("examples/config.yml", package = "S7schema")
x <- my_config_class(file = config_path)
print(x)
#> <my_config_class> List of 1
#>  $ my_config_var: int 1
#>  @ schema   : chr "/home/runner/work/_temp/Library/S7schema/examples/schema.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x55b1301f4f30> 
#>  @ file     : chr "/home/runner/work/_temp/Library/S7schema/examples/config.yml"
```

### Accessing values

Since `S7schema` objects are lists, values are accessed directly:

``` r

x$my_config_var
#> [1] 1
```

### Class hierarchy

The child class inherits from `S7schema`:

``` r

class(x)
#> [1] "my_config_class"    "S7schema::S7schema" "list"              
#> [4] "S7_object"
```

### Validation

[`S7::validate()`](https://rconsortium.github.io/S7/reference/validate.html)
works on the child class just like on the parent:

``` r

x$my_config_var <- "not a number"
S7::validate(x)
#> Error in `validate_S7schema()`:
#> ! /my_config_var must be number
#> ✖ type: number
```

### Method dispatch

Methods defined for `S7schema` work on child classes without extra code.

[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.md)
validates and writes to YAML:

``` r

tmp <- tempfile(fileext = ".yml")
x$my_config_var <- 42
write_config(x, path = tmp)
readLines(tmp)
#> [1] "my_config_var: 42.0"
```

[`document_schema()`](https://novonordisk-opensource.github.io/S7schema/reference/document_schema.md)
generates markdown documentation from the schema:

``` r

md <- document_schema(schema_path)
cat(md)
#> # My config schema
#> 
#> Simple example schema with one allowed entry
#> 
#> |Type   |Additional Properties |
#> |:------|:---------------------|
#> |object |No                    |
#> 
#> ## Properties
#> 
#> |Name          |Description                    |Type   |Required |
#> |:-------------|:------------------------------|:------|:--------|
#> |my_config_var |My only configuration variable |number |No       |
```

Note that if printed directly, the return of
[`document_schema()`](https://novonordisk-opensource.github.io/S7schema/reference/document_schema.md)
is displayed as-is.

The `header_start_level` parameter controls the depth of the generated
headings:

``` r

md <- document_schema(schema_path, header_start_level = 3)
cat(md)
#> ### My config schema
#> 
#> Simple example schema with one allowed entry
#> 
#> |Type   |Additional Properties |
#> |:------|:---------------------|
#> |object |No                    |
#> 
#> #### Properties
#> 
#> |Name          |Description                    |Type   |Required |
#> |:-------------|:------------------------------|:------|:--------|
#> |my_config_var |My only configuration variable |number |No       |
```
