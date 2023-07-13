local M = {}

M.general = {
  i = {
        -- go to  beginning and end
        ["<C-b>"] = { "<ESC>^i", "Beginning of line" },
        ["<C-e>"] = { "<End>", "End of line" },

        -- navigate within insert mode
        ["<C-h>"] = { "<Left>", "Move left" },
        ["<C-l>"] = { "<Right>", "Move right" },
        ["<C-j>"] = { "<Down>", "Move down" },
        ["<C-k>"] = { "<Up>", "Move up" },
    },
  
  n = {
        -- switch between windows
        ["<C-h>"] = { "<C-w>h", "Window left" },
        ["<C-l>"] = { "<C-w>l", "Window right" },
        ["<C-j>"] = { "<C-w>j", "Window down" },
        ["<C-k>"] = { "<C-w>k", "Window up" },
    },
}

M.nvimtree = {
    plugin = true,

    n = {
        ["<leader>e"] = { "<cmd> NvimTreeToggle <CR>", "Toggle file tree" },
    },
}

M.lazygit = {
    plugin = true,
    n = {
        ["<leader>gg"] = { "<cmd> LazyGit <CR>", "Open Lazy Git" },
        ["<leader>gf"] = { "<cmd> LazyGitFilter <CR>", "View Git Commits" },
    },
}

return M
