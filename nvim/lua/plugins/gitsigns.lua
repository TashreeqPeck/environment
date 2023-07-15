return {
    "lewis6991/gitsigns.nvim",
    init = function()
        require("utils").load_mappings("gitsigns")
    end,
    opts = {},
    config = function(_, opts)
        require("gitsigns").setup(opts)
    end
}
