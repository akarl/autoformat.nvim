let s:config = {}

" config lets you configure a list of formatters for a filetype.
function! autoformat#config(ft, formatters)
	let s:config[a:ft] = a:formatters
endfunction

" format_buffer will format the provided buffer. If the bufnr is 0, the
" current buffer is used.
function! autoformat#format_buffer(bufnr)
	if !has_key(s:config, &filetype)
		" We don't have any config for this filetype.
		return
	endif

	let l:bufnr = a:bufnr
	if l:bufnr ==# 0
		let l:bufnr = bufnr()
	endif

	let l:formatters = s:config[&filetype]

	" Get all lines in the buffer.
	let l:lines = nvim_buf_get_lines(l:bufnr, 0, line('$'), 0)
	if len(l:lines) ==# 0
		" The buffer it empty. Do nothing!
		return
	endif

	" Remember the length so that we can offset the cursor later.
	let l:pre_len = len(l:lines)

	" Run each formatter after the other.
	for formatter in l:formatters
		let l:lines = s:format_lines(l:lines, formatter)
		if len(l:lines) ==# 0
			return
		endif
	endfor

	" Remember the cursor positions of all windows containing the buffer.
	let l:cursors = s:get_win_cursors(l:bufnr)

	" Rewrite the buffer.
	call nvim_buf_set_lines(l:bufnr, 0, line('$'), 0, l:lines)

	" Restore the cursor positions with an offset.
	let l:offset = len(l:lines) - l:pre_len
	let l:cursors = s:offset_win_cursors(l:cursors, l:offset)

	" Restore the cursor positions.
	call autoformat#restore_win_cursors(l:cursors)
endfunction

" formatLines takes a list of lines and feeds them to the provided formatter.
function! s:format_lines(lines, formatter)
	return systemlist(a:formatter . ' 2> /dev/null', a:lines)
endfunction

" get_win_cursors returns a dictionary containing the cursor positions of all
" windows that contains the provided buffer. The returned dictionary is in the
" form Window-ID: [line, col].
function! s:get_win_cursors(bufnr)
	" Get all window-ids containing the bufnr.
	let l:windows = win_findbuf(a:bufnr)

	let l:cursors = {}
	for w in l:windows
		let l:cursors[w] = nvim_win_get_cursor(w)
	endfor

	return l:cursors
endfunction

" restore_win_cursors will restore the provided cursors using the cursors
" dict returned from s:get_win_cursors.
function! autoformat#restore_win_cursors(cursors)
	for w in keys(a:cursors)
		let l:line = a:cursors[w][0]
		let l:col = a:cursors[w][1]

		try
			call nvim_win_set_cursor(str2nr(w), a:cursors[w])
		catch "Cursor position outside buffer"
			" That's ok!
		endtry
	endfor
endfunction

" offset_win_cursors offsets the cursors using the provided offset amount.
function! s:offset_win_cursors(cursors, offset)
	let l:cursors = a:cursors
	for w in keys(l:cursors)
		let l:cursors[w][0] += a:offset
	endfor

	return l:cursors
endfunction
