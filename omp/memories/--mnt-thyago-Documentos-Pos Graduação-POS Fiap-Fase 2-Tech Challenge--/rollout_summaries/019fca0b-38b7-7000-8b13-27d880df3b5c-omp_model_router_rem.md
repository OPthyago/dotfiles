thread_id: 019fca0b-38b7-7000-8b13-27d880df3b5c
updated_at: 1785802662

User asked to install a GitHub skill (Graphify) for general OMP use. A separate model-router extension was attempted (routing requests to a small model to classify which model to send to) but was abandoned as not worth the effort due to added latency/cost; extension was removed via `rm -rf ~/.omp/agent/extensions/model-router`. Noted that OMP auto-discovers extensions only if a package.json with `omp.extensions` manifest exists.
