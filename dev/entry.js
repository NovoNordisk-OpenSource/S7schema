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
    valid: valid,
    data: data,
    errors: valid ? null : validate_func.errors
  }
}

// Define function to report validation results
function report_validation(result) {
  if (!result.valid) {
    console.log(result.errors)
  }
  console.log('validation done')
}

// Export functions for browserify bundle
// Make them available globally for V8 R package
if (typeof window !== 'undefined') {
  // Browser environment
  window.create_validator = create_validator
  window.validate_yaml = validate_yaml
  window.report_validation = report_validation
} else if (typeof global !== 'undefined') {
  // Node.js/V8 environment
  global.create_validator = create_validator
  global.validate_yaml = validate_yaml
  global.report_validation = report_validation
}

// Also make available on this context
this.create_validator = create_validator
this.validate_yaml = validate_yaml
this.report_validation = report_validation
