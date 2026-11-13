-- Extend the "lervag/vimtex" spec from LazyVim's lang.tex extra.
-- VimTeX reads its g: options when it loads, so set them in `init`.
return {
  {
    "lervag/vimtex",
    init = function()
      -- Compiler: latexmk, with LuaLaTeX as the default engine
      vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }

      -- Viewer: Okular with SyncTeX forward search
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "okular"
      vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"

      -- Open the quickfix window for errors only, not warnings
      vim.g.vimtex_quickfix_open_on_warning = 0
    end,
  },
}
