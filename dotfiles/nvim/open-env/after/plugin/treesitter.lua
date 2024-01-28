local plugins_path = vim.fn.stdpath("data") .. "/plugins"
local parsers = require("nvim-treesitter.parsers").get_parser_configs()

parsers.c.install_info.url = plugins_path .. "/tree-sitter-c"
parsers.cpp.install_info.url = plugins_path .. "/tree-sitter-cpp"
parsers.lua.install_info.url = plugins_path .. "/tree-sitter-lua"
parsers.python.install_info.url = plugins_path .. "/tree-sitter-python"

vim.defer_fn(function()
    require('nvim-treesitter.configs').setup({
        ensure_installed = {'c', 'cpp', 'lua', 'python'},
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    })
end, 0)

