local navbuddy = require("nvim-navbuddy")

navbuddy.setup({
    lsp = {
        -- attach to every LSP client that supports document symbols
        auto_attach = true,
    },
})
