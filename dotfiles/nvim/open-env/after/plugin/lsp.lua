-- LSP setup using Neovim's native vim.lsp.config / vim.lsp.enable API.
-- nvim-lspconfig only provides the default server configs (its lsp/*.lua files);
-- everything below extends those defaults.

-- Capabilities shared by every server (adds nvim-cmp completion support)
vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Setup mappings for LSP commands whenever a server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local builtin = require('telescope.builtin')

        local nmap = function(keys, func, desc)
            if desc then
                desc = 'LSP: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>lrn', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('<leader>lca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('<leader>lgd', builtin.lsp_definitions, '[G]oto [D]efinition')
        nmap('<leader>lgr', builtin.lsp_references, '[G]oto [R]eferences')
        nmap('<leader>lgu', builtin.lsp_references, '[G]oto [U]sages')
        nmap('<leader>lgI', builtin.lsp_implementations, '[G]oto [I]mplementation')
        nmap('<leader>lD', builtin.lsp_type_definitions, 'Type [D]efinition')
        nmap('<leader>lds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>lws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- See `:help H` for why this keymap
        nmap('<leader>lh', vim.lsp.buf.hover, 'Hover Documentation')
        nmap('<leader>lH', vim.lsp.buf.signature_help, 'Signature Documentation')

        -- Lesser used LSP functionality
        nmap('<leader>lgD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        nmap('<leader>lwa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nmap('<leader>lwr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        --  nmap('<leader>wl', function()
        --    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        --  end, '[W]orkspace [L]ist Folders')

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
            vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })

        -- navbuddy attaches itself (see after/plugin/navbuddy.lua); just map it
        nmap("<leader>nb", require("nvim-navbuddy").open, 'Open [N]av[B]uddy')

        -- lsp_signature attaches itself through its own LspAttach autocmd
        -- (see after/plugin/signatures.lua)
    end,
})

-- Lua LS (lazydev.nvim adds the Neovim runtime/plugin library on demand)
local luals_state = vim.fn.stdpath("state") .. "/lua-language-server"
vim.lsp.config('lua_ls', {
    cmd = {
        "lua-language-server",
        "--logpath=" .. luals_state .. "/log",
        "--metapath=" .. luals_state .. "/meta",
    },
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

-- Clangd
vim.lsp.config('clangd', {
    cmd = {
        "clangd",
        "--query-driver=/usr/bin/g++",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
    },
    filetypes = {
        "c", "cpp",
    },
})

-- Python LSP Server
vim.lsp.config('pylsp', {
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    ignore = { 'E501' },
                }
            }
        }
    }
})

-- Docker lsp
vim.lsp.config('dockerls', {
    settings = {
        docker = {
            languageserver = {
                formatter = {
                    ignoreMultilineInstructions = true,
                },
            },
        }
    }
})

-- Elixir lsp (installed by the Dockerfile, not on $PATH)
vim.lsp.config('elixirls', {
    cmd = { '/opt/lsps/elixir-ls/language_server.sh' },
})

vim.lsp.enable({
    'lua_ls',
    'clangd',
    'pylsp',
    'neocmake',                        -- CMake
    'dockerls',                        -- Dockerfiles
    'docker_compose_language_service', -- Compose files
    'elixirls',
    'elmls',
    -- 'gitlab_ci_ls',
    'gopls',
    'yamlls',
    'helm_ls',
    'bashls',
    -- 'protols',
})

-- setup for auto completion
local cmp = require('cmp')
local luasnip = require('luasnip')
luasnip.config.setup({})

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
--    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'lazydev', group_index = 0 }, -- require() / annotation completion in Neovim lua files
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
})
