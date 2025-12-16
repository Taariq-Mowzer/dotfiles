require("obsidian").setup({
	workspaces = {
		{
			name = "personal",
			path = "~/Documents/Obsidian-Notes",
		},
	},
	completion = {
		nvim_cmp = true,
		min_chars = 2,
	},
	-- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
	-- way then set 'mappings = {}'.
	mappings = {
	  -- Overrides the 'gd' mapping to work on markdown/wiki links within your vault.
	  ["gd"] = {
		action = function()
		  return require("obsidian").util.gf_passthrough()
		end,
		opts = { noremap = false, expr = true, buffer = true },
	  },
	  -- Toggle check-boxes.
	  ["<leader>ch"] = {
		action = function()
		  return require("obsidian").util.toggle_checkbox()
		end,
		opts = { buffer = true },
	  },
	  -- Smart action depending on context, either follow link or toggle checkbox.
	  ["<cr>"] = {
		action = function()
		  return require("obsidian").util.smart_action()
		end,
		opts = { buffer = true, expr = true },
	  }
	},
	new_notes_location = "notes_subdir",
	picker = {
		-- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
		name = "telescope.nvim",
		-- Optional, configure key mappings for the picker. These are the defaults.
		-- Not all pickers support all mappings.
		note_mappings = {
		  -- Create a new note from your query.
		  new = "<C-x>",
		  -- Insert a link to the selected note.
		  insert_link = "<C-l>",
		},
		tag_mappings = {
		  -- Add tag(s) to current note.
		  tag_note = "<C-x>",
		  -- Insert a tag at the current location.
		  insert_tag = "<C-l>",
	},
  },
  templates = {
	  folder = "Templates",
	  date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
  },

  -- Optional, customize how note IDs are generated given an optional title.
  ---@param title string|?
  ---@return string
  note_id_func = function(title)
	  return title
  end,
	-- Optional, customize how note file names are generated given the ID, target directory, and title.
	---@param spec { id: string, dir: obsidian.Path, title: string|? }
	---@return string|obsidian.Path The full path to the new note.
	note_path_func = function(spec)
	  -- This is equivalent to the default behavior.
	  local path = spec.dir / "Unsorted" / tostring(spec.id)
	  return path:with_suffix(".md")
	end,
})
vim.opt.conceallevel = 2
vim.keymap.set("n", "<leader>fo",  "<cmd>ObsidianQuickSwitch<cr>", { desc = "Obsidian: quick switch note" })
