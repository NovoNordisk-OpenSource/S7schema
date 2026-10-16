const Ajv = require('ajv')

const ajv = new Ajv({ verbose: true })

// Compiled validator, set by createValidator()
let validate

// Compile and store AJV validator from schema string.
// Returns undefined on success (QuickJSR 1.3.1 converts null to a string, but
// undefined to NULL), or the error message if the schema is not valid JSON or
// not a valid JSON schema.
function createValidator (schemaString) {
  try {
    const schema = JSON.parse(schemaString)
    validate = ajv.compile(schema)
  } catch (e) {
    return e.message
  }
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
