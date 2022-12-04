local C = dofile('CParser.lua')

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

for _, file in ipairs(FILES) do
  local path = BASE_DIR .. '/src/nvim/api/' .. file
  print(file)
  local fns = C.parse(path)
  for _, fn in pairs(fns) do
    print(fn.name)
    print('  return = ' .. fn.ret)
    print('  args = [' .. table.concat(fn.args, ', ') .. ']')
    print('  attrs = [' .. table.concat(fn.attrs, ', ') .. ']')
    for _, line in ipairs(fn.desc) do
      print('    ' .. line)
    end
    print('\n')
  end
end
