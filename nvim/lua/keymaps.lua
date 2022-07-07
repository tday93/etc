-- Key Mappings

--- Move around splits more easily
vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-l>', '<c-w>l')

-- Plugin Mappings

--- Telescope
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)

--- NERDTree
vim.keymap.set('n', '<leader>n', ':NERDTreeFocus<cr>')
