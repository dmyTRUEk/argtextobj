" main code

function! s:CurChar()
    return getline('.')[getpos('.')[2] - 1]
endfunction


function! s:GetOuterFunctionParenthesis(toplevel)
    let pos_save = getpos('.')
    let rightup_before = pos_save

    let split = split(&matchpairs, ':')[:-2]
    let [opening; split] = split
    for sp in split
        let opening = opening.split(sp, ',')[1]
    endfor

    let pos_char = <SID>CurChar()
    if pos_char =~ '[' . opening . ']'
        normal! l
        return pos_save
    endif

    normal [%
    let rightup_p = getpos('.')
    if rightup_p == rightup_before
        return []
    endif
    while rightup_p != rightup_before
        if ! a:toplevel
            " found a function
            break
        endif
        let rightup_before = rightup_p
        normal [%
        let rightup_p = getpos('.')
    endwhile

    call setpos('.', pos_save)
    return rightup_p
endfunction


function! s:GetPair(pos)
    let pos_save = getpos('.')
    call setpos('.', a:pos)
    normal! %
    if a:pos == getpos('.')
        call setpos('.', pos_save)
        return []
    endif
    normal! h
    let pair_pos = getpos('.')
    call setpos('.', pos_save)
    return pair_pos
endfunction


function! s:GetInnerText(r1, r2)
    let pos_save = getpos('.')
    let cb_save = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    let reg_save = @@
    let regtype_save = getregtype('"')
    call setpos('.', a:r1)
    normal! lv
    call setpos('.', a:r2)
    if &selection ==# 'exclusive'
        normal! l
    endif
    silent normal! y
    let val = @@
    call setpos('.', pos_save)
    call setreg('"', reg_save, regtype_save)
    let &clipboard = cb_save
    return val
endfunction


function! s:GetPrevCommaOrBeginArgs(arglist, offset)
    let commapos = strridx(a:arglist, ',', a:offset)
    return max([commapos+1, 0])
endfunction


function! s:GetNextCommaOrEndArgs(arglist, offset, count)
    let commapos = a:offset - 1
    let c = a:count
    while c > 0
        let commapos = stridx(a:arglist, ',', commapos + 1)
        if commapos == -1
            if c > 1
                execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
            endif
            return strlen(a:arglist) - 1
        endif
        let c -= 1
    endwhile
    return commapos - 1
endfunction


function! s:MoveToNextNonSpace()
    let oldp = getpos('.')
    let moved = 0
    while <SID>CurChar() =~ '\s'
        normal! l
        if oldp == getpos('.')
            break
        endif
        let oldp = getpos('.')
        let moved += 1
    endwhile
    return moved
endfunction


function! s:MoveLeft(num)
    if a:num > 0
        exe 'normal! ' . a:num . 'h'
    endif
endfunction


function! s:MoveRight(num)
    if a:num > 0
        exe 'normal! ' . a:num . 'l'
    endif
endfunction


function! argtextobj#MotionArgument(inner, visual, toplevel)
    let cnt = v:count1
    let operator = v:operator
    let pos_save = getpos('.')
    let current_c = <SID>CurChar()
    if current_c == ','
        normal! l
    endif

    let rightup = <SID>GetOuterFunctionParenthesis(a:toplevel)  " on (
    if empty(rightup)
        " no left bracket found, not inside function arguments
        call setpos('.', pos_save)
        return
    endif
    let rightup_pair = <SID>GetPair(rightup)    " before )
    if empty(rightup_pair)
        " no matching right parenthesis found, search for incomplete function
        " definition until end of current line.
        let rightup_pair = [0, line('.'), col('$'), 0]
        " empty function argument
    elseif rightup_pair == rightup
        " select both parenthesis
        if !a:inner
            normal! vh
        elseif !a:visual
            if current_c == '('
                " insert single space and visually select it
                silent! execute "normal! i \<Esc>v"
            endif
        endif
        return s:Repeat(cnt, a:inner, a:visual, operator)
    endif
    let arglist_str = <SID>GetInnerText(rightup, rightup_pair) " inside ()
    if line('.') == rightup[1]
        " left parenthesis in the current line
        " cursor offset from rightup
        let offset = getpos('.')[2] - rightup[2] - 1   " -1 for the removed parenthesis
    else
        " left parenthesis in a previous line; retrieve the (partial when there's a
        " matching right parenthesis) current line from the arglist_str.
        for line in split(arglist_str, "\n")
            if stridx(getline('.'), line) == 0
                let arglist_str = line
                break
            endif
        endfor
        let offset = getpos('.')[2] - 1
    endif
    " replace all parentheses and commas inside them to '_'
    let arglist_sub = arglist_str
    let arglist_sub = substitute(arglist_sub, "'".'\([^'."'".']\{-}\)'."'", '\="(".substitute(submatch(1), ".", "_", "g").")"', 'g') " replace '..' => (__)
    let arglist_sub = substitute(arglist_sub, '\[\([^'."'".']\{-}\)\]', '\="(".substitute(submatch(1), ".", "_", "g").")"', 'g')     " replace [..] => (__)
    let arglist_sub = substitute(arglist_sub, '<\([^'."'".']\{-}\)>', '\="(".substitute(submatch(1), ".", "_", "g").")"', 'g')       " replace <..> => (__)
    let arglist_sub = substitute(arglist_sub, '"\([^'."'".']\{-}\)"', '(\1)', 'g') " replace ''..'' => (..)
    while stridx(arglist_sub, '(') >= 0 && stridx(arglist_sub, ')') >= 0
        let arglist_sub = substitute(arglist_sub , '(\([^()]\{-}\))', '\="<".substitute(submatch(1), ",", "_", "g").">"', 'g')
    endwhile
    " the beginning/end of this argument
    let thisargbegin = <SID>GetPrevCommaOrBeginArgs(arglist_sub, offset)
    let thisargend   = <SID>GetNextCommaOrEndArgs(arglist_sub, offset, cnt)

    " function(..., the_nth_arg, ...)
    "             [^left]    [^right]
    let left  = offset - thisargbegin
    let right = thisargend - thisargbegin

    let delete_trailing_space = 0
    " only do inner matching when argument list is not empty
    if a:inner && arglist_sub !~# "^\s\+$"
        " ia
        call <SID>MoveLeft(left)
        let right -= <SID>MoveToNextNonSpace()
    else
        " aa
        if thisargbegin == 0 && thisargend == strlen(arglist_sub) - 1
            " only single argument
            call <SID>MoveLeft(left)
        elseif thisargbegin == 0
            " head of the list (do not delete '(')
            call <SID>MoveLeft(left)
            let right += 1
            let delete_trailing_space = 1
        else
            " normal or tail of the list
            call <SID>MoveLeft(left + 1)
            let right += 1
        endif
    endif

    exe 'normal! v'

    call <SID>MoveRight(right)
    if delete_trailing_space
        exe 'normal! l'
        call <SID>MoveToNextNonSpace()
        exe 'normal! h'
    endif

    if &selection ==# 'exclusive'
        normal! l
    endif

    call s:Repeat(cnt, a:inner, a:visual, operator)
endfunction


function! s:Repeat(cnt, inner, visual, operator)
    let l:mapping = (a:inner ? "\<Plug>(argtextobjI)" : "\<Plug>(argtextobjA)")
    if !a:visual
        silent! call ingo#motion#omap#repeat(l:mapping, a:operator, a:cnt)
    endif
endfunction



" MY CODE GOES AFTER THIS:



function! s:GetCurrentLineAndCol()
    let l:pos = getcurpos() " current cursor position info
    let l:line = l:pos[1]
    let l:col  = l:pos[2]
    " echom "line = " . l:line . "   col = " . l:col
    return [l:line, l:col]
endfunction

function! s:GetChar(linecol)
    let l:line = a:linecol[0]
    let l:col  = a:linecol[1]
    return getline(l:line)[l:col - 1]
endfunction


function! s:IsItemInList(item_to_search, list_)
    for item in a:list_
        if item == a:item_to_search
            return v:true
        endif
    endfor
    return v:false
endfunction

function! s:IsWhitespace(char)
    return s:IsItemInList(a:char, [" ", "\t"])
endfunction

function! s:IsBracketLeft(char)
    return s:IsItemInList(a:char, ["(", "[", "<"])
endfunction

function! s:IsBracketRight(char)
    return s:IsItemInList(a:char, [")", "]", ">"])
endfunction

function! s:IsBracket(char)
    return s:IsBracketLeft(a:char) || s:IsBracketRight(a:char)
endfunction


function! s:ConvertBracketToLeft(char)
    if a:char ==# ")"
        return "("
    elseif a:char ==# "]"
        return "["
    elseif a:char ==# ">"
        return "<"
    else
        return char
    endif
endfunction


function! s:CurPosNext(linecol)
    let [line_, col_] = a:linecol
    let col_ += 1
    if col_ > len(getline(line_))
        let line_ += 1
        if line_ > line('$')
            " echom "REACHED END OF FILE, EXITING"
            return []
        endif
        let col_ = 0
    endif
    return [line_, col_]
endfunction

function! s:CurPosPrev(linecol)
    let [line_, col_] = a:linecol
    let col_ -= 1
    if col_ < 1
        let line_ -= 1
        if line_ < 1
            " echom "REACHED START OF FILE, EXITING"
            return []
        endif
        let col_ = len(getline(line_))
    endif
    return [line_, col_]
endfunction


function! s:FindFirstCorrectBracketOrCommaOnLeft(linecol_initial_cursor_pos)
    " TODO: make global for configurationability
    let search_limit_max = 1000 " if checked more than this symbols, stop
    " init vars for loop:
    let linecol = a:linecol_initial_cursor_pos
    let search_limit = search_limit_max
    let level_bracket    = 0 " level for ( and )
    let level_bracket_sq = 0 " level for [ and ]
    let level_bracket_tr = 0 " level for < and >
    while (level_bracket != 0) || (level_bracket_sq != 0) || (level_bracket_tr != 0) || ( (s:GetChar(linecol) !=# ",") && (s:GetChar(linecol) !=# "(") && (s:GetChar(linecol) !=# "[") && (s:GetChar(linecol) !=# "<"))
        let l:current_char = s:GetChar(linecol)
        " echom "l="line_.", c="col_.", char=".l:current_char.", level_bracket=".level_bracket.", level_bracket_sq=".level_bracket_sq

        " change level
        if l:current_char ==# "("
            let level_bracket += 1
        elseif l:current_char ==# ")"
            let level_bracket -= 1
        elseif l:current_char ==# "["
            let level_bracket_sq += 1
        elseif l:current_char ==# "]"
            let level_bracket_sq -= 1
        elseif l:current_char ==# "<"
            let level_bracket_tr += 1
        elseif l:current_char ==# ">"
            let level_bracket_tr -= 1
        endif

        let linecol = s:CurPosPrev(linecol)
        if empty(linecol)
            " if reached beginning of the file
            return []
        endif

        let search_limit -= 1
        if search_limit < 0
            " echom "REACHED SEARCH LIMIT for left bracket, EXITING"
            return []
        endif
    endwhile

    " echom "level_bracket=".level_bracket.", level_bracket_sq=".level_bracket_sq
    if level_bracket == 0 && level_bracket_sq == 0
        " echom "OK"
    else
        " echom "NOT OK!!!!"
        return []
    endif

    " echom "got: line=".line_.", col=".col_.", char there = ".s:GetChar([line_, col_])

    return linecol
endfunction


function! s:FindFirstCorrectBracketOrCommaOnRight(linecol_initial_cursor_pos)
    " TODO: make global for configurationability
    let search_limit_max = 1000 " if checked more than this symbols, stop
    " init vars for loop:
    let linecol = a:linecol_initial_cursor_pos
    let search_limit = search_limit_max
    let level_bracket    = 0 " level for ( and )
    let level_bracket_sq = 0 " level for [ and ]
    let level_bracket_tr = 0 " level for < and >
    while (level_bracket != 0) || (level_bracket_sq != 0) || (level_bracket_tr != 0) || ( (s:GetChar(linecol) !=# ",") && (s:GetChar(linecol) !=# ")") && (s:GetChar(linecol) !=# "]") && (s:GetChar(linecol) !=# ">"))
        let l:current_char = s:GetChar(linecol)
        " echom "l="line_.", c="col_.", char=".l:current_char.", level_bracket=".level_bracket.", level_bracket_sq=".level_bracket_sq

        " change level
        if l:current_char ==# "("
            let level_bracket += 1
        elseif l:current_char ==# ")"
            let level_bracket -= 1
        elseif l:current_char ==# "["
            let level_bracket_sq += 1
        elseif l:current_char ==# "]"
            let level_bracket_sq -= 1
        elseif l:current_char ==# "<"
            let level_bracket_tr += 1
        elseif l:current_char ==# ">"
            let level_bracket_tr -= 1
        endif

        let linecol = s:CurPosNext(linecol)
        if empty(linecol)
            " if reached end of the file
            return []
        endif

        let search_limit -= 1
        if search_limit < 0
            " echom "REACHED SEARCH LIMIT for right bracket, EXITING"
            return []
        endif
    endwhile

    " echom "level_bracket=".level_bracket.", level_bracket_sq=".level_bracket_sq
    if level_bracket == 0 && level_bracket_sq == 0
        " echom "OK"
    else
        " echom "NOT OK!!!!"
        return []
    endif

    " echom "got: line=".line_.", col=".col_.", char there = ".s:GetChar([line_, col_])

    return linecol
endfunction


function! s:GetBoundsForAroundArg()
    let l:pos = getcurpos() " current cursor position
    " echom "pos = " . string(l:pos)

    " TODO: make global for configurationability
    let search_limit_max = 1000 " if checked more than this symbols, stop

    " current cursor position
    let l:linecol = s:GetCurrentLineAndCol()
    let l:char = s:GetChar(l:linecol)
    if s:IsBracket(l:char) || (l:char == ",")
        echom "this char is bracket or comma"
        return [[], []]
    endif

    " find left and right bounds (it could be brackets or comma)
    let linecol_left  = s:FindFirstCorrectBracketOrCommaOnLeft(l:linecol)
    let linecol_right = s:FindFirstCorrectBracketOrCommaOnRight(l:linecol)
    if empty(linecol_left) || empty(linecol_right)
        echom "not inside brackets"
        return [[], []]
    endif
    let l:ch_left  = s:GetChar(linecol_left)
    let l:ch_right = s:GetChar(linecol_right)

    " left and right bounds corrections depending on the surrounding characters
    if (l:ch_left ==# ",") && (l:ch_right ==# ",")
        " , arg ,
        let linecol_left = s:CurPosNext(linecol_left)
        " TODO: maybe this `if` is redundant?
        if s:IsWhitespace(s:GetChar(s:CurPosNext(linecol_right)))
            let linecol_right = s:CurPosNext(linecol_right)
            while s:IsWhitespace(s:GetChar(linecol_right))
                let linecol_right = s:CurPosNext(linecol_right)
            endwhile
            let linecol_right = s:CurPosPrev(linecol_right)
        endif
        if ((linecol_left[1] != 0) || (linecol_right[1] != len(getline(linecol_right[0])))) && s:IsWhitespace(s:GetChar(linecol_left))
            while s:IsWhitespace(s:GetChar(linecol_left))
                let linecol_left = s:CurPosNext(linecol_left)
            endwhile
        endif

    elseif (l:ch_left ==# ",") && (l:ch_right !=# ",")
        " , arg )
        let linecol_right = s:CurPosPrev(linecol_right)
        while s:IsWhitespace(s:GetChar(linecol_right))
            let linecol_right = s:CurPosPrev(linecol_right)
        endwhile
        " TODO: maybe this `if` is redundant?
        if s:IsWhitespace(s:GetChar(s:CurPosPrev(linecol_left)))
            let linecol_left = s:CurPosPrev(linecol_left)
            while s:IsWhitespace(s:GetChar(linecol_left))
                let linecol_left = s:CurPosPrev(linecol_left)
            endwhile
            let linecol_left = s:CurPosNext(linecol_left)
        endif

    elseif (l:ch_left !=# ",") && (l:ch_right ==# ",")
        " ( arg ,
        let linecol_left = s:CurPosNext(linecol_left)
        while s:IsWhitespace(s:GetChar(linecol_left))
            let linecol_left = s:CurPosNext(linecol_left)
        endwhile
        " TODO: maybe this `if` is redundant?
        if s:IsWhitespace(s:GetChar(s:CurPosNext(linecol_right)))
            let linecol_right = s:CurPosNext(linecol_right)
            while s:IsWhitespace(s:GetChar(linecol_right))
                let linecol_right = s:CurPosNext(linecol_right)
            endwhile
            let linecol_right = s:CurPosPrev(linecol_right)
        endif

    elseif (l:ch_left !=# ",") && (l:ch_right !=# ",") && (l:ch_left ==# s:ConvertBracketToLeft(l:ch_right))
        " ( arg )
        let linecol_left  = s:CurPosNext(linecol_left)
        let linecol_right = s:CurPosPrev(linecol_right)

    elseif (l:ch_left !=# ",") && (l:ch_right !=# ",") && (l:ch_left !=# s:ConvertBracketToLeft(l:ch_right))
        " [ arg )
        echom "LEFT and RIGHT brackets DOESNT MATCH, which means that bracket sequence is incorrect, so no arg can be selected"
        return [[], []]
    endif

    " if arg is alone on the line, then also grab "\n" at the end
    if (l:ch_right ==# ",") && (linecol_left[1] == 0) && (linecol_right[1] == len(getline(linecol_right[0])))
        let linecol_right = [linecol_right[0], linecol_right[1]+1]

    elseif (l:ch_right ==# ",") && (linecol_left[1] == 0) && (linecol_right[1] != len(getline(linecol_right[0])))
        let linecol_left = s:CurPosNext(linecol_left)
        while s:IsWhitespace(s:GetChar(linecol_left))
            let linecol_left = s:CurPosNext(linecol_left)
        endwhile

    elseif (l:ch_right ==# ",") && (linecol_left[1] != 0) && (linecol_right[1] == len(getline(linecol_right[0])))
        let linecol_left = s:CurPosPrev(linecol_left)
        while s:IsWhitespace(s:GetChar(linecol_left))
            let linecol_left = s:CurPosPrev(linecol_left)
        endwhile
        let linecol_left = s:CurPosNext(linecol_left)
    endif

    " set cursor pos
    let l:pos_left  = [l:pos[0], linecol_left[0] , linecol_left[1] , l:pos[3]]
    let l:pos_right = [l:pos[0], linecol_right[0], linecol_right[1], l:pos[3]]

    return [l:pos_left, l:pos_right]
endfunction


function! argtextobj#VisualSelectAroundArg()
    let [l:pos_left, l:pos_right] = s:GetBoundsForAroundArg()
    if (l:pos_left == []) || (l:pos_right == [])
        return
    endif
    call setpos(".", l:pos_left)
    exe 'normal! v'
    call setpos(".", l:pos_right)
endfunction

function! argtextobj#DeleteAroundArg()
    call argtextobj#VisualSelectAroundArg()
    exe 'normal! d'
endfunction

function! argtextobj#ChangeAroundArg()
    call argtextobj#VisualSelectAroundArg()
    " TODO: dont press `c` if nothing was selected
    call feedkeys('c')
endfunction

function! argtextobj#YieldAroundArg()
    call argtextobj#VisualSelectAroundArg()
    " TODO: dont press `y` if nothing was selected
    exe 'normal! y'
endfunction


