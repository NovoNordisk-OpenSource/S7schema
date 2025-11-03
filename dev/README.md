# Developer notes

## Updating embedded javascript

The `dev/entry.js` script uses the [ajv](https://ajv.js.org) and [js-yaml](https://www.npmjs.com/package/js-yaml) node packages to validate a yaml input against a [JSON-schema](https://json-schema.org) definition.

It exports the following functions that are used inside the R functions using the V8 package:

1. `createValidator()`: Compiles AJV validator from schema string
2. `validateYaml()`: Validates YAML string using validator

The script is bundled and put into `inst/bundle.js` in order for us to get a single `.js` file
that can be loaded in V8 and contains all dependencies.

A new bundled script is create with [Browserify](https://browserify.org):

```
browserify dev/entry.js -o inst/bundle.js
```

Note this requires that the dependencies of `dev/entry.js` are installed.
Install them with:

```
npm install ajv
npm install js-yaml
```

Read more in this the [Using NPM packages in V8](https://cran.r-project.org/web/packages/V8/vignettes/npm.html) vignette.
