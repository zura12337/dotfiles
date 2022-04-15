local vim = vim
local nvim_lsp = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
local null_ls = require("null-ls")
local configs = require("lspconfig.configs")

require("nice-reference").setup({})

local on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local opts = { noremap = true, silent = true }
	local ts_utils = require("nvim-lsp-ts-utils")
	ts_utils.setup({})

	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover({ float = { border = 'rounded', max_width = 120 }})<CR>", opts)
	buf_set_keymap(
		"n",
		"]d",
		'<cmd>lua vim.diagnostic.goto_next({ float = { border = "rounded", max_width = 120  }})<CR>',
		opts
	)
	buf_set_keymap(
		"n",
		"[d",
		'<cmd>lua vim.diagnostic.goto_prev({ float = { border = "rounded", max_width = 120  }})<CR>',
		opts
	)
	buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	buf_set_keymap("n", "gs", ":TSLspOrganize<CR>", opts)
	buf_set_keymap("n", "gi", ":TSLspImportAll<CR>", opts)

	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
      augroup lsp_document_highlight
      autocmd! * <buffer>
      autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end

	vim.cmd("sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=")
	vim.cmd("sign define DiagnosticSignWarn text=⚠ texthl=DiagnosticSignWarn linehl= numhl=")
	vim.cmd("sign define DiagnosticSignInfo text=🛈 texthl=DiagnosticSignInfo linehl= numhl=")
	vim.cmd("sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=")
end

capabilities.textDocument.completion.completionItem.snippetSupport = true

if not configs.emmet_ls then
	configs.emmet_ls = {
		default_config = {
			cmd = { "ls_emmet", "--stdio" },
			filetypes = {
				"html",
				"css",
				"scss",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"haml",
				"xml",
				"xsl",
				"pug",
				"slim",
				"sass",
				"stylus",
				"less",
				"sss",
				"hbs",
				"handlebars",
			},
			root_dir = function(fname)
				return vim.loop.cwd()
			end,
			settings = {},
		},
	}
end

local function clip_text(diagnostic)
	if #diagnostic.message < 70 then
		return diagnostic.message
	else
		return string.sub(diagnostic.message, 1, 70) .. "... ]d for more info."
	end
end

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	underline = true,
	virtual_text = {
		spacing = 1,
		prefix = "■",
		format = clip_text,
	},
	update_in_insert = true,
})

require("nvim-treesitter.configs").setup({
	highlight = {
		enable = false,
	},
	indent = {
		true,
	},
	autotag = {
		enable = true,
	},
	ensure_installed = {
		"javascript",
		"tsx",
		"php",
		"json",
		"yaml",
		"html",
		"css",
	},
})

local servers = {
	cssls = {},
	tsserver = {
		on_attach = on_attach,
		capabilities = capabilities,
	},
	jsonls = {
		filetypes = { "json", "jsonc" },
		settings = {
			json = {
				schemas = {
					{
						fileMatch = { "package.json" },
						url = "https://json.schemastore.org/package.json",
					},
					{
						fileMatch = { "tsconfig*.json" },
						url = "https://json.schemastore.org/tsconfig.json",
					},
					{
						fileMatch = {
							".prettierrc",
							".prettierrc.json",
							"prettier.config.json",
						},
						url = "https://json.schemastore.org/prettierrc.json",
					},
					{
						fileMatch = { ".eslintrc", ".eslintrc.json" },
						url = "https://json.schemastore.org/eslintrc.json",
					},
					{
						fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
						url = "https://json.schemastore.org/babelrc.json",
					},
					{
						fileMatch = { "lerna.json" },
						url = "https://json.schemastore.org/lerna.json",
					},
					{
						fileMatch = { "now.json", "vercel.json" },
						url = "https://json.schemastore.org/now.json",
					},
					{
						fileMatch = {
							".stylelintrc",
							".stylelintrc.json",
							"stylelint.config.json",
						},
						url = "http://json.schemastore.org/stylelintrc.json",
					},
				},
			},
		},
	},
	yamlls = {
		on_attach = on_attach,
		capabilities = capabilities,
	},
	diagnosticls = {
		filetypes = {
			"javascript",
			"javascriptreact",
			"json",
			"typescript",
			"typescriptreact",
			"css",
			"less",
			"scss",
			"markdown",
		},
		init_options = {
			filetypes = {
				javascript = "eslint_d",
				javascriptreact = "eslint_d",
				typescript = "eslint_d",
				typescriptreact = "eslint_d",
			},
		},
	},
	html = {
		on_attach = on_attach,
		capabilities = capabilities,
	},
	sumneko_lua = {
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	},
	vimls = {
		on_attach = on_attach,
		capabilities = capabilities,
	},
	emmet_ls = {
		capabilities = capabilities,
	},
}

for server, config in pairs(servers) do
	local server_disabled = (config.disabled ~= nil and config.disabled) or false

	if not server_disabled then
		nvim_lsp[server].setup(vim.tbl_deep_extend("force", {
			on_attach = on_attach,
			capabilities = capabilities,
			flags = {
				debounce_text_change = 1000,
			},
		}, config))
	end
end

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.prettierd,
		null_ls.builtins.formatting.stylua,
	},
	on_attach = function(client)
		if client.resolved_capabilities.document_formatting then
			vim.cmd("nnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.formatting()<CR>")
			-- format on save
			vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()")
		end
		if client.resolved_capabilities.document_range_formatting then
			vim.cmd("xnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.range_formatting({})<CR>")
			vim.cmd("")
		end
	end,
})
