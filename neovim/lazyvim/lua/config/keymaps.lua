-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- <F6>: build the current file (with debug symbols) for C/C++ and Go.
-- Output binary is written next to the source with the extension stripped,
-- which is also what <F5> (debugger) defaults to launching.
local function build_current()
  vim.cmd("silent! write")
  local file = vim.fn.expand("%:p")
  local out = vim.fn.expand("%:p:r")
  local inc = vim.fn.expand("~/.config/clangd/include") -- for <bits/stdc++.h>
  local ft = vim.bo.filetype
  local cmd
  if ft == "cpp" then
    -- Apple's clang (not Homebrew LLVM) so the debug map links correctly for lldb/codelldb.
    cmd = { "/usr/bin/clang++", "-g", "-O0", "-std=gnu++17", "-I", inc, "-o", out, file }
  elseif ft == "c" then
    cmd = { "/usr/bin/clang", "-g", "-O0", "-std=gnu11", "-o", out, file }
  elseif ft == "go" then
    cmd = { "go", "build", "-gcflags=all=-N -l", "-o", out, file } -- -N -l: debuggable
  else
    vim.notify("Build: unsupported filetype '" .. ft .. "'", vim.log.levels.WARN, { title = "Build" })
    return
  end
  vim.notify("Building " .. vim.fn.expand("%:t") .. " …", vim.log.levels.INFO, { title = "Build" })
  vim.system(cmd, { text = true }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.notify("OK → " .. out, vim.log.levels.INFO, { title = "Build" })
      else
        local msg = (res.stderr ~= "" and res.stderr) or res.stdout or "build failed"
        vim.notify(msg, vim.log.levels.ERROR, { title = "Build failed" })
      end
    end)
  end)
end

vim.keymap.set("n", "<F6>", build_current, { desc = "Build current file" })

-- Compile (and optionally run) the current file in a floating popup terminal.
--   <leader>oo  build only        <leader>oO  build & run (type stdin here)
-- Uses the same Apple clang toolchain as the debug build so binaries are also
-- lldb/codelldb-debuggable (GNU g++ output doesn't debug cleanly on macOS).
-- -I adds the custom <bits/stdc++.h> include dir. Compile errors show in the popup.
local function build_run(do_run)
  vim.cmd("silent! write")
  local file = vim.fn.shellescape(vim.fn.expand("%:p"))
  local out = vim.fn.shellescape(vim.fn.expand("%:p:r"))
  local inc = vim.fn.shellescape(vim.fn.expand("~/.config/clangd/include"))
  local ft = vim.bo.filetype
  local build, run
  if ft == "cpp" then
    build = string.format("/usr/bin/clang++ -O2 -std=gnu++17 -I %s -o %s %s", inc, out, file)
    run = out
  elseif ft == "c" then
    build = string.format("/usr/bin/clang -O2 -std=gnu11 -o %s %s", out, file)
    run = out
  elseif ft == "go" then
    build = string.format("%s build -o %s %s", vim.fn.exepath("go"), out, file)
    run = out
  else
    vim.notify("Build: unsupported filetype '" .. ft .. "'", vim.log.levels.WARN, { title = "Build" })
    return
  end
  -- On success: run the binary, or just confirm the build.
  local script = build .. " && " .. (do_run and run or "echo '✓ build ok'")
  -- Table form ({shell, -c, script}) so `&&` is shell-interpreted; /bin/sh keeps it clean.
  Snacks.terminal.open({ "/bin/sh", "-c", script }, {
    interactive = true,
    auto_close = false, -- keep output/errors visible after the process exits
    win = {
      position = "float",
      border = "rounded",
      title = do_run and " build & run " or " build ",
      title_pos = "center",
      height = 0.85,
      width = 0.85,
    },
  })
end

vim.keymap.set("n", "<leader>oo", function() build_run(false) end, { desc = "Build (popup)" })
vim.keymap.set("n", "<leader>oO", function() build_run(true) end, { desc = "Build & run (popup)" })
