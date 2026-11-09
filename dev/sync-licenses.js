// Copy the licenses of all npm packages bundled into inst/bundle.js to
// inst/licenses/<package>-LICENSE. Scoped packages use '-' instead of '/',
// e.g. @scope/name becomes @scope-name-LICENSE.
// Fails without copying anything if the set of bundled packages differs from
// the existing license files, since new packages require a manual review.
// Usage (from dev/, after npm ci --ignore-scripts): node sync-licenses.js
const { execFileSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const licensesDir = path.join(__dirname, '..', 'inst', 'licenses')
const suffix = '-LICENSE'

// Package name from the segment(s) after the last node_modules in a file path
function packageName (file) {
  const parts = file.split(path.sep)
  const i = parts.lastIndexOf('node_modules')
  if (i === -1) return null
  const name = parts[i + 1]
  return name.startsWith('@') ? name + '/' + parts[i + 2] : name
}

function licenseFileName (pkg) {
  return pkg.replace('/', '-') + suffix
}

// Files included in the bundle, one absolute path per line
const files = execFileSync(
  path.join(__dirname, 'node_modules', '.bin', 'browserify'),
  ['--list', 'entry.js'],
  { cwd: __dirname, encoding: 'utf8' }
).split('\n').filter(Boolean)

const bundled = [...new Set(files.map(packageName).filter(Boolean))].sort()
const expected = bundled.map(licenseFileName)
const existing = fs.readdirSync(licensesDir)
  .filter(file => file.endsWith(suffix))
  .sort()

const added = bundled.filter(pkg => !existing.includes(licenseFileName(pkg)))
const removed = existing.filter(file => !expected.includes(file))
  .map(file => file.slice(0, -suffix.length))

if (added.length > 0 || removed.length > 0) {
  console.log(
    '::error::Bundled npm packages changed. ' +
    `Added: ${added.join(', ') || 'none'}. ` +
    `Removed: ${removed.join(', ') || 'none'}.`
  )
  console.log('Update the licenses manually (see dev/README.md):')
  console.log('1. Assess license compatibility of added packages with Apache 2.0')
  console.log('2. Add or remove the license files in inst/licenses')
  console.log('3. Update LICENSE.note')
  console.log('4. Update the copyright holders in DESCRIPTION')
  console.log('5. Update the license table in dev/README.md')
  process.exit(1)
}

for (const pkg of bundled) {
  const pkgDir = path.join(__dirname, 'node_modules', pkg)
  const candidates = fs.readdirSync(pkgDir)
    .filter(file => /^licen[cs]e/i.test(file))
    .sort()
  if (candidates.length === 0) {
    console.log(`::error::No license file found in ${pkgDir}`)
    process.exit(1)
  }
  // Prefer an exact LICENSE file if several match
  const license = candidates.includes('LICENSE') ? 'LICENSE' : candidates[0]
  fs.copyFileSync(
    path.join(pkgDir, license),
    path.join(licensesDir, licenseFileName(pkg))
  )
  console.log(`Copied ${pkg}/${license} to inst/licenses/${licenseFileName(pkg)}`)
}
