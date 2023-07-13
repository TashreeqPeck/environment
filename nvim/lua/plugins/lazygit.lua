return {
    "kdheepak/lazygit.nvim",
    dependendencies = {
        "nvim-lua/plenary.nvim",
    },
    init = function()
        require("utils").load_mappings("lazygit")
    end
}
