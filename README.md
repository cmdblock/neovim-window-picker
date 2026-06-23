# neovim-window-picker

A lightweight Neovim plugin for fast window navigation using letter hints.

> **Note:** This plugin is written entirely in Lua and does not support Vim/Neovim < 0.5.

## Features

- Display single-letter hints on each window
- Jump to any window by pressing its hint letter
- Customizable labels, appearance, and window filter
- Minimal dependencies (Neovim 0.11+)
- Pure Lua implementation

## Demo

```
┌─────────────┬─────────────┐
│      a      │      s      │
│             │             │
├─────────────┼─────────────┤
│      d      │      f      │
│             │             │
└─────────────┴─────────────┘
```

Press `<leader>w` then `s` to jump to the top-right window.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "cmdblock/neovim-window-picker",
  config = function()
    require("window-picker").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "cmdblock/neovim-window-picker",
  config = function()
    require("window-picker").setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'your-username/neovim-window-picker'
```

## Configuration

```lua
require("window-picker").setup({
  -- Letters used for window hints (default: asdfghjkl;qwertyuiopzxcvbnm)
  labels = "asdfghjkl;qwertyuiopzxcvbnm",

  -- Floating window appearance
  float = {
    border = "rounded",        -- "single", "double", "rounded", "solid", "shadow"
    style = "minimal",
    highlight = "WindowPickerFloat",
  },

  -- Filter which windows to include (default: include all windows)
  filter = function(win)
    return true
  end,
})
```

## Usage

### Default Mapping

| Key         | Action                     |
| ----------- | -------------------------- |
| `<leader>w` | Show window hints and pick |

### Custom Mapping

```lua
vim.keymap.set("n", "<C-w>p", function()
  require("window-picker").pick()
end, { desc = "Pick window" })
```

## API

### `setup(opts)`

Initialize the plugin with optional configuration.

### `pick()`

Show window hints and wait for user input to jump.

## Highlight

Define or override the float window highlight group:

```lua
vim.api.nvim_set_hl(0, "WindowPickerFloat", { fg = "#ffffff", bg = "#ff0000" })
```

## Requirements

- Neovim >= 0.11

## License

MIT
