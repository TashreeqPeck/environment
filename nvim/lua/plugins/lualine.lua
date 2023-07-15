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
                globalstatus = true,
            },
        })
    end
}
