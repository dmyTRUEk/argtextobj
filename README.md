# This repo is depraceted
Use [dmyTRUEk/argument-text-object](https://github.com/dmyTRUEk/argument-text-object) instead.

# Argument Text Object
Arguments is also text-objects now!

This plugin provides a text-object `a`(argument).
- `via`, `vaa` - select in/an arg
- `dia`, `daa` - delete in/an arg
- `cia`, `caa` - change in/an arg
- `yia`, `yaa` - yank (copy) in/an arg
- `]a`, `[a` - jump to next/prev arg

What this plugin does is more than simply typing `F,dt,`,
because it recognizes the inclusion relationship of parentheses.


## Examples
Here `|` denotes cursor position.

1. Delete in argument: `foo(ba|r, baz)`, press `dia` => `foo(|, baz)`
2. Delete an argument: `foo(ba|r, baz)`, press `daa` => `foo(|baz)`
3. Change in argument: `foo(ba|r, baz)`, press `cia`, input `abc`, press `<esc>` => `foo(abc|, baz)`
4. Select in argument: `foo(ba|r, baz)`, press `via` => `foo(|bar|, baz)`
5. Jump to next argument: `foo(ba|r, baz)`, press `]a` => `foo(bar, |baz)`


## Ideas
- shift args (`<a` - move current arg to left, `>a` - move current arg to right)


## Alternatives
- [PeterRincker/vim-argumentative](https://github.com/PeterRincker/vim-argumentative) - argument text object, move cursor between args, shift args to left/right
- [hgiesel/vim-motion-sickness](https://github.com/hgiesel/vim-motion-sickness#field-text-objects) - contains motions for arguments in specified brackets
- [AndrewRadev/sideways.vim](https://github.com/AndrewRadev/sideways.vim) - shift arg to left/right
- [machakann/vim-swap](https://github.com/machakann/vim-swap) - shift arg to left/right, arg swap mode (ala sub-mode)
- [mizlan/iswap.nvim](https://github.com/mizlan/iswap.nvim) - interactive swap args mode
- [vim-scripts/swap-parameters](https://github.com/vim-scripts/swap-parameters) - swap args


## History
This is an improved fork of [xeruf/argtextobj.vim](https://github.com/xeruf/argtextobj.vim),  
which is improved fork of [inkarkat/argtextobj.vim](https://github.com/inkarkat/argtextobj.vim),  
which is improved fork of [vim-scripts/argtextobj.vim](https://github.com/vim-scripts/argtextobj.vim),  
which is code from [vim.org script_id=2699](https://www.vim.org/scripts/script.php?script_id=2699).

