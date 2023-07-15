return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
        require("lualine").setup({
            options = {
                ignore_focus = {
                    "NvimTree",
                },
                disabled_filetypes = {
                    "lazygit",
                },
                globalstatus = true,
            },
        })
    end
}
