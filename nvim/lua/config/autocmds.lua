-- auto close nvim tree if it is the last buffer open
vim.api.nvim_create_autocmd("BufEnter", {
    nested = true,
    callback = function()
        if
            #vim.api.nvim_list_wins() == 1
            and vim.fn.bufname():match("NvimTree") ~= nil
            and require("utils").is_modified_buffer_open("NvimTree") == false
        then
            vim.cmd("quit")
        end
    end
})

-- delete lazygit buffer when finished
vim.api.nvim_create_autocmd("BufEnter", {
    nested = true,
    callback = function()
        local bufnr = vim.fn.bufnr("lazygit")
        if bufnr ~= -1 then
            vim.cmd("bdelete " .. bufnr)
            vim.cmd("NvimTreeRefresh")
        end
    end
})
