local M = {}

M.glypherDir = vim.fn.stdpath('cache')
M.glypherPath = M.glypherDir .. '/glypher.lua'

M.update = function()
    local Job = require('plenary.job')
    vim.notify('NGG: Updating Glyphs', vim.log.levels.DEBUG)
    if not Job then
        os.execute('python3 scripts/glypher.py -f ' .. M.glypherPath) -- replace with plenary job
        vim.notify('NGG: Done Updating Glyphs', vim.log.levels.INFO)
        return
    end

    vim.notify('NGG: Found Plenary!!', vim.log.levels.DEBUG)
    Job:new({
        command = 'python3',
        args = { 'scripts/glypher.py', '-f', M.glypherPath },
        on_exit = function(_, _)
            vim.notify('NGG: Done Updating Glyphs', vim.log.levels.INFO)
        end,
    }):start()
end

M.setup = function(opts)
    M.opts = opts
    if vim.fn.filereadable(M.glypherPath) == 0 then
        M.update()
    end
end

M.telescope = function()
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local conf = require("telescope.config").values

    local chunk, _ = loadfile(M.glypherPath)
    local glyphs = {}
    if chunk then
        -- Execute the chunk to define 'foo' in the current environment
        local M = chunk()

        glyphs = M.GetGlyphs()
    end

    local colors = function(opts)
        opts = opts or {}
        pickers.new(opts, {
            prompt_title = "Glyph Description",
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
    colors(M.opts.telescope)
end

return M

