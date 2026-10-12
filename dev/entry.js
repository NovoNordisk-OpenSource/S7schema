const Ajv = require('ajv')

const ajv = new Ajv({ verbose: true })

// Define createValidator function that compiles AJV validator from schema string
function createValidator (schemaString) {
  const schema = JSON.parse(schemaString)
  return ajv.compile(schema)
}

// Define function to validate JSON string using validator.
// The data is parsed from YAML in R, so only JSON is handled here.
function validateJson (validateFunc, jsonString) {
  const data = JSON.parse(jsonString)
  const valid = validateFunc(data)
  return JSON.stringify({
    errors: valid ? null : validateFunc.errors
  })
}

// Export functions for browserify bundle
// Make them available globally for the QuickJSR R package
// (`global` is shimmed to `globalThis` in R/validator.R)
global.createValidator = createValidator
global.validateJson = validateJson
