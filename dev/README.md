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

The `dev/entry.js` script uses the [ajv](https://ajv.js.org) and
[js-yaml](https://www.npmjs.com/package/js-yaml) node packages to validate a
yaml input against a [JSON-schema](https://json-schema.org) definition.

It exports the following functions that are used inside the R functions using
the V8 package:

1. `createValidator()`: Compiles AJV validator from schema string
2. `validateYaml()`: Validates YAML string using validator

The script is bundled and put into `inst/bundle.js` in order for us to get a
single `.js` file that can be loaded in V8 and contains all dependencies.

A new bundled script is create with [Browserify](https://browserify.org):

```bash
browserify dev/entry.js -o inst/bundle.js
```

Note this requires that the dependencies of `dev/entry.js` are installed.
Install them with:

```bash
cd dev
npm install
cd ..
```

Read more in this the [Using NPM packages in
V8](https://cran.r-project.org/web/packages/V8/vignettes/npm.html) vignette.

### License

Only embed javascript modules that are compatiable with the license og S7schema
(APACHE 2.0). Currently using the following modules and licenses:

| Package                           | License      |
|:----------------------------------|:-------------|
| node_modules/ajv                  | MIT          |
| node_modules/argparse             | Python-2.0   |
| node_modules/fast-deep-equal      | MIT          |
| node_modules/fast-uri             | BSD-3-Clause |
| node_modules/js-yaml              | MIT          |
| node_modules/json-schema-traverse | MIT          |
| node_modules/require-from-string  | MIT          |

Following the advice in [R
Packages](https://r-pkgs.org/license.html#sec-code-you-bundle) we include the
individual licenses in `inst/licenses` folder, mention them in `LICENSE.note`
and includer their authors as copyright holders in `DESCRIPTION`.

We have assesded the three licenses used (MIT, Python-2.0 , and BSD-3-Clause)
to be compatible with Apache 2.0, and therefore they can be bundled into this R
package.

If new development introduces new packages or newer version, it is required to
asses their license compatibility and update the files mentioned above as
appropiate.

To copy each license you can run the bash script below to copy all
individual licenses:

```bash
for license in $(find node_modules -maxdepth 2 -iname "license*" | sort); do
    package=$(dirname $license | xargs basename)
    cp "$license" "../inst/licenses/${package}-LICENSE"
  done
```
