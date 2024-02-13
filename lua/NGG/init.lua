
local M = {}
M.glypherModule = 'lua/NGG'
M.glypherPath = M.glypherModule .. '/glypher.lua'

M.update = function()
    os.execute('python3 scripts/glypher.py -f ' .. M.glypherPath) -- replace with plenary job
end

M.setup = function(opt)
    if vim.fn.exists(M.glypherPath) == 0 then
        M.update()
    end
    local glyphs = require('NGG.glypher')
    -- glyphs.GetGlyphs()
end

return M

