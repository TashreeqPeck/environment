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
