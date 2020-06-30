# autoformat.nvim

NOTE: autoformat.nvim does not contain any default formatters or keymappings.
You'll have to define them yourself.

## About

autoformat.nvim will allow you to easily setup autoformating for any filetype.

### Features

- Synchronous formatting, you can't edit the file while it's formatting it.
- Cursor stays in position after formatting. Even in multiple open windows!
- Run multiple formatters in order after each other. This allows you to run for
  example `goimports` and `gofmt -s`.

### Install

autoformat.nvim requires Neovim 0.4.0+ (PR welcome!).

For [vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'akarl/autoformat.nvim'
```

### Examples

```vim
" Define autoformatter
" First argument is the filetype, then a list of formatters that can take input
" from stdin.
call autoformat#config('go', 
	\ ['goimports -local "$(go list -m)"', 'gofmt -s']) 
call autoformat#config('python', 
	\ ['black -']) 

" Format file on save.
autocmd! BufWritePre * :Autoformat

" Format on key mapping.
nnoremap <Leader>= :Autoformat<CR>
```

