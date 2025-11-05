-- PLUGINS

vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-file-browser.nvim",
	"https://github.com/nvim-lua/plenary.nvim", -- telescope dependency
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/f-person/auto-dark-mode.nvim",
	"https://github.com/Mofiqul/vscode.nvim", -- theme
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-lualine/lualine.nvim",
})

require("telescope").setup({})
require("telescope").load_extension("file_browser")
require("gitsigns").setup({})
require("auto-dark-mode").setup({})
require("vscode").setup({})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"asm",
		"bash",
		"c",
		"cmake",
		"cpp",
		"dockerfile",
		"json",
		"lua",
		"markdown",
		"markdown_inline",
		"nix",
		"python",
		"rust",
		"zig",
	},
	highlight = { enable = true },
})

require("lualine").setup({
	options = { globalstatus = true },
	sections = { lualine_x = { "searchcount" } },
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

-- OPTIONS

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 3 -- pad lines around cursor
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
vim.opt.breakindent = true -- start with tab in case of line wrap
vim.opt.splitright = true -- by default open splits to the right
vim.cmd.colorscheme("vscode")

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

-- This provides "hot reloads" when I'm working on a blog post. It's only enabled when working in
-- the "website" repo on macOS.
if vim.fn.getcwd():match("website$") and vim.fn.has("mac") == 1 then
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = "content/*.md", -- only when editing pages
		callback = function()
			local html_path = "zig-out/" .. vim.fn.expand("%:t:r") .. ".html"
			vim.system(
				{ "zig", "build", "reload", "--", html_path },
				{ text = true },
				function(result)
					if result.code == 0 then
						print("✅ Web page hot-reloaded")
					else
						print("❌ Hot reload failed\n" .. (result.stderr or ""))
					end
				end
			)
		end,
	})
end

-- LSP

vim.lsp.enable({
	"clangd",
	"rust_analyzer",
	"pylsp",
	"zls",
})

-- KEY MAPPINGS

-- search

vim.keymap.set("n", "<leader>/", require("telescope.builtin").live_grep, { desc = "Grep files" })

vim.keymap.set(
	"n",
	"<leader><leader>",
	require("telescope.builtin").find_files,
	{ desc = "Search files" }
)

vim.keymap.set(
	"n",
	"<leader>sh",
	require("telescope.builtin").help_tags,
	{ desc = "[S]earch [H]elp" }
)

vim.keymap.set(
	"n",
	"<leader>sk",
	require("telescope.builtin").keymaps,
	{ desc = "[S]earch [K]eymaps" }
)

vim.keymap.set("n", "<leader>sf", function()
	require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end, { desc = "[S]earch [F]iles (including hidden/ignored)" })

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

vim.keymap.set("v", "<", "<gv", { desc = "Indent Left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down and center" })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Go to older cursor position and center" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Go to newer cursor position and center" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- navigation

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- window management

vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "[D]elete [W]indow", remap = true })

-- buffer management

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<CR>", { desc = "[N]ew [B]uffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "[D]elete [B]uffer" })

vim.keymap.set("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end, { desc = "Delete [O]ther [B]uffers" })

-- clipboard

vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>d", '"+d', { desc = "Delete to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard after cursor" })
vim.keymap.set("n", "<leader>yy", '"+yy', { desc = "Yank line to system clipboard" })
vim.keymap.set("n", "<leader>dd", '"+dd', { desc = "Delete line to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
vim.keymap.set("v", "<leader>d", '"+d', { desc = "Delete selection to system clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste to selection from system clipboard" })

-- IDE goodies

vim.keymap.set(
	"n",
	"gd",
	require("telescope.builtin").lsp_definitions,
	{ desc = "[G]oto [D]efinition" }
)

vim.keymap.set(
	"n",
	"gD",
	"<cmd>vsplit | lua vim.lsp.buf.definition()<CR>",
	{ desc = "[G]oto [D]efinition in right split" }
)

vim.keymap.set("n", "<leader>gb", require("gitsigns").blame_line, { desc = "[G]it [B]lame" })
vim.keymap.set("n", "<leader>gB", require("gitsigns").blame, { desc = "[G]it [B]lame (window)" })

vim.keymap.set("n", "<leader>e", function()
	require("telescope").extensions.file_browser.file_browser({ path = vim.fn.expand("%:p:h") })
end, { desc = "UI: Toggle file [E]xplorer tree" })
