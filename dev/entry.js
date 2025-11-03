const Ajv = require('ajv')
const yaml = require('js-yaml')

const ajv = new Ajv()

// Define create_validator function that compiles AJV validator from schema string
function create_validator(schema_string) {
  const schema = JSON.parse(schema_string)
  return ajv.compile(schema)
}

// Define function to validate YAML string using validator
function validate_yaml(validate_func, yaml_string) {
  const data = yaml.load(yaml_string)
  const valid = validate_func(data)
  return {
    errors: valid ? null : validate_func.errors
  }
}

// Export functions for browserify bundle
// Make them available globally for V8 R package
global.create_validator = create_validator
global.validate_yaml = validate_yaml
