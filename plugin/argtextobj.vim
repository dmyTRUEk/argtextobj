" check vim version and some other magick:
if exists('loaded_argument_text_object') || &cp || version < 700
  finish
endif
let loaded_argument_text_object = 1

" bind plugin's functions to better(?) names:
xnoremap <Plug>(argtextobj2_x_aa)  :<C-U>call argtextobj#VisualSelectAroundArg()<CR>
nnoremap <Plug>(argtextobj2_n_daa) :<C-U>call argtextobj#DeleteAroundArg()<CR>
nnoremap <Plug>(argtextobj2_n_caa) :<C-U>call argtextobj#ChangeAroundArg()<CR>
nnoremap <Plug>(argtextobj2_n_yaa) :<C-U>call argtextobj#YieldAroundArg()<CR>
xnoremap <Plug>(argtextobj2_x_ia)  :<C-U>call argtextobj#VisualSelectInArg()<CR>
nnoremap <Plug>(argtextobj2_n_dia) :<C-U>call argtextobj#DeleteInArg()<CR>
nnoremap <Plug>(argtextobj2_n_cia) :<C-U>call argtextobj#ChangeInArg()<CR>
nnoremap <Plug>(argtextobj2_n_yia) :<C-U>call argtextobj#YieldInArg()<CR>

" keybinds:
xnoremap  aa <Plug>(argtextobj2_x_aa)
nnoremap daa <Plug>(argtextobj2_n_daa)
nnoremap caa <Plug>(argtextobj2_n_caa)
nnoremap yaa <Plug>(argtextobj2_n_yaa)
xnoremap  ia <Plug>(argtextobj2_x_ia)
nnoremap dia <Plug>(argtextobj2_n_dia)
nnoremap cia <Plug>(argtextobj2_n_cia)
nnoremap yia <Plug>(argtextobj2_n_yia)

