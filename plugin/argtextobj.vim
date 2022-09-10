" check vim version and some other magick:
if exists('loaded_argument_text_object') || &cp || version < 700
  finish
endif
let loaded_argument_text_object = 1

" visual mode maps:
xnoremap <Plug>(argtextobj_x_aa) :<C-U>call argtextobj#MotionArgument(0, 1, 0)<CR>
xnoremap <Plug>(argtextobj_x_ia) :<C-U>call argtextobj#MotionArgument(1, 1, 0)<CR>
xnoremap <Plug>(argtextobj_x_aA) :<C-U>call argtextobj#MotionArgument(0, 1, 1)<CR>
xnoremap <Plug>(argtextobj_x_iA) :<C-U>call argtextobj#MotionArgument(1, 1, 1)<CR>

" operator pending mode (after "d", "y", "c") maps:
onoremap <Plug>(argtextobj_o_aa) :<C-U>call argtextobj#MotionArgument(0, 0, 0)<CR>
onoremap <Plug>(argtextobj_o_ia) :<C-U>call argtextobj#MotionArgument(1, 0, 0)<CR>
onoremap <Plug>(argtextobj_o_aA) :<C-U>call argtextobj#MotionArgument(0, 0, 1)<CR>
onoremap <Plug>(argtextobj_o_iA) :<C-U>call argtextobj#MotionArgument(1, 0, 1)<CR>

" new implementation:
xnoremap <Plug>(argtextobj2_x_aa)  :<C-U>call argtextobj#VisualSelectAroundArg()<CR>
nnoremap <Plug>(argtextobj2_n_daa) :<C-U>call argtextobj#DeleteAroundArg()<CR>
nnoremap <Plug>(argtextobj2_n_caa) :<C-U>call argtextobj#ChangeAroundArg()<CR>
nnoremap <Plug>(argtextobj2_n_yaa) :<C-U>call argtextobj#YieldAroundArg()<CR>
"xnoremap <Plug>(argtextobj2_x_ia)  :<C-U>call argtextobj#VisualSelectInArg()<CR>
"nnoremap <Plug>(argtextobj2_n_dia) :<C-U>call argtextobj#DeleteInArg()<CR>
"nnoremap <Plug>(argtextobj2_n_cia) :<C-U>call argtextobj#ChangeInArg()<CR>
"nnoremap <Plug>(argtextobj2_n_yia) :<C-U>call argtextobj#YieldInArg()<CR>

" tmp maps to key binds:
"xnoremap ia <Plug>(argtextobj_x_ia)
"xnoremap aa <Plug>(argtextobj_x_aa)
"xnoremap iA <Plug>(argtextobj_x_iA)
"xnoremap aA <Plug>(argtextobj_x_aA)

"onoremap ia <Plug>(argtextobj_o_ia)
"onoremap aa <Plug>(argtextobj_o_aa)
"onoremap iA <Plug>(argtextobj_o_iA)
"onoremap aA <Plug>(argtextobj_o_aA)

xnoremap  aa <Plug>(argtextobj2_x_aa)
nnoremap daa <Plug>(argtextobj2_x_daa)
nnoremap caa <Plug>(argtextobj2_x_caa)
nnoremap yaa <Plug>(argtextobj2_x_yaa)
"xnoremap  ia <Plug>(argtextobj2_x_ia)
"nnoremap dia <Plug>(argtextobj2_x_dia)
"nnoremap cia <Plug>(argtextobj2_x_cia)
"nnoremap yia <Plug>(argtextobj2_x_yia)

