
local M = {}

M.update = function()
    -- run update code
    local Job = require('plenary.job')

    Job:new({
        command = 'python',
        args = { 'scripts/glypher.py', '-f ', vim.fn.stdpath('cache') .. 'glypher.lua' },
        cwd = '/usr/bin',
        env = { ['a'] = 'b' },
        on_exit = function(j, return_val)
            print(return_val)
            print(j:result())
        end,
    }):sync() -- or start()
end

M.setup = function()
    M.update()
end

return M

