# Argument Text Object
Arguments is also text-objects now!

This plugin provides a text-object `a`(argument).
You can `d`(delete), `c`(change), `v`(visual select) an argument or inner argument in familiar ways,
such as `daa`(delete-an-argument) `cia`(change-inner-argument) `via`(select-inner-argument).  
What this plugin does is more than simply typing `F,dt,`
because it recognizes the inclusion relationship of parentheses.

This is an improved fork of [xeruf/argtextobj.vim](https://github.com/xeruf/argtextobj.vim),
which is improved fork of [inkarkat/argtextobj.vim](https://github.com/inkarkat/argtextobj.vim),
which is improved fork of [vim-scripts/argtextobj.vim](https://github.com/vim-scripts/argtextobj.vim),
which is code from [vim.org script_id=2699](https://www.vim.org/scripts/script.php?script_id=2699)

## Examples
```
  case1) delete An argument
      function(int arg1,    ch<press 'daa' here>ar* arg2="a,b,c(d,e)")
      function(int arg1<cursor here; and if you press 'daa' again..>)
      function(<cursor>)

  case2) change Inner argument
      function(int arg1,    ch<press 'cia' here>ar* arg2="a,b,c(d,e)")
      function(int arg1,    <cursor here>)
      
  case 3) smart argument recognition (g:argumentobject_force_toplevel = 0)
       function(1, (20<press 'cia' here>*30)+40, somefunc2(3, 4))
       function(1, <cursor here>, somefunc2(3, 4))
       
       function(1, (20*30)+40, somefunc2(<press 'cia' here>3, 4))
       function(1, (20*30)+40, somefunc2(<cursor here>4))

  case 4) smart argument recognition (g:argumentobject_force_toplevel = 1)
       function(1, (20<press 'cia' here>*30)+40, somefunc2(3, 4))
       function(1, <cursor here>, somefunc2(3, 4)) " note that this result is the same of above.
       
       function(1, (20*30)+40, somefunc2(<press 'cia' here>3, 4))
       function(1, (20*30)+40, <cursor here>) " sub-level function is deleted because it is a argument in terms of the outer function.
```
