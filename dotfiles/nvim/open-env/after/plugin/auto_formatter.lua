local format_on_save = require("format-on-save")
local formatters = require("format-on-save.formatters")

format_on_save.setup({
    exclude_path_patterns = {
        ".local/save/nvim/lazy",
    },
    formatter_by_ft = {
        c = formatters.lsp,
        cpp = formatters.lsp,
        lua = formatters.lsp,
        python = formatters.lsp,
    },
    experiments = {
        partial_update = 'diff',
    }
})
