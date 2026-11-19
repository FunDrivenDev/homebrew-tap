# The tap's one entry point: humans, git hooks (hk.pkl) and CI run these recipes, never the
# tools behind them (README.md, Checks). A scope is `all` (default), `changed` (the files
# that differ from origin/main) or `staged`.

_default:
    @just --list --unsorted

# Once per clone, idempotent: the pinned tools. The git hooks need no install: the dotfiles' git config runs hk.pkl.
init:
    mise install --locked

# The tap has no package dependencies: the pinned tools are all it needs (init).
deps:
    mise install --locked

# Format the casks in scope (brew style --fix); the only recipe that writes.
fmt scope="all":
    scripts/fmt.sh {{ quote(scope) }}

# Lint the files in scope; `family` narrows it to shell, actions or casks (casks need brew).
lint scope="all" family="":
    scripts/lint.sh {{ quote(scope) }} {{ quote(family) }}

# Run the tests of the CI change classifier, when it is in scope.
test scope="all":
    scripts/test.sh {{ quote(scope) }}

# Lint, then test: what the hooks and CI gate on.
check scope="all": (lint scope) (test scope)

# Audit security: `all` (the default) secrets or home paths anywhere in the history, then unsafe workflows and actions; `staged` gitleaks on the git index alone (pre-commit).
audit scope="all":
    scripts/audit.sh {{ quote(scope) }}

# The tests that reach the network: `just lint` already audits each cask online, so there are none of their own.
test-live:
    @echo "No live tests: just lint audits the casks online (brew audit --online)."

# Run the CI workflow locally (.actrc maps the runners).
act event="pull_request":
    act {{ event }} --workflows .github/workflows/ci.yml -s GITHUB_TOKEN="$(gh auth token)"

# CI: which checks the files changed since `base` need; no base means all of them.
ci-changes base="":
    scripts/ci-changes.sh {{ quote(base) }}

# CI: the one verdict from the jobs' results; skipped passes, failed or cancelled fails.
ci-verdict *results:
    scripts/ci-verdict.sh {{ results }}
