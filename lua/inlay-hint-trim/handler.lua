local M = {}

-- Default configuration
M.config = {
  max_length = 30,
  ellipsis = "…",
  clients = {
    ["typescript-tools"] = true,
    ["tsserver"] = true,
    ["ts_ls"] = true,
  },
}

-- Store the original handler
local original_handler = nil

-- Truncate a string to a maximum length
local function truncate(str, max_len)
  if #str <= max_len then
    return str
  end
  return str:sub(1, max_len - #M.config.ellipsis) .. M.config.ellipsis
end

-- Normalize label (string | InlayHintLabelPart[])
local function normalize_label(label)
  if type(label) == "string" then
    return truncate(label, M.config.max_length)
  end

  -- Handle labelParts: { { value = "...", tooltip = ... }, ... }
  if type(label) == "table" then
    local buf = {}
    local total = 0

    for _, part in ipairs(label) do
      if type(part.value) ~= "string" then
        goto continue
      end

      local remain = M.config.max_length - total
      if remain <= 0 then
        break
      end

      local value = part.value
      if #value > remain then
        value = truncate(value, remain)
        table.insert(buf, {
          value = value,
          tooltip = part.tooltip,
        })
        break
      end

      total = total + #value
      table.insert(buf, part)

      ::continue::
    end

    -- Add ellipsis if truncated
    if total >= M.config.max_length then
      table.insert(buf, { value = M.config.ellipsis })
    end

    return buf
  end

  return label
end

-- Custom handler for textDocument/inlayHint
local function custom_handler(err, result, ctx, config)
  if err or type(result) ~= "table" then
    return original_handler(err, result, ctx, config)
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client or not M.config.clients[client.name] then
    return original_handler(err, result, ctx, config)
  end

  -- Map to table to avoid iterator compatibility issues
  local new_result = vim.tbl_map(function(hint)
    if hint.label ~= nil then
      hint.label = normalize_label(hint.label)
    end
    return hint
  end, result)

  return original_handler(err, new_result, ctx, config)
end

-- Setup the handler
function M.setup(opts)
  -- Merge user config with defaults
  if opts then
    if opts.max_length then
      M.config.max_length = opts.max_length
    end
    if opts.ellipsis then
      M.config.ellipsis = opts.ellipsis
    end
    if opts.clients then
      M.config.clients = opts.clients
    end
  end

  -- Get the LSP methods
  local methods = vim.lsp.protocol.Methods
  if not methods or not methods.textDocument_inlayHint then
    vim.notify("inlay-hint-trim: LSP methods not available", vim.log.levels.WARN)
    return
  end

  -- Store original handler
  original_handler = vim.lsp.handlers[methods.textDocument_inlayHint]

  -- Override handler
  vim.lsp.handlers[methods.textDocument_inlayHint] = custom_handler
end

-- Disable the plugin (restore original handler)
function M.disable()
  if original_handler then
    local methods = vim.lsp.protocol.Methods
    vim.lsp.handlers[methods.textDocument_inlayHint] = original_handler
  end
end

return M
