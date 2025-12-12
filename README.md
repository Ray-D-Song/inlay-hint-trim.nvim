# inlay-hint-trim.nvim

A Neovim plugin that truncates overly long inlay hints for LSP clients, making your code more readable.

## Features

- Automatically truncates inlay hint labels that exceed a configurable maximum length
- Configurable target LSP clients (defaults to TypeScript-related clients)
- Preserves tooltip information
- Easy to enable/disable

## Requirements

- Neovim >= 0.10.0 (for LSP inlay hints support)
- An LSP client that provides inlay hints

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ray-d-song/inlay-hint-trim.nvim",
  config = function()
    require("inlay-hint-trim").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "ray-d-song/inlay-hint-trim.nvim",
  config = function()
    require("inlay-hint-trim").setup()
  end,
}
```

## Configuration

### Default configuration

```lua
require("inlay-hint-trim").setup({
  max_length = 30,      -- Maximum length of inlay hint labels
  ellipsis = "…",       -- Character to use for truncation
  clients = {           -- LSP clients to apply truncation to
    ["typescript-tools"] = true,
    ["tsserver"] = true,
    ["ts_ls"] = true,
  },
})
```

### Custom configuration examples

#### Shorter hints for all TypeScript clients

```lua
require("inlay-hint-trim").setup({
  max_length = 20,
  ellipsis = "...",
})
```

#### Add support for more LSP clients

```lua
require("inlay-hint-trim").setup({
  clients = {
    ["typescript-tools"] = true,
    ["tsserver"] = true,
    ["ts_ls"] = true,
    ["rust_analyzer"] = true,  -- Add Rust support
    ["gopls"] = true,           -- Add Go support
  },
})
```

#### Only apply to specific clients

```lua
require("inlay-hint-trim").setup({
  clients = {
    ["ts_ls"] = true,  -- Only for ts_ls
  },
})
```

## Usage

Once installed and configured, the plugin will automatically truncate inlay hints from the specified LSP clients. No additional commands are needed.

### Disabling the plugin

If you want to temporarily disable the plugin:

```lua
require("inlay-hint-trim").disable()
```

To re-enable:

```lua
require("inlay-hint-trim").setup()
```

## How it works

The plugin intercepts the `textDocument/inlayHint` LSP handler and processes the results before displaying them. It:

1. Checks if the response is from a target LSP client
2. Truncates label strings that exceed the maximum length
3. For structured labels (arrays of label parts), it intelligently truncates while preserving the structure
4. Passes the processed hints to the original handler

## Why this plugin?

Inlay hints are a great feature for understanding code, but they can sometimes be overly verbose, especially in TypeScript projects. This plugin helps maintain readability by keeping hints concise while preserving the most important information.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See LICENSE file for details

## Credits

Created by [@ray-d-song](https://github.com/ray-d-song)
