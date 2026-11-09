local path = vim.fn.stdpath("data") .. "/plugins/lazy.nvim"

vim.opt.rtp:prepend(path)

local plugins = {
    -- Telescope
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function()
                    return vim.fn.executable('make') == 1
                end,
            },
        },
    },

    -- Tree-sitter (the `main` branch rewrite; it does not support lazy-loading)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ':TSUpdate',
    },

    -- Color Scheming
    "rktjmp/lush.nvim",
    {
        "m241dan/ksd_theme",
        config = function()
            vim.cmd.colorscheme("ksd_theme")
        end,
    },

    -- LSP
    "neovim/nvim-lspconfig", -- server configs consumed by vim.lsp.config / vim.lsp.enable
    { "j-hui/fidget.nvim", opts = {} }, -- A progress bar for what the LSP is doing
    {
        "folke/lazydev.nvim", -- lua_ls support for the Neovim API when working on vim specific things
        ft = "lua",
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- Auto complete and snippet support
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
    },

    -- Git plugins
    "lewis6991/gitsigns.nvim",

    -- CMake Tools
    "Civitasv/cmake-tools.nvim",

    -- Nav Buddy
    "MunifTanjim/nui.nvim",
    "SmiteshP/nvim-navic",
    "SmiteshP/nvim-navbuddy",

    -- Lsp Signatures (highlights things like which parameter you are on in a function call as you write it)
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
    },

    -- Notifications, Messages, and Commands
    --    {
    --        "folke/noice.nvim",
    --        event = "VeryLazy",
    --        opts = {},
    --        dependencies = {
    --            "MunifTanjim/nui.nvim",
    --            "rcarriga/nvim-notify",
    --        },
    --    }

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
        },
    },
    {
        "m4xshen/hardtime.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        opts = {},
    },
    {
        "tris203/precognition.nvim",
        event = "VeryLazy",
        opts = {
            startVisible = false,
            hints = {
                Caret = { text = "H", prio = 2 },
                Dollar = { text = "L", prio = 1 },
            }
        },
    },
    -- Auto detect indent size
    {
        "nmac427/guess-indent.nvim",
        config = function() require('guess-indent').setup({}) end,
    },
    -- Auto indent with tab
    {
        'vidocqh/auto-indent.nvim',
        config = function()
            require("auto-indent").setup({
                lightmode = true,
                indentexpr = nil,
                ignore_filetype = {},
            })
        end,
    },
    -- Auto formatter
    "elentok/format-on-save.nvim",
    -- CSV Viewer
    {
        'vidocqh/data-viewer.nvim',
        opts = {},
        dependencies = {
            "nvim-lua/plenary.nvim",
        }
    },
    -- Code folding
    {
        "OXY2DEV/foldtext.nvim",
        lazy = false,
    }
}

local options = {
    root = vim.fn.stdpath("data") .. "/plugins",
}

require("lazy").setup(plugins, options)
