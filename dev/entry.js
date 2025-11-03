const Ajv = require('ajv')
const yaml = require('js-yaml')

const ajv = new Ajv()

// Define createValidator function that compiles AJV validator from schema string
function createValidator(schemaString) {
  const schema = JSON.parse(schemaString)
  return ajv.compile(schema)
}

// Define function to validate YAML string using validator
function validateYaml(validateFunc, yamlString) {
  const data = yaml.load(yamlString)
  const valid = validateFunc(data)
  return {
    errors: valid ? null : validateFunc.errors
  }
}

// Export functions for browserify bundle
// Make them available globally for V8 R package
global.createValidator = createValidator
global.validateYaml = validateYaml
