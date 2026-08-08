return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      interactions = {
        chat = {
          adapter = "openai",
        },
        inline = {
          adapter = "openai",
        },
        cmd = {
          adapter = "openai",
        },
      },
    },
  },
}
