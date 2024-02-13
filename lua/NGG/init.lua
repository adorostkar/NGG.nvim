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

M.show_finder = function()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local conf = require("telescope.config").values
    local themes = require("telescope.themes")

    local chunk, _ = loadfile(M.glypherPath)
    local glyphs = {}
    if chunk then
        glyphs = chunk().GetGlyphs()
    end

    local show_telescope = function(opts)
        opts = vim.tbl_extend('force', themes.get_dropdown(), opts or {})
        pickers.new(opts, {
            theme = "dropdown",
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
    show_telescope(M.opts.telescope)
end

M.show_finder2 = function()
    local Input = require("nui.input")
    local event = require("nui.utils.autocmd").event

    local input = Input(
        {
            position = "50%",
            size = {
                width = 20,
            },
            border = {
                style = "single",
                text = {
                    top = "Glyph Description",
                    top_align = "center",
                },
            },
            win_options = {
                winhighlight = "Normal:Normal,FloatBorder:Normal",
            },
        }, {
            prompt = "> ",
            on_close = function()
                print("Input Closed!")
            end,
            on_submit = function(value)
                print("Input Submitted: " .. value)
            end,
            on_change = function(value)
                print("Value changed: ", value)
            end,
        })

    -- mount/open the component
    input:mount()

    -- unmount component when cursor leaves buffer
    input:on(event.BufLeave, function()
        input:unmount()
    end)
end

return M

