
<!-- README.md is generated from README.Rmd. Please edit that file -->

# S7schema

<!-- badges: start -->

[![R-CMD-check](https://github.com/NN-OpenSource/S7schema/actions/workflows/check_and_co.yaml/badge.svg)](https://github.com/NN-OpenSource/S7schema/actions/workflows/check_and_co.yaml)
<!-- badges: end -->

The purpose of S7schema is to provide a generic way of working with yaml
config files. The implementation will: 1. Use S7 for easy downstream use
in other packages (e.g. new child classes and methods). 1. Use
[‘ajv’](https://ajv.js.org) for validation of the config file given JSON
schema. 1. S7 class will inherit from `list` ensuring a seamless
integration into existing code.

## Pseudo-code

A new instance of an `S7schema` class can be initiated with:

``` r
config <- S7schema("path/to/my/config.yml", "path/to/my/schema.json")
```

Since config is a list it can be updated (here adding an “a” element):

``` r
config$a <- 2
```

And it can be validated again:

``` r
validate_schema(config)
```

Which will now throw an error if `a = 2` is an illegal entry according
to the schema in `"path/to/my/schema.json"`.
