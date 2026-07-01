-- Short debugger keys, layered on top of LazyVim's dap.core extra.
--   <F5>        start / continue the debugger
--   <leader>dw  add the variable under the cursor to the watch window
-- (LazyVim already provides <leader>db breakpoint, <leader>du UI, stepping, etc.)

-- Project root of the current buffer, so the debuggee runs there and resolves
-- relative file paths (e.g. competitive-programming .inp/.out files) against it.
-- Prefer the git repo root; then other project markers; then LazyVim's root; then cwd.
local function project_root()
  local root = vim.fs.root(0, ".git")
    or vim.fs.root(0, { "go.mod", ".clangd", "compile_commands.json", "Makefile", "package.json" })
  if root then
    return root
  end
  if _G.LazyVim and LazyVim.root then
    local ok, r = pcall(LazyVim.root)
    if ok and r and r ~= "" then
      return r
    end
  end
  return vim.fn.getcwd()
end

return {
  "mfussenegger/nvim-dap",
  optional = true,
  keys = {
    {
      "<F5>",
      function()
        local dap = require("dap")
        local ft = vim.bo.filetype
        local root = project_root()
        -- Run the debuggee from the project root so it can read files there.
        for _, lang in ipairs({ "c", "cpp", "go" }) do
          for _, cfg in ipairs(dap.configurations[lang] or {}) do
            if cfg.request == "launch" then
              cfg.cwd = root
            end
          end
        end
        -- For C/C++, default the launch target to the binary built by <F6>
        -- (same path as the source with the extension stripped) instead of cwd.
        if ft == "c" or ft == "cpp" then
          for _, cfg in ipairs(dap.configurations[ft] or {}) do
            if cfg.request == "launch" and not cfg._prog_defaulted then
              cfg._prog_defaulted = true
              cfg.program = function()
                return vim.fn.input("Path to executable: ", vim.fn.expand("%:p:r"), "file")
              end
            end
          end
        end
        dap.continue()
      end,
      desc = "Debug: Start/Continue",
    },
    {
      "<leader>dw",
      function()
        require("dapui").elements.watches.add(vim.fn.expand("<cexpr>"))
      end,
      desc = "Debug: Add variable to watch",
    },
  },
}
