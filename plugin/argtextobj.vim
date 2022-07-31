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


xnoremap <silent> ia <Plug>(argtextobj_x_ia)
xnoremap <silent> aa <Plug>(argtextobj_x_aa)
xnoremap iA <Plug>(argtextobj_x_iA)
xnoremap aA <Plug>(argtextobj_x_aA)

onoremap <silent> ia <Plug>(argtextobj_o_ia)
onoremap <silent> aa <Plug>(argtextobj_o_aa)
onoremap iA <Plug>(argtextobj_o_iA)
onoremap aA <Plug>(argtextobj_o_aA)

