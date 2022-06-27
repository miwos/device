local utils = require('utils')

local depth = 0
local report = {}

local currentFile
local currentSuite
local currentTest

local fileHasFailed = false
local suiteHasFailed = false
local testHasFailed = false

local function reset()
  depth = 0
  report = {
    files = { total = 0, failed = 0 },
    suites = { total = 0, failed = 0 },
    tests = { total = 0, failed = 0 },
  }
end

local function printIndent(text, _depth)
  print(utils.indent(_depth ~= nil and _depth or depth) .. text)
end

local function fail()
  if not fileHasFailed then
    report.files.failed = report.files.failed + 1
    local colorized = string.gsub(
      currentFile,
      '(.*/)(.*)(-test.lua)',
      '{error ×} {error %1}%2{error %3} \n'
    )
    print(colorized)
  end

  if not suiteHasFailed then
    report.suites.failed = report.suites.failed + 1
    printIndent(string.format('{error • %s} ', currentSuite), depth - 2)
  end

  if not testHasFailed then
    report.tests.failed = report.tests.failed + 1
    printIndent(string.format('{error > %s} ', currentTest), depth - 1)
  end

  fileHasFailed = true
  suiteHasFailed = true
  testHasFailed = true
end

local assertions = {}
function assertions:toBe(value)
  if value ~= self.value then
    fail()
    printIndent(
      string.format(
        '{gray {italic expect(}}{error %s}{gray {italic ):toBe(}}{success %s}{gray {italic )}} \n',
        utils.serialize(self.value, true),
        utils.serialize(value, true)
      )
    )
  end
end

local function runFile(fileName)
  currentFile = fileName
  report.files.total = report.files.total + 1

  fileHasFailed = false
  loadfile(fileName)()

  if not fileHasFailed then
    local colorized = string.gsub(
      fileName,
      '(.*/)(.*)(-test.lua)',
      '{success √} {gray %1}%2{gray %3} '
    )
    print(colorized)
  end

  return fileHasFailed
end

local function runDir(dirName)
  reset()
  local files = FileSystem.listFiles(dirName)
  for _, baseName in pairs(files) do
    Testing.runFile(dirName .. '/' .. baseName)
  end
end

local function printSummarySection(name, total, failed)
  local parts = {}

  if failed > 0 then
    parts[#parts + 1] = string.format('{error failed %s}', failed)
  end

  local passed = total - failed
  if passed then
    parts[#parts + 1] = string.format('{success passed %s}', passed)
  end

  print(
    string.format(
      '%s %s {gray of %s} ',
      name,
      table.concat(parts, '{gray ,} '),
      total
    )
  )
end

local function getSummary()
  print()
  printSummarySection('Files: ', report.files.total, report.files.failed)
  printSummarySection('Suites:', report.suites.total, report.suites.failed)
  printSummarySection('Tests: ', report.tests.total, report.tests.failed)
  return report.tests.failed == 0
end

function describe(name, fn)
  currentSuite = name
  report.suites.total = report.suites.total + 1

  suiteHasFailed = false
  depth = depth + 1
  fn()
  depth = depth - 1
end

function it(name, fn)
  currentTest = name
  report.tests.total = report.tests.total + 1

  testHasFailed = false
  depth = depth + 2
  fn()
  depth = depth - 2
end

function expect(value)
  return setmetatable({ value = value }, { __index = assertions })
end

Testing = {
  runFile = runFile,
  runDir = runDir,
  getSummary = getSummary,
}
