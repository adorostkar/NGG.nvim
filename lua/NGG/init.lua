
local M = {}

M.update = function()
    local glypherPath = vim.fn.stdpath('cache') .. '/glypher.lua'
    os.execute('python3 scripts/glypher.py -f ' .. glypherPath) -- replace with plenary job
end

M.setup = function(opt)
end

return M

