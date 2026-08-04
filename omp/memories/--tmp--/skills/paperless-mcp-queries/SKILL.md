# Querying Paperless-ngx via MCP (write() tool)

The `mcp__paperless_query_documents` tool must be invoked through the generic `write()` tool using protocol-path conventions — NOT by passing a JS object as a positional argument.

## Correct call pattern
```
write(path='xd://mcp__paperless_query_documents', content=JSON.stringify({query, after, before, counts_only}), i='<intent label>')
```
- `content` must be a JSON **string**, not an object.
- Passing `JSON.stringify(...)` as a bare second positional arg (instead of via `content=`) fails with: "Protocol paths are not supported by write()".

## Known query params
`query` (search string), `after`, `before` (date bounds), `counts_only` (bool, for count-only results).

## Common failure mode
A 401 "Invalid token" response means the configured Paperless-ngx API token for the MCP server is expired/invalid — this requires the user to generate/renew the token in Paperless-ngx settings and update the MCP server's env config; it is not a query-syntax problem.
