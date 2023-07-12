return {
    "rebelot/kanagawa.nvim",
    opts = {
        background = {
            dark = "dragon"
        },
    },
    config = function(_, opts)
        require("kanagawa").setup(opts)
        vim.cmd("colorscheme kanagawa")
    end,
}
