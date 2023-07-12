return {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    init = function()
        require("utils").load_mappings("nvimtree")
    end,
    opts = {
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,
        sync_root_with_cwd = true,
    },
    config = function(_, opts)
        require("nvim-tree").setup(opts)
    end,
}
