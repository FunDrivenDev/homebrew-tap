# The tap's one entry point: humans, git hooks (hk.pkl) and CI run these recipes, never the
# tools behind them (README.md, Checks). A scope is `all` (default), `changed` (the files
# that differ from origin/main) or `staged`.

_default:
    @just --list --unsorted

# Once per clone, idempotent: the pinned tools, then the git hooks.
init:
    mise install
    hk install

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

# Secrets or home paths anywhere in the history, then unsafe workflows and actions.
audit:
    gitleaks git --config .gitleaks.toml --redact --no-banner --log-level warn .
    zizmor --quiet .

# Run the CI workflow locally (.actrc maps the runners).
act event="pull_request":
    act {{ event }} --workflows .github/workflows/ci.yml -s GITHUB_TOKEN="$(gh auth token)"

# CI: which checks the files changed since `base` need; no base means all of them.
ci-changes base="":
    scripts/ci-changes.sh {{ quote(base) }}

# CI: the one verdict from the jobs' results; skipped passes, failed or cancelled fails.
ci-verdict *results:
    scripts/ci-verdict.sh {{ results }}
