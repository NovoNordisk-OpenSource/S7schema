const Ajv = require('ajv')

const ajv = new Ajv({ verbose: true })

// Compiled validator, set by createValidator()
let validate

// Compile and store AJV validator from schema string
function createValidator (schemaString) {
  const schema = JSON.parse(schemaString)
  validate = ajv.compile(schema)
}

// Validate JSON string using the stored validator.
// The data is parsed from YAML in R, so only JSON is handled here.
// Returns the errors (or null if valid) as a JSON string.
function validateJson (jsonString) {
  const data = JSON.parse(jsonString)
  const valid = validate(data)
  return JSON.stringify({
    errors: valid ? null : validate.errors
  })
}

// Make functions available globally for the QuickJSR R package
globalThis.createValidator = createValidator
globalThis.validateJson = validateJson
