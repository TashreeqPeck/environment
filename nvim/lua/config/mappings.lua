-- shorten funciton name
local keymap = require("utils").keymap

-- map <leader> to <space>
keymap("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-------------------------------------------------------------------------------
-- INSERT MODE --
-------------------------------------------------------------------------------

-- navigate within insert mode
keymap("i", "<C-h>", "<Left>", "Move left")
keymap("i", "<C-l>", "<Right>", "Move right")
keymap("i", "<C-j>", "<Down>", "Move down")
keymap("i", "<C-k>", "<Up>", "Move down")

-- go to beginning and end
keymap("i", "<C-b>", "<ESC>^i", "Beginning of line")
keymap("i", "<C-e>", "<End>", "End of line")
