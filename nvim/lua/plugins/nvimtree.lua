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
        hijack_unnamed_buffer_when_opening = false,
        sync_root_with_cwd = true,
        update_focused_file = {
            enable = true,
            update_root = false,
        },
        view = {
            side = "left",
            width = "23%",
            preserve_window_proportions = false,
        },
    },
    config = function(_, opts)
        require("nvim-tree").setup(opts)
    end,
}
