# Document configuration schema

Creates markdown documentation of a configuration suitable for use in
e.g. vignettes to provide easy readable documentation for users.

## Usage

``` r
document_schema(x, header_start_level)
```

## Arguments

- x:

  `character(1)` path to JSON schema,
  [`list()`](https://rdrr.io/r/base/list.html) of already loaded
  specifications, or
  [`S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.md)
  object.

- header_start_level:

  `numeric(1)` Level of initial header. All subheaders will continuously
  he one level smaller.

## Value

`character(1)`/[`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html)
markdown with the documentation.

## Examples

``` r
# Simple example schema
system.file("examples/schema.json", package = "S7schema") |>
  document_schema(2) |>
  cat()
#> ## My config schema
#> 
#> Simple example schema with one allowed entry
#> 
#> |Type   |Additional Properties |
#> |:------|:---------------------|
#> |object |No                    |
#> 
#> ### Properties
#> 
#> |Name          |Description                    |Type   |Required |
#> |:-------------|:------------------------------|:------|:--------|
#> |my_config_var |My only configuration variable |number |No       |

# Changing header start level to 1
system.file("examples/schema.json", package = "S7schema") |>
  document_schema(1) |>
  cat()
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

# Example with definitions
system.file("examples/definitions.json", package = "S7schema") |>
  document_schema(2) |>
  cat()
#> ## Schema with definitions
#> 
#> Simple example with definitions
#> 
#> |Type   |Required      |Additional Properties |
#> |:------|:-------------|:---------------------|
#> |object |my_config_var |Yes                   |
#> 
#> ### Properties
#> 
#> |Name          |Description                    |Required |Type          |
#> |:-------------|:------------------------------|:--------|:-------------|
#> |my_config_var |My only configuration variable |Yes      |[my_config_var](#my_config_var)|
#> 
#> ## Definitions
#> 
#> ### my_config_var
#> 
#> More information on the variable
#> 
#> |Type   |
#> |:------|
#> |number |
```
