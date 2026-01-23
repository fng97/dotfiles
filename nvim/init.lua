-- OPTIONS

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true -- enable line numbers
vim.opt.relativenumber = true -- make them relative
vim.opt.scrolloff = 3 -- pad lines around cursor vertically
vim.opt.sidescrolloff = 3 -- pad lines around cursor horizontally
vim.opt.undofile = true -- persist undo history
vim.opt.cmdheight = 0 -- hide command line unless active
vim.opt.confirm = true -- don't fail silently
vim.opt.ignorecase = true -- ignore case when searching...
vim.opt.smartcase = true -- unless uppercase used in search
vim.opt.textwidth = 100 -- break lines at 100
vim.opt.tabstop = 2 -- a tab character is displayed as 2 spaces
vim.opt.softtabstop = 2 -- pressing tab inserts 2 spaces
vim.opt.shiftwidth = 2 -- indentation uses 2 spaces
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.smartindent = true -- automatically indent new lines
vim.opt.autoindent = true -- copy indent from current line
vim.opt.breakindent = true -- start with tab in case of line wrap

-- PLUGINS

-- NOTE: Pinning version with `vim.pack` wasn't working for me. Just forked everything instead to
-- make sure versions are pinned.
vim.pack.add({
	"https://github.com/fng97/conform.nvim", -- auto-formatting
	"https://github.com/fng97/fzf-lua", -- fuzzy fd/ripgrep
	"https://github.com/fng97/nvim-treesitter", -- better syntax highlighting
	"https://github.com/fng97/vscode.nvim", -- theme
})

vim.o.background = "light"
require("vscode").setup({})
vim.cmd.colorscheme("vscode")

require("fzf-lua").setup({})

require("nvim-treesitter.configs").setup({
	auto_install = true, -- just install as needed
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
require("conform").setup({
	format_on_save = { lsp_format = "never" },
	formatters_by_ft = {
		_ = { "trim_whitespace", "trim_newlines" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		zig = { "zigfmt" },
		rust = { "rustfmt" },
		cmake = { "cmake_format" },
		python = { "ruff_format" },
		bash = { "shfmt" },
		sh = { "shfmt" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		markdown = { "prettier" },
		json = { "jq" },
		html = { "prettier" },
		css = { "prettier" },
	},
})

-- AUTOCOMMANDS

vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 150 })
	end,
	desc = "Highlight yanked text",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "cpp", "c" },
	callback = function()
		vim.bo.commentstring = "// %s"
	end,
	desc = "Set comment style to '//' for C and C++ (default is '/**/')",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_gb"
	end,
	desc = "Enable spell check in Markdown",
})

-- KEY MAPPINGS

vim.keymap.set("v", "<", "<gv", { desc = "Indent left (keep highlight)" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right (keep highlight)" })
vim.keymap.set("n", "<leader>tt", function()
	vim.o.background = (vim.o.background == "dark") and "light" or "dark"
end, { desc = "Toggle background light/dark" })

-- Search
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Grep files" })
vim.keymap.set("n", "<leader><leader>", fzf.git_files, { desc = "Search files" })
vim.keymap.set("n", "<leader>sf", function()
	fzf.files({ fd_opts = "--type f --unrestricted --follow --exclude .git" })
end, { desc = "Search all files" })
vim.keymap.set("n", "<leader>sh", fzf.helptags, { desc = "Search help" })
vim.keymap.set("n", "<leader>sk", fzf.keymaps, { desc = "Search keymap" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "n", "nzz", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzz", { desc = "Next search result (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down (centered)" })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Go to older cursor position (centered)" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Go to newer cursor position (centered)" })

-- Window Management
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split horizontally", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split vertically", remap = true })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete current window", remap = true })

-- Buffer Management
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete current buffer" })
vim.keymap.set("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end, { desc = "Delete other buffers" })

-- Clipboard
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>d", '"+d', { desc = "Delete to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard after cursor" })
vim.keymap.set("n", "<leader>yy", '"+yy', { desc = "Yank line to system clipboard" })
vim.keymap.set("n", "<leader>dd", '"+dd', { desc = "Delete line to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
vim.keymap.set("v", "<leader>d", '"+d', { desc = "Delete selection to system clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste to selection from system clipboard" })
vim.keymap.set("n", "<leader>yr", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "Yank relative file path to system clipboard" })
vim.keymap.set("n", "<leader>yf", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Yank full file path to system clipboard" })
vim.keymap.set("n", "<leader>yn", function()
	vim.fn.setreg("+", vim.fn.expand("%:t"))
end, { desc = "Yank file name to system clipboard" })
