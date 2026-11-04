// Bump the development version in DESCRIPTION and add a NEWS.md bullet if
// inst/bundle.js or inst/licenses changed compared to the base commit.
// DESCRIPTION and NEWS.md are computed from the base commit, so reruns give
// the same result.
// Usage (from dev/, after node sync-licenses.js):
//   node bump-version.js <base-sha> <pr-number>
const { execFileSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const repoRoot = path.join(__dirname, '..')
const suffix = '-LICENSE'
const [base, pr] = process.argv.slice(2)

if (!base || !/^\d+$/.test(pr || '')) {
  console.log('Usage: node bump-version.js <base-sha> <pr-number>')
  process.exit(1)
}

function git (args) {
  return execFileSync('git', args, { cwd: repoRoot, encoding: 'utf8' })
}

// git diff --quiet exits 0 without differences and 1 with differences
function bundleChanged () {
  try {
    git(['diff', '--quiet', base, '--', 'inst/bundle.js', 'inst/licenses'])
    return false
  } catch (e) {
    if (e.status === 1) return true
    throw e
  }
}

if (!bundleChanged()) {
  console.log('inst/bundle.js and inst/licenses are unchanged, nothing to do')
  process.exit(0)
}

// Version x.y.z becomes x.y.z.9000, x.y.z.N becomes x.y.z.(N+1)
function bumpVersion (description) {
  const match = description.match(/^Version: (\d+\.\d+\.\d+)(?:\.(\d+))?$/m)
  if (!match) {
    console.log('::error::Unexpected Version field in DESCRIPTION')
    process.exit(1)
  }
  const dev = match[2] === undefined ? 9000 : Number(match[2]) + 1
  return `${match[1]}.${dev}`
}

// Top level package versions from a package-lock.json, by package name
function lockVersions (lock) {
  const versions = {}
  for (const [key, info] of Object.entries(JSON.parse(lock).packages)) {
    const name = key.replace(/^node_modules\//, '')
    if (key.startsWith('node_modules/') && !name.includes('node_modules/')) {
      versions[name] = info.version
    }
  }
  return versions
}

const description = git(['show', `${base}:DESCRIPTION`])
const news = git(['show', `${base}:NEWS.md`])
const baseVersions = lockVersions(git(['show', `${base}:dev/package-lock.json`]))
const headVersions = lockVersions(
  fs.readFileSync(path.join(__dirname, 'package-lock.json'), 'utf8')
)

// License files name @scope/name as @scope-name (see sync-licenses.js), so
// map file names back to package names via the packages in the lock file
const fileNames = {}
for (const pkg of Object.keys(headVersions)) {
  fileNames[pkg.replace('/', '-')] = pkg
}
const bundled = fs.readdirSync(path.join(repoRoot, 'inst', 'licenses'))
  .filter(file => file.endsWith(suffix))
  .map(file => file.slice(0, -suffix.length))
  .map(name => fileNames[name] || name)
  .sort()

const changes = bundled
  .filter(pkg => baseVersions[pkg] !== headVersions[pkg])
  .map(pkg =>
    `\`${pkg}\` ${baseVersions[pkg] || 'none'} → ${headVersions[pkg] || 'none'}`
  )

const bullet = changes.length > 0
  ? `* Updated bundled JavaScript dependencies in \`inst/bundle.js\`: ${changes.join(', ')} (#${pr}).`
  : `* Rebuilt \`inst/bundle.js\` with updated build tools (#${pr}).`

const version = bumpVersion(description)
const pkgMatch = description.match(/^Package: (.+)$/m)
if (!pkgMatch) {
  console.log('::error::Unexpected Package field in DESCRIPTION')
  process.exit(1)
}
const pkgName = pkgMatch[1].trim()
const header = `# ${pkgName} (development version)`

// Add the bullet first in an existing development section, otherwise add a
// new development section at the top
let newNews
const lines = news.split('\n')
if (lines[0] === header && lines[1] === '') {
  // Keep a blank line before a following header if the section is empty
  const insert = (lines[2] || '').startsWith('* ') ? [bullet] : [bullet, '']
  lines.splice(2, 0, ...insert)
  newNews = lines.join('\n')
} else {
  newNews = `${header}\n\n${bullet}\n\n${news}`
}

fs.writeFileSync(
  path.join(repoRoot, 'DESCRIPTION'),
  description.replace(/^Version: .*$/m, `Version: ${version}`)
)
fs.writeFileSync(path.join(repoRoot, 'NEWS.md'), newNews)

console.log(`Set Version to ${version} in DESCRIPTION`)
console.log(`Added to NEWS.md under '${header}':`)
console.log(bullet)
