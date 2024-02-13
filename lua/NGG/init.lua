local M = {}

M.glypherModule = 'lua/NGG'
M.glypherPath = M.glypherModule .. '/glypher.lua'

M.update = function()
    vim.notify("NGG: Update Glyphs", vim.log.levels.INFO)
    os.execute('python3 scripts/glypher.py -f ' .. M.glypherPath) -- replace with plenary job
end

M.setup = function(opts)
    if vim.fn.filereadable(M.glypherPath) == 0 then
        M.update()
    end
end

M.telescope = function()
    local glyphs = require('NGG.glypher').GetGlyphs()
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local conf = require("telescope.config").values

    local colors = function(opts)
        opts = opts or {}
        pickers.new(opts, {
            prompt_title = "Glyph",
            finder = finders.new_table {
                results = glyphs,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = function(entr)
                            return string.format("%-40s %s", entr.value.key, entr.value.value)
                        end,
                        ordinal = entry.key,
                    }
                end
            },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function() -- default action is yank
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.fn.setreg('"', selection.value.value)
                    vim.notify('NGG: '.. selection.value.value .. ' Yanked to default register', vim.log.levels.INFO)
                end)

                return true
            end,
        }):find()
    end

    -- to execute the function
    colors()
end

return M

