-- ============================================================================
-- 🧠 Language Server Protocol
-- ============================================================================

return {
  {
    "neovim/nvim-lspconfig",

    opts = {
      servers = {
        -- 🦀 Rust
        rust_analyzer = {},

        -- 🐹 Go
        gopls = {},

        -- 🟦 TypeScript / JavaScript
        vtsls = {},

        -- 🌙 Lua
        lua_ls = {},

        -- 🌐 HTML
        html = {},

        -- 🎨 CSS
        cssls = {},

        -- 📦 JSON
        jsonls = {},

        -- ⚙️ YAML
        yamlls = {},

        -- 🐚 Bash
        bashls = {},
      },
    },
  },
}
