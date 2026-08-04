# NAS SSH / Docker Access Playbook

For accessing this user's NAS at 192.168.0.11.

## Connect
```
ssh -i "$HOME/.ssh/nas_claude" -p 44 bolseiro@192.168.0.11
```
There is NO `~/.ssh/config` alias configured (user may colloquially call it "nas-claude" but it doesn't exist as a resolvable host) — always use the explicit command above. The sandbox `ssh://` protocol path only works for configured capability hosts or resolvable SSH aliases; use bash `ssh` directly otherwise.

## Docker on the NAS
- User `bolseiro` (uid=1026, groups=users,administrators) is NOT in the docker group and `docker` is not in default PATH.
- `sudo` requires a password (no NOPASSWD) — `sudo docker ps` / `sudo -n docker ps` fail without it. Either get the sudo password from the user or locate the docker binary's full path (e.g. via NAS vendor's package manager conventions) to invoke it without sudo if permissions allow.

## Known containers
claude-code, gemini-cli, antigravity-cli — used as reference setups to replicate elsewhere.
