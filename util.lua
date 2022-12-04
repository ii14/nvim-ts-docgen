local util = {}

function util.dedent(lines)
  local indent = math.huge
  for _, line in ipairs(lines) do
    local col = line:find('[^ ]') -- TODO: handle hard tabs?
    if col and col < indent then
      indent = col
    end
  end
  if indent < math.huge then
    for i, line in ipairs(lines) do
      lines[i] = line:sub(indent)
    end
  end
  return lines
end

function util.mk_lookup(t)
  local r = {}
  for _, v in ipairs(t) do
    r[v] = true
  end
  return r
end

return util
