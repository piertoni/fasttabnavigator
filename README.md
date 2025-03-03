# FastTabNavigator

FastTabNavigator is a Neovim plugin that enhances window navigation by remapping `<C-h>` and `<C-l>` to seamlessly switch between windows and tabs.

## Features
- Move left (`<C-h>`) or right (`<C-l>`) between Neovim windows.
- If you are in the **leftmost** window and press `<C-h>`, it switches to the **previous tab**.
- If you are in the **rightmost** window and press `<C-l>`, it switches to the **next tab**.

## Installation
### Using LazyVim
To integrate FastTabNavigator with LazyVim, add the following configuration:

```lua
  {
    "piertoni/fasttabnavigator",
    config = function(_, opts)
      require('fasttabnavigator')
    end,
    keys = {
      {"<C-h>", desc = "Go to Left Window or Previous Tab"},
      {"<C-l>", desc = "Go to Right Window or Next Tab"}
    },
  },
```

## Usage
Simply use the standard Neovim window navigation shortcuts:
- `<C-h>`: Move to the left window, or if in the first window, go to the previous tab.
- `<C-l>`: Move to the right window, or if in the last window, go to the next tab.

## License
This project is licensed under the MIT License.

