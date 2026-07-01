-- Enable LazyVim extras via tracked imports (lazyvim.json is gitignored, so
-- extras toggled through :LazyExtras wouldn't propagate through git).
--   dap.core     debugger (nvim-dap, dap-ui, mason-nvim-dap)
--   lang.clangd  C/C++ LSP + codelldb debug configs
--   lang.go      gopls + nvim-dap-go + delve
return {
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.go" },
}
