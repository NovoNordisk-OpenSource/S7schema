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

  `numeric(1)` Level of initial header. All subheaders will continously
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
#> Error in map(vec_proxy(.x), .f, ...): ℹ In index: 1.
#> ℹ With name: $schema.
#> Caused by error in `map()`:
#> ℹ In index: 1.
#> Caused by error in `loadNamespace()`:
#> ! there is no package called ‘stringr’

# Changing header start level to 1
system.file("examples/schema.json", package = "S7schema") |>
  document_schema(1) |>
  cat()
#> Error in map(vec_proxy(.x), .f, ...): ℹ In index: 1.
#> ℹ With name: $schema.
#> Caused by error in `map()`:
#> ℹ In index: 1.
#> Caused by error in `loadNamespace()`:
#> ! there is no package called ‘stringr’

# Example with definitions
system.file("examples/definitions.json", package = "S7schema") |>
  document_schema(2) |>
  cat()
#> Error in map(vec_proxy(.x), .f, ...): ℹ In index: 1.
#> ℹ With name: $schema.
#> Caused by error in `map()`:
#> ℹ In index: 1.
#> Caused by error in `loadNamespace()`:
#> ! there is no package called ‘stringr’
```
