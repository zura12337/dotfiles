local cmp = require "cmp"

vim.o.completeopt = "menuone,noselect"

cmp.setup {
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		}),

    ["<c-space>"] = cmp.mapping {
      i = cmp.mapping.complete(),
      c = function(
        _ --[[fallback]]
      )
        if cmp.visible() then
          if not cmp.confirm { select = true } then
            return
          end
        else
          cmp.complete()
        end
      end,
    }
  },

		['<Tab>'] = cmp.mapping(function(fallback)
			if vim.fn.pumvisible() == 1 then
				vim.fn.feedkeys(t('<C-n>'), 'n')
			elseif vim.fn['vsnip#available']() == 1 then
				vim.fn.feedkeys(t('<Plug>(vsnip-expand-or-jump)'), '')
			elseif check_back_space() then
				vim.fn.feedkeys(t('<Tab>'), 'n')
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if vim.fn.pumvisible() == 1 then
				vim.fn.feedkeys(t('<C-p>'), 'n')
			elseif vim.fn['vsnip#jumpable'](-1) == 1 then
				vim.fn.feedkeys(t('<Plug>(vsnip-jump-prev)'), '')
			elseif check_back_space() then
				vim.fn.feedkeys(t('<C-h>'), 'n')
			else
				fallback()
			end
		end, { 'i', 's' }),

  sources = {
    { name = "nvim_lsp" },
    { name = "path" },
    { name = 'ultisnips' },
    { name = "buffer" },
  },

  snippet = {
    expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end
  },

  experimental = {
    native_menu = false,

    ghost_text = true,
  },
}

cmp.setup.cmdline("/", {
  completion = {
    -- Might allow this later, but I don't like it right now really.
    -- Although, perhaps if it just triggers w/ @ then we could.
    --
    -- I will have to come back to this.
    autocomplete = false,
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp_document_symbol" },
  }, {
    -- { name = "buffer", keyword_length = 5 },
  }),
})

cmp.setup.cmdline(":", {
  completion = {
    autocomplete = false,
  },

  sources = cmp.config.sources({
    {
      name = "path",
    },
  }, {
    {
      name = "cmdline",
      max_item_count = 20,
      keyword_length = 4,
    },
  }),
})

--[[
" Setup buffer configuration (nvim-lua source only enables in Lua filetype).
"
" ON YOUTUBE I SAID: This only _adds_ sources for a filetype, not removes the global ones.
"
" BUT I WAS WRONG! This will override the global setup. Sorry for any confusion.
autocmd FileType lua lua require'cmp'.setup.buffer {
\   sources = {
\     { name = 'nvim_lua' },
\     { name = 'buffer' },
\   },
\ }
--]]

