local function mk_lookup(t)
  local r = {}
  for _, v in ipairs(t) do
    r[v] = true
  end
  return r
end

local COMMANDS = mk_lookup {
  'deprecated',
  'note',
  'param',
  'param[in,out]',
  'param[in]',
  'param[out]',
  'return',
  'returns',
  'see',
}

local function split_paragraphs(lines)
  local ps = {}
  local p = nil
  local block = nil

  local function end_paragraph()
    if p ~= nil then
      table.insert(ps, p)
      p = nil
    end
  end

  local function append(line)
    if p == nil then
      p = { line }
    else
      table.insert(p, line)
    end
  end

  for _, line in ipairs(lines) do
    if block then
      append(line)
      if line:match('^%s*</pre>') then
        block = nil
      end
    elseif not line:match('%S') then
      end_paragraph()
    elseif line:match('^%s*<pre>') then
      append(line)
      block = true
    elseif line:match('^%s*@') then
      local cmd, rest = line:match('^%s*@(%S+)%s*(.*)')
      if cmd then
        assert(COMMANDS[cmd], 'unknown doxygen command: ' .. tostring(cmd))
        end_paragraph()
        append(rest)
        p.type = 'command'
        p.cmd = cmd
      else
        append(line)
      end
    else
      append(line)
    end
  end
  end_paragraph()
  return ps
end

return {
  parse = function(lines)
    local res = split_paragraphs(lines)
    for _, p in ipairs(res) do
      print('    [' .. (p.cmd or 'paragraph') .. ']')
      for _, line in ipairs(p) do
        print('      ' .. line)
      end
    end
  end,
}
