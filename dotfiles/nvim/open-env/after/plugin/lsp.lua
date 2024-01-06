-- Setup neovim lua configuration


-- get the capabilities of our client lsp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Function to setup mappings for LSP commands when attached
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>lrn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>lca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('<leader>lgd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('<leader>lgr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('<leader>lgI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>lD', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>lds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

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
end

local lspconfig = require("lspconfig")

-- Setup Lua LS
require('neodev').setup() -- This adds support for the vim API to the lua_ls
lspconfig.lua_ls.setup({
    -- Neovim Specific Params
    on_attach = on_attach,

    -- LSP Specific Params
    Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
    },
})

-- Setup Clangd
lspconfig.clangd.setup({
    -- Neovim specific Params
    on_attach = on_attach,
    cmd = {
        "clangd",
        "--query-driver='/usr/bin/g++'",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
    },
    filetypes = {
        "c", "cpp",
    },
})

-- Setup Python LSP Server
lspconfig.pylsp.setup({})

local cmp = require('cmp')
local luasnip = require('luasnip')
luasnip.config.setup({})

-- Setup CMake LSP Server
lspconfig.neocmake.setup({
    -- Neovim specific params
    on_attach = on_attach,
})

-- setup for auto completion
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
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
})

