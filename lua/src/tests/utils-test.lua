local utils = require('utils')

describe('isArray', function()
  it('handles numbers', function()
    expect(utils.isArray(99)):toBe(false)
  end)

  it('handles strings', function()
    expect(utils.isArray('string')):toBe(false)
  end)

  it('handles tables', function()
    expect(utils.isArray({ [2] = 2, [1] = 1 })):toBe(false)
  end)

  it('handles arrays', function()
    expect(utils.isArray({ 1, 2, 3 })):toBe(true)
  end)
end)

describe('serialize', function() end)
