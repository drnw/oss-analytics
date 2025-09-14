set dotenv-load := true
venv := ".venv"

# Ensure uv exists (nice error if missing)
check-uv:
    @which uv >/dev/null || (echo "uv not found. See https://docs.astral.sh/uv/" && exit 1)

py-init: check-uv
   uv init --no-readme --no-workspace
   cp ../pyproject.toml .
   just lock
   just lock-dev
   just setup-dev

# ---- LOCKFILES ----
# Compile runtime lockfile from pyproject (top-level deps only)
lock: check-uv
    uv pip compile pyproject.toml -o requirements.lock

# Compile dev lockfile (includes optional [project.optional-dependencies].dev)
lock-dev: check-uv
    uv pip compile pyproject.toml -o requirements-dev.lock --extra dev

# ---- SETUP ----
# Fresh venv + sync exactly to the *runtime* lockfile
setup: check-uv
    python3 -m venv {{venv}}
    uv pip sync requirements.lock

# Fresh venv + sync to *both* runtime and dev lockfiles
setup-dev: check-uv
    python3 -m venv {{venv}}
    uv pip sync requirements.lock requirements-dev.lock

# ---- DIFF ----
# Preview differences between venv and *runtime* lock (no changes)
diff:
    uv pip sync --dry-run requirements.lock

# Preview differences between venv and combined runtime+dev locks
diff-dev:
    uv pip sync --dry-run requirements.lock requirements-dev.lock

# ---- OBSERVABLE ----
etl:
    {{venv}}/bin/python -m etl.cli        # Summarises the python

dev:
    bash -lc 'nvm use && npm run dev'                   # ensure nvm is loaded, then start Observable dev server
