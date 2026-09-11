const Ajv = require('ajv')
const yaml = require('js-yaml')

const ajv = new Ajv({ verbose: true })

// The js-yaml default schema resolves unquoted scalars that look like dates
// (2025-08-06) to a Date, so a schema asking for a string fails. The JSON
// schema only resolves the types JSON has, which keeps such values as strings
// and matches what R's yaml reader returns. The merge key and the explicit
// tags are added back, since they are not type guesses. See issue #67.
const yamlSchema = yaml.JSON_SCHEMA.extend({
  implicit: [yaml.types.merge],
  explicit: [
    yaml.types.binary,
    yaml.types.omap,
    yaml.types.pairs,
    yaml.types.set
  ]
})

// Define createValidator function that compiles AJV validator from schema string
function createValidator (schemaString) {
  const schema = JSON.parse(schemaString)
  return ajv.compile(schema)
}

// Define function to validate YAML string using validator
function validateYaml (validateFunc, yamlString) {
  const data = yaml.load(yamlString, { schema: yamlSchema })
  const valid = validateFunc(data)
  return {
    errors: valid ? null : validateFunc.errors
  }
}

// Export functions for browserify bundle
// Make them available globally for V8 R package
global.createValidator = createValidator
global.validateYaml = validateYaml
