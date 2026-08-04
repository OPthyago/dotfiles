# OMP + LM Studio Configuration

Use when configuring OMP (Oh My Pi agent CLI) to talk to LM Studio, or debugging model routing / reasoning output.

## Point OMP at a remote/LAN LM Studio server
1. Verify reachability first: `curl -s -m 3 http://<host>:1234/v1/models` — should return a model list.
2. Set override in `~/.omp/agent/.env`:
   `LM_STUDIO_BASE_URL=http://<host>:1234/v1`
3. Restart omp. Models surface as `lm-studio/<model-id>`.
4. Pattern generalizes: any OMP provider base URL can be overridden via `<PROVIDER>_BASE_URL` in `~/.omp/agent/.env`. LM Studio provider is keyless by default for local/LAN.

## Model roles
- `completion(prompt, model="smol"|"slow"|"default")` is explicit routing, not automatic. Configure via OMP's modelRoles config (e.g. default=claude-sonnet, smol=local LM Studio model, slow=claude-opus).
- Verify actual routing via: session's `Model: provider/model-id` context line (ground truth), `/model` command, `omp models` CLI, or tool statusEvents during `eval`.

## Enabling chain-of-thought/reasoning on a local LM Studio model
1. Edit `~/.lmstudio/.internal/user-concrete-model-default-config/<provider>/<model>.json`, set `"llm.prediction.reasoning.enableThinking": true`.
2. Reload the model: `lms load` (or reload from LM Studio UI).
3. ALSO check the harness side: `~/.omp/agent/config.yml` key `defaultThinkingLevel` must be non-empty (e.g. "high") for OMP to request reasoning from the model.
4. Verify with a direct API call:
```
curl -s http://127.0.0.1:1234/v1/chat/completions -X POST -H 'Content-Type: application/json' \
  -d '{"model":"<model>","messages":[...],"max_tokens":1024}' \
  | jq '{content:.choices[0].message.content, reasoning_tokens:.usage.completion_tokens_details.reasoning_tokens, has_reasoning:(.choices[0].message.reasoning_content|length>0), finish:.choices[0].finish_reason}'
```
Both `reasoning_tokens > 0` and `has_reasoning: true` confirm the fix. Model capability and harness request setting are independent — check both.
