local lspconfig = require('lspconfig')
local coq = require('coq')


local lsp_flags = {
}

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end


lspconfig.sumneko_lua.setup(coq.lsp_ensure_capabilities({
  on_attach = on_attach,
  flags = lsp_flags,
  settings = {
    Lua = {
      diagnostics = {
	globals = {"vim"},
      },
    },
  },
}))

lspconfig.terraformls.setup(coq.lsp_ensure_capabilities({
  on_attach = on_attach,
  flags = lsp_flags,
}))

lspconfig.yamlls.setup(coq.lsp_ensure_capabilities({
  settings = {
    yaml = {
      schemas = {
	-- ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = "*template.yml"
	-- ["https://s3.amazonaws.com/cfn-resource-specifications-us-east-1-prod/schemas/2.15.0/all-spec.json"] = "*.yml"
	-- ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = "*.yml"
      },
      customTags = {
	"!Cidr",
	"!Cidr sequence",
	"!And",
	"!And sequence",
	"!If",
	"!If sequence",
	"!Not",
	"!Not sequence",
	"!Equals",
	"!Equals sequence",
	"!Or",
	"!Or sequence",
	"!FindInMap",
	"!FindInMap sequence",
	"!Base64",
	"!Join",
	"!Join sequence",
	"!Ref",
	"!Sub",
	"!Sub sequence",
	"!GetAtt",
	"!GetAZs",
	"!ImportValue",
	"!ImportValue sequence",
	"!Select",
	"!Select sequence",
	"!Split",
	"!Split sequence",
      },
    },
  },
}))

vim.cmd('COQnow')
