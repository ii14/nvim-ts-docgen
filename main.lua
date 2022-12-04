local C = require('CParser')
local Doxygen = require('DoxygenParser')

local BASE_DIR = assert(vim.env.NVIM_SRC, 'set $NVIM_SRC to the neovim source code directory')

local FILES = {
  'autocmd.c',
  'buffer.c',
  'command.c',
  'deprecated.c',
  'extmark.c',
  'options.c',
  'tabpage.c',
  'ui.c',
  'vim.c',
  'vimscript.c',
  'win_config.c',
  'window.c',
}

local lines = {}
local function append(line)
  table.insert(lines, line)
end

for _, file in ipairs(FILES) do
  local path = BASE_DIR .. '/src/nvim/api/' .. file
  append(file)
  local fns = C.parse(path)
  for _, fn in pairs(fns) do
    append(fn.name)
    append('  return = ' .. fn.ret)
    append('  args = [' .. table.concat(fn.args, ', ') .. ']')
    append('  attrs = [' .. table.concat(fn.attrs, ', ') .. ']')
    for _, line in ipairs(Doxygen.parse(fn.desc)) do
      append('    ' .. line)
    end
    append('')
  end
end

local file = assert(io.open('out.txt', 'w'))
file:write(table.concat(lines, '\n'))
file:flush()
file:close()
