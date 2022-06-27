require('Log')
require('Hmr')
require('Testing')

-- local tests = FileSystem.listFiles('lua/tests')
-- for _, file in pairs(tests) do
--   Testing.reset()
--   loadfile('lua/tests/' .. file)
--   print(Testing.fileHasFailed)
-- end

print('--')
Testing.runDir('lua/tests')
Testing.getSummary()

-- describe('Miwos', function()
--   it('works', function()
--     expect(99):notToBe(3)
--   end)

--   it('does stuff', function()
--     expect(3):toBe('hallooooo')
--     expect(3):notToBe(3)
--   end)

--   it("doesn't do stuff", function()
--     expect(3):notToBe(3)
--   end)
-- end)
