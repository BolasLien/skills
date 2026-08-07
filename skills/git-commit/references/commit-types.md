# Conventional Commit Types

| Type | Description | Usage |
|---|---|---|
| `feat` | Feature | New components, features, APIs |
| `fix` | Bug fix | Resolving bugs or issues |
| `refactor` | Refactor | Structural changes with no behavior change |
| `style` | Styling | Formatting-only updates |
| `docs` | Documentation | Documentation or comment-only edits |
| `test` | Tests | Adding or updating tests |
| `chore` | Build/tooling | Dependencies, configs, tooling |
| `perf` | Performance | Improving performance |
| `ci` | CI/CD | GitLab CI or automation changes |
| `build` | Build system | Webpack, Vite, Turbo, etc. |
| `revert` | Revert | Reverting a previous commit |

## Type Selection Rules

- Refactor + new feature → use `feat` (feature takes priority)
- Pure refactor with no user impact → use `refactor`
- Build/dependency/tooling changes → use `chore`
