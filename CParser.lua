local TS = vim.treesitter
local util = require('util')

TS.set_query('c', 'injections', '') -- https://github.com/neovim/neovim/issues/21275

local Parser = { __index = {} }

function Parser.new(path)
  local text = (function()
    local file = assert(io.open(path, 'rb'))
    local text = file:read('*a')
    file:close()
    return text
  end)()

  local tree = TS.get_string_parser(text, 'c'):parse()[1]:root()

  local parser = setmetatable({
    file = path,
    text = text,
    tree = tree,
    result = {},
    _comments = nil,
    _comment_line = nil,
  }, Parser)

  return parser
end

--- Get node string
function Parser.__index:to_str(node)
  local _, _, s = node:start()
  local _, _, e = node:end_()
  return self.text:sub(s + 1, e)
end

function Parser.__index:parse_arg(node)
  return self:to_str(node)
end

function Parser.__index:parse_attr(node)
  return self:to_str(node)
end

function Parser.__index:parse_function(node)
  assert(node:type() == 'function_definition', 'invalid node type')

  local return_type = node:field('type')[1]
  if not return_type then return end

  local declarator = node:field('declarator')[1]
  if not declarator then return end

  local name = declarator:field('declarator')[1]
  if not name then return end
  name = self:to_str(name)
  if not name:match('^nvim_') then
    return
  end

  local params = declarator:field('parameters')[1]
  if not params then return end
  local args = {}
  for child in params:iter_children() do
    if child:type() == 'parameter_declaration' then
      table.insert(args, self:parse_arg(child))
    end
  end

  local attrs = {}
  for child in declarator:iter_children() do
    if child:type() == 'nvim_attribute_specifier' then
      table.insert(attrs, self:parse_attr(child))
    end
  end

  local desc = {}
  if self._comments ~= nil and node:start() == self._comment_line + 1 then
    desc, self._comments = util.dedent(self._comments), nil
  end

  self.result[name] = {
    name = name,
    args = args,
    ret = self:to_str(return_type),
    attrs = attrs,
    desc = desc,
  }
end

function Parser.__index:parse_comment(node)
  assert(node:type() == 'comment', 'invalid node type')

  local comment = self:to_str(node):match('^///(.-)%s*$')
  if not comment then return false end

  local prev_line = self._comment_line
  self._comment_line = node:start()

  if self._comments == nil or self._comment_line ~= prev_line + 1 then
    self._comments = { comment }
  else
    table.insert(self._comments, comment)
  end
end

function Parser.__index:parse()
  local function reset_comment()
    self._comments, self._comment_line = nil, nil
  end

  for node in self.tree:iter_children() do
    if node:type() == 'comment' then
      if self:parse_comment(node) == false then
        reset_comment()
      end
    elseif node:type() == 'function_definition' then
      self:parse_function(node)
      reset_comment()
    else
      reset_comment()
    end
  end

  return self.result
end

return {
  parse = function(file)
    return Parser.new(file):parse()
  end,
}
