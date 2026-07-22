return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets", -- Collection of pre-made snippets
  },
  config = function()
    local luasnip = require("luasnip")

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Load custom snippets from snippets/ directory (if it exists)
    require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets" })

    luasnip.config.setup({
      -- Enable autotriggered snippets
      enable_autosnippets = true,

      -- Use Tab (or some other key if you prefer) to trigger visual selection
      store_selection_keys = "<Tab>",

      -- Update more often for dynamic snippets
      update_events = "TextChanged,TextChangedI",

      -- Delete check prevents snippets from being deleted when leaving insert mode
      delete_check_events = "TextChanged",

      -- History allows you to jump back into snippets even after you've moved outside
      history = true,

      -- Snippet regions autotrigger themselves when you enter them
      region_check_events = "CursorMoved",
    })

    -- Load custom filetype snippets
    local ft_snippets = {
      all = function()
        local s = luasnip.snippet
        local t = luasnip.text_node
        local i = luasnip.insert_node

        return {
          s("todo", {
            t("TODO("),
            i(1, "name"),
            t("): "),
            i(2, "description"),
          }),
          s("fixme", {
            t("FIXME("),
            i(1, "name"),
            t("): "),
            i(2, "description"),
          }),
        }
      end,

      ruby = function()
        local s = luasnip.snippet
        local t = luasnip.text_node
        local i = luasnip.insert_node
        local fmt = require("luasnip.extras.fmt").fmt

        return {
          s("pry", t("binding.pry")),
          s("desc", fmt([[
            describe '{}' do
              {}
            end
          ]], {
            i(1, "description"),
            i(2, "# test code"),
          })),
          s("it", fmt([[
            it '{}' do
              {}
            end
          ]], {
            i(1, "should do something"),
            i(2, "# test code"),
          })),
          s("let", fmt([[
            let(:{}) {{ {} }}
          ]], {
            i(1, "variable"),
            i(2, "value"),
          })),
        }
      end,

      javascript = function()
        local s = luasnip.snippet
        local t = luasnip.text_node
        local i = luasnip.insert_node
        local fmt = require("luasnip.extras.fmt").fmt

        return {
          s("cl", fmt("console.log({})", { i(1) })),
          s("desc", fmt([[
            describe('{}', () => {{
              {}
            }})
          ]], {
            i(1, "description"),
            i(2, "// test code"),
          })),
          s("it", fmt([[
            it('{}', () => {{
              {}
            }})
          ]], {
            i(1, "should do something"),
            i(2, "// test code"),
          })),
        }
      end,

      typescript = function()
        local s = luasnip.snippet
        local t = luasnip.text_node
        local i = luasnip.insert_node
        local fmt = require("luasnip.extras.fmt").fmt

        return {
          s("cl", fmt("console.log({})", { i(1) })),
          s("desc", fmt([[
            describe('{}', () => {{
              {}
            }})
          ]], {
            i(1, "description"),
            i(2, "// test code"),
          })),
          s("it", fmt([[
            it('{}', () => {{
              {}
            }})
          ]], {
            i(1, "should do something"),
            i(2, "// test code"),
          })),
        }
      end,

      yaml = function()
        local s = luasnip.snippet
        local t = luasnip.text_node
        local i = luasnip.insert_node
        local fmt = require("luasnip.extras.fmt").fmt

        return {
          -- Ruby debug service (rdbg on port 38698)
          s("dap-ruby", fmt([[
  {}:
    build: .
    volumes:
      - .:/app
    ports:
      - "38698:38698"
    command: bundle exec rdbg -n --open --host 0.0.0.0 --port 38698 -c -- {}
    environment:
      - RUBY_DEBUG_OPEN=true
    stdin_open: true
    tty: true
          ]], {
            i(1, "app"),
            i(2, "rails server"),
          })),

          -- Node.js debug service (--inspect on port 9229)
          s("dap-node", fmt([[
  {}:
    build: .
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "9229:9229"
      - "3000:3000"
    command: node --inspect=0.0.0.0:9229 {}
    environment:
      - NODE_ENV=development
          ]], {
            i(1, "app"),
            i(2, "index.js"),
          })),

          -- Go debug service (delve on port 2345)
          s("dap-go", fmt([[
  {}:
    build: .
    volumes:
      - .:/app
    ports:
      - "2345:2345"
      - "8080:8080"
    command: dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient {}
    security_opt:
      - "apparmor=unconfined"
      - "seccomp=unconfined"
    cap_add:
      - SYS_PTRACE
          ]], {
            i(1, "app"),
            i(2, "./cmd/main.go"),
          })),

          -- Python debug service (debugpy on port 5678)
          s("dap-python", fmt([[
  {}:
    build: .
    volumes:
      - .:/app
    ports:
      - "5678:5678"
      - "8000:8000"
    command: python -m debugpy --listen 0.0.0.0:5678 --wait-for-client {}
    environment:
      - PYTHONUNBUFFERED=1
          ]], {
            i(1, "app"),
            i(2, "main.py"),
          })),
        }
      end,
    }

    -- Register custom snippets
    for ft, snippets_fn in pairs(ft_snippets) do
      luasnip.add_snippets(ft, snippets_fn())
    end
  end,
  keys = {
    {
      "<Tab>",
      function()
        local luasnip = require("luasnip")
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          return "<Tab>"
        end
      end,
      expr = true,
      silent = true,
      mode = "i",
      desc = "Expand or jump to next snippet node",
    },
    {
      "<Tab>",
      function()
        require("luasnip").jump(1)
      end,
      mode = "s",
      desc = "Jump to next snippet node",
    },
    {
      "<S-Tab>",
      function()
        require("luasnip").jump(-1)
      end,
      mode = { "i", "s" },
      desc = "Jump to previous snippet node",
    },
    {
      "<C-E>",
      function()
        local luasnip = require("luasnip")
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end,
      mode = { "i", "s" },
      desc = "Cycle snippet choices",
    },
  },
}
