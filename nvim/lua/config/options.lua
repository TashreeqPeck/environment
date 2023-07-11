local options = {
    number = true, -- enable line numbers
    cursorline = true, -- highlight the current line
    expandtab = true, --convert tabs to spaces
    shiftwidth = 4, -- number of spaces for each indent
    tabstop = 4, -- insert 4 spaces for a tab
}

for key, value in pairs(options) do
    vim.opt[key] = value
end

