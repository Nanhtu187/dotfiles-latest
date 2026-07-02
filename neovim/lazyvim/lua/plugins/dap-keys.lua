-- Short debugger keys, layered on top of LazyVim's dap.core extra.
-- VS Code-style function keys:
--   <F5> / <leader>od   start / continue        <S-F5>    stop / terminate
--   <F9>   toggle breakpoint                    <C-S-F5>  restart
--   <F10>  step over    <F11> step into         <S-F11>   step out
--   <leader>dW          add variable under cursor to watch
-- (F6 stays "build"; pause is <leader>dP; <leader>dw keeps LazyVim's Widgets.)

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

-- Start (or resume) the debugger. For C/C++ it first (re)builds a `-g -O0`
-- debug binary, since <leader>oo/oO build optimized binaries without -g.
local function start_debug()
  local dap = require("dap")
  -- If a session is already running, this just resumes execution.
  if dap.session() then
    dap.continue()
    return
  end
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
  if ft == "c" or ft == "cpp" then
    vim.cmd("silent! write")
    local file = vim.fn.expand("%:p")
    local out = vim.fn.expand("%:p:r")
    local inc = vim.fn.expand("~/.config/clangd/include")
    local cmd = ft == "cpp"
        and { "/usr/bin/clang++", "-g", "-O0", "-std=gnu++17", "-I", inc, "-o", out, file }
      or { "/usr/bin/clang", "-g", "-O0", "-std=gnu11", "-o", out, file }
    -- launch exactly the binary we're about to build (no path prompt)
    for _, cfg in ipairs(dap.configurations[ft] or {}) do
      if cfg.request == "launch" then
        cfg.program = out
      end
    end
    vim.notify("Building debug binary …", vim.log.levels.INFO, { title = "Debug" })
    vim.system(cmd, { text = true }, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify((res.stderr ~= "" and res.stderr) or "compile failed", vim.log.levels.ERROR, {
            title = "Debug build failed",
          })
          return
        end
        dap.continue()
      end)
    end)
    return
  end
  -- Go (delve builds its own `-N -l` debug binary) and others: just start.
  dap.continue()
end

return {
  "mfussenegger/nvim-dap",
  optional = true,
  keys = {
    { "<F5>", start_debug, desc = "Debug: Start/Continue" },
    { "<leader>od", start_debug, desc = "Debug: Start/Continue" },
    -- VS Code-style debug function keys
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: Stop" },
    { "<C-S-F5>", function() require("dap").restart() end, desc = "Debug: Restart" },
    -- Run to cursor (VS Code "Run to Cursor"); <leader>dC also does this.
    { "<C-F10>", function() require("dap").run_to_cursor() end, desc = "Debug: Run to Cursor" },
    {
      "<leader>dW",
      function()
        require("dapui").elements.watches.add(vim.fn.expand("<cexpr>"))
      end,
      desc = "Debug: Add variable to watch",
    },
  },
}
