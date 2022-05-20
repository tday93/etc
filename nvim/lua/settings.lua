HOME = os.getenv("HOME")

vim.g.mapleader = "<Space>"
vim.g.maplocalleader = ","

vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.python_host_prog = "/usr/bin/python"


-- Basic Settings
vim.o.encoding = "utf-8"
vim.o.backspace = "indent,eol,start" -- backspace works on every character in instert mode
vim.o.history = 1000
vim.o.completeopt = 'menuone,noselect'

-- Display

vim.o.foldenable = false
vim.o.foldmethod = 'syntax'

-- Sidebar
vim.o.number = true -- absolute line number for line
vim.o.relativenumber = true -- relative line numbers
vim.o.numberwidth = 3 -- reserve three spaces for line number
vim.o.showcmd = true -- display command in bottom bar

-- White Characters
vim.o.shiftwidth = 2 -- indentation rule


-- Filetype Changes
vim.cmd([[
  au BufRead,BufNewFile */tasks/*.yml set filetype=yaml.ansible
]])


-- Restore cursor to last position
vim.cmd([[
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]])



-- Commands mode
vim.o.wildmenu = true -- on TAB, complete options for system command
vim.o.wildmode = "longest,list,full"


-- Appearance
vim.o.background = 'dark'

vim.o.termguicolors = true
