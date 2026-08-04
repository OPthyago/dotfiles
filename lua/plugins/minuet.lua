local M = {}

-- servidor FIM dedicado (Qwen2.5-Coder-3B) — separado do :1235 usado pelo OMP,
-- pra autocomplete nunca enfileirar atras de tarefa longa de agente
local HOST = "http://127.0.0.1:1236"

local function llamacpp_available()
  local handle = io.popen("curl -sf --max-time 1 " .. HOST .. "/health 2>/dev/null")
  if not handle then return false end
  local res = handle:read("*a")
  handle:close()
  return res:find('"status"') ~= nil
end

function M.config()
  if not llamacpp_available() then
    vim.notify(
      "Minuet: llama.cpp nao disponivel em " .. HOST .. " — inline completion desativado\n"
        .. "  systemctl --user status llama-server",
      vim.log.levels.WARN,
      { title = "Minuet" }
    )
    return
  end
  require("minuet").setup(M.setup_opts)

  -- <Tab> para aceitar a sugestao.
  -- O LazyVim ja monta o Tab como map({snippet_forward, ai_nes, ai_accept}) + fallback,
  -- e o hook ai_accept esta vago (so existe se voce usa o extra do copilot).
  -- Registrando o minuet ali, o Tab aceita a sugestao SEM sequestrar a tecla:
  -- se nao houver sugestao a cadeia segue pro snippet jump e depois pro Tab literal.
  local ok_cmp, lazy_cmp = pcall(require, "lazyvim.util.cmp")
  if ok_cmp then
    lazy_cmp.actions.ai_accept = function()
      local vt = require("minuet.virtualtext")
      if vt.action.is_visible() then
        vt.action.accept()
        return true
      end
    end
  end
end

-- llama.cpp expoe FIM real no endpoint /infill (input_prefix/input_suffix).
-- O /v1/completions ignora o suffix e vira continuacao burra, entao nao serve.
-- Como o minuet fala o dialeto OpenAI, traduzimos request e response.

-- Primeira linha nao-vazia do suffix. Usada como stop: sem isso o modelo
-- costuma continuar escrevendo o proprio suffix e a completion sai duplicada.
local function first_meaningful_line(s)
  if type(s) ~= "string" then
    return nil
  end
  for line in s:gmatch("[^\n]+") do
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed ~= "" then
      return trimmed
    end
  end
  return nil
end

local function to_llamacpp_infill(d)
  local b = d.body

  local stop = vim.deepcopy(b.stop or {})
  local boundary = first_meaningful_line(b.suffix)
  if boundary then
    table.insert(stop, boundary)
  end

  d.body = {
    input_prefix = b.prompt,
    input_suffix = b.suffix,
    n_predict = b.max_tokens,
    stop = stop,
    stream = b.stream,
    temperature = b.temperature,
    top_p = b.top_p,
  }
  return d
end

local function get_content(json)
  return json.content
end

M.setup_opts = {
  provider = "openai_fim_compatible",
  provider_options = {
    openai_fim_compatible = {
      name = "llamacpp",
      model = "qwen2.5-coder-3b",
      end_point = HOST .. "/infill",
      -- servidor local sem auth: get_api_key aceita funcao, precisa retornar string nao-vazia
      api_key = function()
        return "no-key"
      end,
      stream = true,
      transform = { to_llamacpp_infill },
      get_text_fn = {
        stream = get_content,
        no_stream = get_content,
      },
      optional = {
        max_tokens = 128,
        stop = { "\n\n" },
        temperature = 0.2,
      },
    },
  },
  virtualtext = {
    auto_trigger_ft = {
      "lua", "typescript", "javascript", "go", "python",
      "rust", "html", "css", "svelte", "vue", "toml",
    },
    keymap = {
      -- 'accept' fica fora daqui de proposito: o minuet mapeia a tecla de forma
      -- crua, sem fallback, o que quebraria o Tab do blink e a indentacao.
      -- O aceite vai pelo hook ai_accept do LazyVim, registrado em M.config().
      accept_line = "<M-a>",
      dismiss = "<C-]>",
    },
  },
}

return {
  "milanglacier/minuet-ai.nvim",
  event = "InsertEnter",
  config = M.config,
}
