return {
    "akinsho/bufferline.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    opts = {
        options = {
            separator_style = "thin",
            offsets = {{
                filetype = "NvimTree",
                text = "Explorer",
                text_align = "left"
            }},
        },
    },
    configuration = function(_, opts)
        require("bufferline").setup(opts)
    end
}
