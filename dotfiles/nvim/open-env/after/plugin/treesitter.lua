-- nvim-treesitter (`main` branch). Parsers are compiled with the tree-sitter CLI.
-- Grammars vendored in the dev-env repo (plugins/nvim/tree-sitter-*) are built
-- from the local checkout instead of being downloaded. Their submodules are
-- pinned to the revisions nvim-treesitter's queries are written against
-- (see lua/nvim-treesitter/parsers.lua in the plugin).
local ts = require('nvim-treesitter')
local plugins_path = vim.fn.stdpath("data") .. "/plugins"

-- parser name -> vendored grammar directory
local vendored = {
    c = "tree-sitter-c",
    cpp = "tree-sitter-cpp",
    lua = "tree-sitter-lua",
    python = "tree-sitter-python",
    cmake = "tree-sitter-cmake",
    csv = "tree-sitter-csv",
    tsv = "tree-sitter-csv", -- csv requires tsv; both live in the same repo
    dockerfile = "tree-sitter-dockerfile",
    doxygen = "tree-sitter-doxygen",
    elixir = "tree-sitter-elixir",
    elm = "tree-sitter-elm",
    erlang = "tree-sitter-erlang",
    git_config = "tree-sitter-git-config",
    git_rebase = "tree-sitter-git-rebase",
    gitattributes = "tree-sitter-gitattributes",
    gitcommit = "tree-sitter-gitcommit",
    gitignore = "tree-sitter-gitignore",
    go = "tree-sitter-go",
    json = "tree-sitter-json",
    proto = "tree-sitter-proto",
    rust = "tree-sitter-rust",
    toml = "tree-sitter-toml",
    xml = "tree-sitter-xml",
    dtd = "tree-sitter-xml", -- xml requires dtd; both live in the same repo
    yaml = "tree-sitter-yaml",
}

vim.api.nvim_create_autocmd('User', {
    pattern = 'TSUpdate',
    group = vim.api.nvim_create_augroup('user-ts-local-parsers', { clear = true }),
    callback = function()
        local parsers = require('nvim-treesitter.parsers')

        for lang, dir in pairs(vendored) do
            local parser = parsers[lang]
            if parser and parser.install_info then
                -- keep location/generate/revision info, but build from the local checkout
                parser.install_info.path = plugins_path .. "/" .. dir
            end
        end

        -- tmux is no longer shipped by nvim-treesitter (upstream stopped committing
        -- the generated parser), so generate it from the vendored grammar and use
        -- the queries that ship with it
        parsers.tmux = {
            install_info = {
                path = plugins_path .. "/tree-sitter-tmux",
                generate = true,
                generate_from_json = false,
                queries = "queries",
            },
            tier = 2,
        }
    end,
})

local ensure_installed = {
    'c', 'cpp', 'lua', 'python', 'cmake', 'csv', 'dockerfile', 'doxygen',
    'elixir', 'elm', 'erlang',
    'git_config', 'git_rebase', 'gitattributes', 'gitcommit', 'gitignore',
    'go', 'json', 'proto', 'rust', 'tmux', 'toml', 'xml', 'yaml',
}

-- Only kick off an install when something is actually missing so startup
-- stays quiet once everything has been built
local installed = ts.get_installed()
local missing = vim.tbl_filter(function(lang)
    return not vim.list_contains(installed, lang)
end, ensure_installed)
if #missing > 0 then
    ts.install(missing)
end

-- Highlighting is provided by Neovim; start it for every buffer that has a
-- parser, installing parsers nvim-treesitter knows about on demand (the
-- equivalent of the old `auto_install = true` + `highlight.enable = true`)
local available ---@type table<string, boolean>?
local function is_available(lang)
    if not available then
        available = {}
        for _, l in ipairs(ts.get_available()) do
            available[l] = true
        end
    end
    return available[lang] == true
end

local function start(bufnr, lang)
    if vim.api.nvim_buf_is_valid(bufnr) then
        pcall(vim.treesitter.start, bufnr, lang)
    end
end

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('user-ts-start', { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match) or args.match

        if vim.treesitter.language.add(lang) then
            start(args.buf, lang)
        elseif is_available(lang) then
            ts.install(lang):await(function(err)
                if not err then
                    vim.schedule(function() start(args.buf, lang) end)
                end
            end)
        end
    end,
})
