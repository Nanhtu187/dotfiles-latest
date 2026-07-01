-- Go debugging fix.
-- The mason-installed delve (>= 1.25) refuses to launch against Go < 1.25:
--   "Go version go1.24.2 is too old for this version of Delve"
-- This machine pins Go 1.24.2 (gvm), so pass --check-go-version=false to the
-- `dlv dap` server (nvim-dap-go appends delve.args to its launch command).
return {
  "leoluz/nvim-dap-go",
  optional = true,
  opts = {
    delve = {
      args = { "--check-go-version=false" },
    },
  },
}
