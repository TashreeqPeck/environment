local M = {}
local merge_tb = vim.tbl_deep_extend

-- make reassigning key mappings easier
M.load_mappings = function(section, mapping_opt)
  vim.schedule(function()
    local function set_section_map(section_values)
      if section_values.plugin then
        return
      end

      section_values.plugin = nil

      for mode, mode_values in pairs(section_values) do
        local default_opts = merge_tb("force", { mode = mode }, mapping_opt or {})
        for keybind, mapping_info in pairs(mode_values) do
          -- merge default + user opts
          local opts = merge_tb("force", default_opts, mapping_info.opts or {})

          mapping_info.opts, opts.mode = nil, nil
          opts.desc = mapping_info[2]

          vim.keymap.set(mode, keybind, mapping_info[1], opts)
        end
      end
    end

    local mappings = require("config.mappings")

    if type(section) == "string" then
      mappings[section]["plugin"] = nil
      mappings = { mappings[section] }
    end

    for _, sect in pairs(mappings) do
      set_section_map(sect)
    end
  end)
end

-- check if given modified buffer is open
M.is_modified_buffer_open = function(exclude_buffer)
    for _, buffer in pairs(vim.fn.getbufinfo({ bufmodified = 1 })) do
        if buffer.name:match(exclude_buffer) == nil then
            return true
        end
    end
    return false
end

return M
