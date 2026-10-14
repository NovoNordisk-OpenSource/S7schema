# Developer notes

## Purpose

The purpose of S7schema is to provide a generic way of working with yaml
config files. The implementation will:

1. Use S7 for easy downstream use in other packages (e.g. new child
    classes and methods).
2. Use [‘ajv’](https://ajv.js.org) for validation of the config file
    given JSON schema.
3. S7 class will inherit from `list` ensuring a seamless integration
    into existing code using yaml metadata, such as whirl, connector, and
    mighty.

### Pseudo-code

A new instance of an `S7schema` class can be initiated with:

```r
config <- S7schema("path/to/my/config.yml", "path/to/my/schema.json")
```

Since config is a list it can be updated (here adding an “a” element):

```r
config$a <- 2
```

And it can be validated again with:

```r
S7::validate(config)
```

Which will now throw an error if `a = 2` is an illegal entry according
to the schema in `"path/to/my/schema.json"`.

Since `S7schema` will have a validator method that checks if the content is in accordance
with the supplied JSON schema.

## Updating embedded javascript

The `dev/entry.js` script uses the [ajv](https://ajv.js.org) node package to
validate a JSON input against a [JSON-schema](https://json-schema.org) definition.
All YAML is parsed in R with the yaml package, and the resulting list is sent to
the validator as JSON, so the validated data is exactly what R reads.

It exports the following functions that are used inside the R functions using
the V8 package:

1. `createValidator()`: Compiles AJV validator from schema string
2. `validateJson()`: Parses a JSON string, validates it using the validator,
   and returns an object with the errors (or `null` if valid)

The script is bundled and put into `inst/bundle.js` in order for us to get a
single `.js` file that can be loaded in V8 and contains all dependencies.

A new bundled script is created with [Browserify](https://browserify.org),
which is pinned as a devDependency in `dev/package.json`:

```bash
cd dev
npm ci --ignore-scripts
npx --no browserify entry.js -o ../inst/bundle.js
cd ..
```

Read more in the [Using NPM packages in V8][v8-npm] vignette.

[v8-npm]: https://cran.r-project.org/web/packages/V8/vignettes/npm.html

### License

Only embed javascript modules that are compatible with the license of
S7schema (APACHE 2.0). Currently using the following modules and licenses:

| Package                           | License      |
|:----------------------------------|:-------------|
| node_modules/ajv                  | MIT          |
| node_modules/fast-deep-equal      | MIT          |
| node_modules/fast-uri             | BSD-3-Clause |
| node_modules/json-schema-traverse | MIT          |

Following the advice in [R
Packages](https://r-pkgs.org/license.html#sec-code-you-bundle) we include the
individual licenses in `inst/licenses` folder, mention them in `LICENSE.note`
and include their authors as copyright holders in `DESCRIPTION`.

We have assessed the two licenses used (MIT and BSD-3-Clause)
to be compatible with Apache 2.0, and therefore they can be bundled into this R
package.

If new development introduces new packages or newer version, it is required to
assess their license compatibility and update the files mentioned above as
appropriate.

To copy each license you can run the bash script below to copy all
individual licenses:

```bash
for license in $(find node_modules -maxdepth 2 -iname "license*" | sort); do
    package=$(dirname $license | xargs basename)
    cp "$license" "../inst/licenses/${package}-LICENSE"
  done
```
