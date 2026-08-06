-- Restore render-markdown.nvim's upstream look, which LazyVim's markdown extra
-- tones down (it sets `heading.icons = {}`, disables signs and checkboxes).
-- `opts` is deep-merged, so only these keys override the extra's defaults.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        sign = true,
        width = "full",
      },
      checkbox = {
        enabled = true,
      },
    },
  },
}
