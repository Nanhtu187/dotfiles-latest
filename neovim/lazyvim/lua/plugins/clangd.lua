-- Fix clangd startup error with clangd >= 22.
--
-- LazyVim's lang.clangd extra passes a bare `--function-arg-placeholders` flag.
-- clangd 22+ requires a boolean value for it and errors out on launch:
--   "Value specified by --function-arg-placeholders is invalid. Provide a boolean value..."
--
-- This runs as an opts *function*, so it patches the cmd AFTER the extra's opts
-- table is merged in, regardless of spec load order.
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local clangd = opts.servers and opts.servers.clangd
    if clangd and clangd.cmd then
      for i, arg in ipairs(clangd.cmd) do
        if arg == "--function-arg-placeholders" then
          clangd.cmd[i] = "--function-arg-placeholders=true"
        end
      end
    end
  end,
}
