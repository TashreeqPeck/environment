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

        -- switch between buffers
        ["<Tab>"] = { "<cmd> bnext <CR>", "Cycle buffers right" },
        ["<S-Tab>"] = { "<cmd> bprev <CR>", "Cycle buffers left" },

        -- close close current buffer
        ["<leader>bd"] = { "<cmd> bnext <CR> <cmd> bdelete # <CR>", "Close current buffer" },
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

M.gitsigns = {
    plugin = true,
    n = {
        ["<leader>gh"] = { "<cmd> Gitsigns toggle_linehl <CR>", "Toggle status highlighting" },
        ["<leader>gd"] = { "<cmd> Gitsigns toggle_word_diff <CR>", "Toggle git word diff" },
        ["<leader>gb"] = { "<cmd> Gitsigns toggle_current_line_blame <CR>", "Toggle git blame" },
    },
}

return M
