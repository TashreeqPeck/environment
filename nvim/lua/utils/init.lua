local M = {}

-- Wrap vim.keymap to shorten function name
function M.keymap(mode, lhs, rhs, opts)
    if opts == nil or type(opts) == "string" then
        vim.keymap.set(mode, lhs, rhs, {
            noremap = true,
            silent = true,
            desc = opts or nil,
        })
    else
        local options = { noremap = true, silent = true }
        if opts then
            options = vim.tbl_extend("force", options, opts)
        end
        vim.keymap.set(mode, lhs, rhs, options)
    end
end

return M

