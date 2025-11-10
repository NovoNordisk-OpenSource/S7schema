# S7schema

The purpose of S7schema is to provide a generic way of working with yaml
config files. The implementation will:

1.  Use S7 for easy downstream use in other packages (e.g. new child
    classes and methods).
2.  Use [‘ajv’](https://ajv.js.org) for validation of the config file
    given JSON schema.
3.  S7 class will inherit from `list` ensuring a seamless integration
    into existing code.

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
validate(config)
```

Which will now throw an error if `a = 2` is an illegal entry according
to the schema in `"path/to/my/schema.json"`.
