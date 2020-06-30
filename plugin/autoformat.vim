if exists('g:loaded_autoformat')
  finish
endif
let g:loaded_autoformat = 1

command! AutoformatBuffer call autoformat#format_buffer(str2nr(expand("<abuf>")))
