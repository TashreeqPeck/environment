-- load config
require("config")

-- load plugins
require("lazy").setup("plugins", {
  checker = { enabled = true, notify = false},
})
