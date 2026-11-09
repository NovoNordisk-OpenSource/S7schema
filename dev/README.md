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

It exports the following functions, which are called from R with `$call()` of
the [QuickJSR](https://cran.r-project.org/package=QuickJSR) package:

1. `createValidator()`: Compiles the AJV validator from a schema string and
   stores it. Returns `undefined`, or the error message if the schema is
   invalid
2. `validateJson()`: Validates a JSON string with the stored validator, and
   returns the errors (or `null` if valid) as a JSON string

The script is bundled and put into `inst/bundle.js` in order for us to get a
single `.js` file that can be loaded in QuickJS and contains all dependencies.

A new bundled script is created with [Browserify](https://browserify.org),
which is pinned as a devDependency in `dev/package.json`:

```bash
cd dev
npm ci --ignore-scripts
npx --no browserify entry.js -o ../inst/bundle.js
node sync-licenses.js
cd ..
```

Dependencies are pinned to exact versions in `dev/package.json`.

### Dependabot pull requests

Dependabot opens npm pull requests for `dev/`. The `Bundle` workflow
(`.github/workflows/bundle.yaml`) rebuilds `inst/bundle.js` and
`inst/licenses`, bumps the development version and `NEWS.md`, and pushes a
commit `chore: rebuild bundle.js [dependabot skip]`.

Review the `dev/package-lock.json` diff and the release notes of the updated
packages, not `inst/bundle.js`.

To update a Dependabot pull request to the latest `main`, comment
`@dependabot rebase`. Do not use "Update branch": it makes you the last
pusher, so a second reviewer is needed.

On all other pull requests the workflow fails if `inst/bundle.js` or
`inst/licenses` are out of date with `dev/package-lock.json`. Rebuild with the
commands above.

If `sync-licenses.js` fails because the set of bundled packages changed,
handle the pull request manually (see [License](#license)).

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

`node sync-licenses.js` (from `dev/`) copies the license file of each package
included in the bundle (from `browserify --list`) to
`inst/licenses/<package>-LICENSE`. It fails if packages were added or removed,
as these need the manual steps: assess license compatibility, add or remove
license files, and update `LICENSE.note`, the copyright holders in
`DESCRIPTION`, and the table above.
