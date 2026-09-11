const Ajv = require('ajv')
const yaml = require('js-yaml')

const ajv = new Ajv({ verbose: true })

// Matches what R's yaml::read_yaml() loads: it never guesses dates from
// unquoted scalars. Merge keys and the explicit tags are kept since R
// still resolves those. See #67.
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
