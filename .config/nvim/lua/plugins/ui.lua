-- ============================================================================
-- 🧠 Personal Neovim overrides
-- ============================================================================

return {
  -- ==========================================================================
  -- 🎨 TokyoNight polish
  -- ==========================================================================

  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      opts.transparent = false

      opts.styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      }

      opts.sidebars = {
        "qf",
        "help",
        "terminal",
        "neo-tree",
        "snacks_explorer",
      }

      opts.floats = "dark"

      return opts
    end,
  },

  -- ==========================================================================
  -- 🍿 Snacks.nvim
  -- ==========================================================================

  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        enabled = true,
      },

      picker = {
        enabled = true,
      },

      notifier = {
        enabled = true,
        timeout = 2500,
      },

      indent = {
        enabled = true,
      },

      scroll = {
        enabled = true,
      },

      words = {
        enabled = true,
      },

      bigfile = {
        enabled = true,
      },

      quickfile = {
        enabled = true,
      },
    },

    keys = {
      {
        "<leader>e",
        function()
          Snacks.explorer()
        end,
        desc = "📁 Explorer",
      },

      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "🔎 Find files",
      },

      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "🔍 Find text",
      },

      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "🕘 Recent files",
      },

      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "📚 Buffers",
      },

      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "🧑‍💻 LazyGit",
      },

      {
        "<leader>tt",
        function()
          Snacks.terminal()
        end,
        desc = "💻 Terminal",
      },
    },
  },

  -- ==========================================================================
  -- 📊 Statusline
  -- ==========================================================================

  {
    "nvim-lualine/lualine.nvim",

    opts = function(_, opts)
      opts.options = opts.options or {}

      opts.options.globalstatus = true
      opts.options.component_separators = {
        left = "│",
        right = "│",
      }

      opts.options.section_separators = {
        left = "",
        right = "",
      }

      opts.sections = {
        lualine_a = {
          {
            "mode",
            icon = "",
          },
        },

        lualine_b = {
          "branch",
        },

        lualine_c = {
          {
            "filename",
            path = 1,
            symbols = {
              modified = " ●",
              readonly = " ",
              unnamed = " [No Name]",
            },
          },
        },

        lualine_x = {
          "diagnostics",
          "filetype",
        },

        lualine_y = {
          "progress",
        },

        lualine_z = {
          "location",
        },
      }

      return opts
    end,
  },

  -- ==========================================================================
  -- 🌈 Better syntax highlighting
  -- ==========================================================================

  {
    "nvim-treesitter/nvim-treesitter",

    opts = {
      ensure_installed = {
        "bash",
        "css",
        "dockerfile",
        "git_config",
        "gitignore",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "nu",
        "python",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },

  -- ==========================================================================
  -- 💡 Better diagnostics
  -- ==========================================================================

  {
    "neovim/nvim-lspconfig",

    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,

        virtual_text = {
          spacing = 4,
          prefix = "●",
        },

        severity_sort = true,

        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      },
    },
  },

  -- ==========================================================================
  -- 🧠 Completion
  -- ==========================================================================

  {
    "saghen/blink.cmp",

    opts = {
      completion = {
        menu = {
          border = "rounded",
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300,
          window = {
            border = "rounded",
          },
        },
      },

      signature = {
        enabled = true,
        window = {
          border = "rounded",
        },
      },
    },
  },

  -- ==========================================================================
  -- 📁 Better icons
  -- ==========================================================================

  {
    "nvim-tree/nvim-web-devicons",

    opts = {
      default = true,
    },
  },

  -- ==========================================================================
  -- 🔧 Which-key
  -- ==========================================================================

  {
    "folke/which-key.nvim",

    opts = {
      preset = "modern",

      delay = 300,

      icons = {
        mappings = true,
      },

      spec = {
        { "<leader>f", group = "🔎 Find" },
        { "<leader>g", group = " Git" },
        { "<leader>t", group = "💻 Terminal" },
        { "<leader>c", group = "🧠 Code" },
        { "<leader>b", group = "📚 Buffers" },
        { "<leader>w", group = "🪟 Windows" },
      },
    },
  },
}
