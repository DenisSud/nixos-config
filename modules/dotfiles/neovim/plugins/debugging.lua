local dap = require('dap')
local dapui = require('dapui')

return {
  setup = function()
    dapui.setup()
    require('dap-python').setup('python')
  end
}
