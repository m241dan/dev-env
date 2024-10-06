local plugins_path = vim.fn.stdpath("data") .. "/plugins"
local parsers = require("nvim-treesitter.parsers").get_parser_configs()

parsers.c.install_info.url = plugins_path .. "/tree-sitter-c"
parsers.cpp.install_info.url = plugins_path .. "/tree-sitter-cpp"
parsers.lua.install_info.url = plugins_path .. "/tree-sitter-lua"
parsers.python.install_info.url = plugins_path .. "/tree-sitter-python"
parsers.cmake.install_info.cmake = plugins_path .. "/tree-sitter-cmake"
parsers.csv.install_info.csv = plugins_path .. "/tree-sitter-csv"
parsers.dockerfile.install_info.dockerfile = plugins_path .. "/tree-sitter-dockerfile"
parsers.doxygen.install_info.doxygen = plugins_path .. "/tree-sitter-doxygen"
parsers.git_config.install_info.git_config = plugins_path .. "/tree-sitter-git-config"
parsers.git_rebase.install_info.git_rebase = plugins_path .. "/tree-sitter-git-rebase"
parsers.gitattributes.install_info.gitattributes = plugins_path .. "/tree-sitter-gitattributes"
parsers.gitcommit.install_info.gitcommit = plugins_path .. "/tree-sitter-gitcommit"
parsers.gitignore.install_info.gitignore = plugins_path .. "/tree-sitter-gitignore"
parsers.go.install_info.go = plugins_path .. "/tree-sitter-go"
parsers.json.install_info.json = plugins_path .. "/tree-sitter-json"
parsers.proto.install_info.proto = plugins_path .. "/tree-sitter-proto"
parsers.rust.install_info.rust = plugins_path .. "/tree-sitter-rust"
parsers.toml.install_info.toml = plugins_path .. "/tree-sitter-toml"
parsers.xml.install_info.xml = plugins_path .. "/tree-sitter-xml"
parsers.yaml.install_info.yaml = plugins_path .. "/tree-sitter-yaml"
parsers.elm.install_info.elm = plugins_path .. "/tree-sitter-elm"
parsers.elixir.install_info.elixir = plugins_path .. "/tree-sitter-elixir"
parsers.erlang.install_info.erlang = plugins_path .. "/tree-sitter-erlang"

vim.defer_fn(function()
    require('nvim-treesitter.configs').setup({
        ensure_installed = {
            'c', 'cpp', 'lua', 'python', 'cmake', 'csv', 'dockerfile', 'doxygen',
            'elixir', 'elm', 'erlang',
            'git_config', 'git_rebase', 'gitattributes', 'gitcommit', 'gitignore',
            'go', 'json', 'proto', 'rust', 'toml', 'xml', 'yaml',
        },
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    })
end, 0)

