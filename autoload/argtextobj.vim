" main plugin's code:

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
        " yes, this can be considered as a bug, but other code alredy relies on it, so ...
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





function! s:GetBoundsForInArg()
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

    let linecol_left  = s:CurPosNext(linecol_left)
    let linecol_right = s:CurPosPrev(linecol_right)

    if linecol_left[1] == 0
        let linecol_left[1] = 1
    endif

    " TODO
    while s:IsWhitespace(s:GetChar(linecol_left))
        let linecol_left = s:CurPosNext(linecol_left)
    endwhile

    while s:IsWhitespace(s:GetChar(linecol_right))
        let linecol_right = s:CurPosPrev(linecol_right)
    endwhile

    " set cursor pos
    let l:pos_left  = [l:pos[0], linecol_left[0] , linecol_left[1] , l:pos[3]]
    let l:pos_right = [l:pos[0], linecol_right[0], linecol_right[1], l:pos[3]]

    return [l:pos_left, l:pos_right]
endfunction


function! argtextobj#VisualSelectInArg()
    let [l:pos_left, l:pos_right] = s:GetBoundsForInArg()
    if (l:pos_left == []) || (l:pos_right == [])
        return
    endif
    call setpos(".", l:pos_left)
    exe 'normal! v'
    call setpos(".", l:pos_right)
endfunction

function! argtextobj#DeleteInArg()
    call argtextobj#VisualSelectInArg()
    exe 'normal! d'
endfunction

function! argtextobj#ChangeInArg()
    call argtextobj#VisualSelectInArg()
    " TODO: dont press `c` if nothing was selected
    call feedkeys('c')
endfunction

function! argtextobj#YieldInArg()
    call argtextobj#VisualSelectInArg()
    " TODO: dont press `y` if nothing was selected
    exe 'normal! y'
endfunction


