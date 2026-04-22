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
local indent_spaces_count = 4
vim.opt.tabstop = indent_spaces_count -- spaces to display for tab character
vim.opt.softtabstop = indent_spaces_count -- spaces to insert when tab pressed
vim.opt.shiftwidth = indent_spaces_count -- spaces to use for indentation
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.smartindent = true -- automatically indent new lines
vim.opt.autoindent = true -- copy indent from current line
vim.opt.breakindent = true -- start with tab in case of line wrap

-- PLUGINS

-- NOTE: Pinning version with `vim.pack` wasn't working for me. Just forked everything instead.
vim.pack.add({
	"https://github.com/fng97/conform.nvim", -- auto-formatting
	"https://github.com/fng97/fzf-lua", -- fuzzy fd/ripgrep
	"https://github.com/fng97/vscode.nvim", -- theme
	"https://github.com/fng97/auto-dark-mode.nvim", -- auto light/dark theme
})

vim.o.background = "light"
require("vscode").setup({})
vim.cmd.colorscheme("vscode")

require("auto-dark-mode").setup({ fallback = "light" })

require("fzf-lua").setup({})

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
		vim.opt_local.textwidth = 80
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "gitcommit" },
	callback = function()
		vim.opt_local.formatoptions:append("q")
		vim.opt_local.comments:append("n:>")
	end,
	desc = "Fix hard wrapping of quoted text (e.g. `gw`)",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.textwidth = 88
	end,
})

-- KEY MAPPINGS

-- Misc
vim.keymap.set("v", "<", "<gv", { desc = "Indent left (keep highlight)" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right (keep highlight)" })
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", {
	desc = "Go down a line (works on wrapped lines)",
	expr = true,
	silent = true,
})
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", {
	desc = "Go up a line (works on wrapped lines)",
	expr = true,
	silent = true,
})

-- Search
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Grep files" })
vim.keymap.set("n", "<leader>*", function()
	local word = vim.fn.expand("<cword>")
	fzf.live_grep({ search = word })
end, { desc = "Grep word under cursor" })
vim.keymap.set("v", "<leader>*", function()
	local utils = require("fzf-lua.utils")
	local selection = utils.get_visual_selection()
	require("fzf-lua").grep({ search = selection })
end, { desc = "Grep selection" })
vim.keymap.set("n", "<leader><leader>", function()
	fzf.git_files({ cmd = "git ls-files --recurse-submodules" })
end, { desc = "Search files" })
vim.keymap.set("n", "<leader>sf", function()
	fzf.files({ fd_opts = "--type f --unrestricted --follow --exclude .git" })
end, { desc = "Search all files" })
vim.keymap.set("n", "<leader>sh", fzf.helptags, { desc = "Search help" })
vim.keymap.set("n", "<leader>sk", fzf.keymaps, { desc = "Search keymap" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<leader>sr", function()
	fzf.resume()
end, { desc = "Resume search" })
vim.keymap.set("n", "<leader>'", fzf.marks, { desc = "Search marks" })

-- Grep-based go-to-definition. What I grep for depends on the language. I also add search paths
-- depending on language. E.g. for Zig I add the standard library path and dependency source paths.
vim.keymap.set("n", "<leader>gd", function()
	local def_patterns = {
		zig = { "const %s =", "fn %s" },
		python = { "def %s", "class %s" },
		cpp = { "class %s", "struct %s ", "enum %s", "%s\\(" },
	}
	local extra_paths = {
		zig = function()
			local handle = io.popen("zig env 2>/dev/null")
			if not handle then
				return {}
			end
			local output = handle:read("*a")
			handle:close()
			local paths = {}
			local std_dir = output:match('%.std_dir%s*=%s*"([^"]+)"')
			if std_dir then
				table.insert(paths, std_dir)
			end
			-- zig-pkg/ holds local deps since 2026-02-06
			local pkg_dir = vim.fn.getcwd() .. "/zig-pkg"
			if vim.fn.isdirectory(pkg_dir) == 1 then
				table.insert(paths, pkg_dir)
			end
			return paths
		end,
	}
	local word = vim.fn.expand("<cword>")
	local ft = vim.bo.filetype
	local patterns = def_patterns[ft]
	if not patterns then
		fzf.live_grep({ search = word })
		return
	end
	local rg_patterns = vim.tbl_map(function(pat)
		return pat:format(word)
	end, patterns)
	local path_fn = extra_paths[ft]
	local search_paths = vim.list_extend({ "." }, path_fn and path_fn() or {})
	fzf.grep({ search = table.concat(rg_patterns, "|"), no_esc = true, search_paths = search_paths })
end, { desc = "Go to definition (grep-based)" })

-- Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "n", "nzz", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzz", { desc = "Next search result (centered)" })

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
