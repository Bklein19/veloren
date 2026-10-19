# Working on Brandon's Veloren fork

Follow Grice's four maxims of conversation.

Read [DEVELOPMENT.md](DEVELOPMENT.md) before making game changes. It is the
maintained reference for this checkout. [README-FORK.md](README-FORK.md) covers
playing, saves, and the installed tools.

- This is Brandon's personal fork at `https://github.com/Bklein19/veloren`.
  The playable branch is `codex/personal-game`. Inspect the current branch and
  working tree before editing; preserve unrelated work. Use the `codex/` prefix
  when a task needs a new branch.
- Keep gameplay changes in this source checkout. The desktop shortcut runs
  `build-and-play.cmd`, which rebuilds and launches it. The separate downloaded
  installation is not the development copy.
- Use `build-and-play.cmd --build-only` for a game build. It selects the pinned
  GNU Rust toolchain, native tools, cached dependencies, and build features.
  Avoid switching targets, toolchains, or profiles during routine edits.
- Use `test-gameplay.cmd` for shared-system tests, optionally followed by a test
  name filter. See the development guide for other crates and formatting.
- Validate the changed behavior. For Rust changes, build the actual game after
  focused checks. Documentation changes need no game build. For assets, check
  their references and loading in game when practical.
- Preserve the rocket glider and other personal changes unless the task changes
  them. Keep the current custom features section in `DEVELOPMENT.md` accurate.
- `userdata/` contains this checkout's saves and settings. Preserve it and the
  separate portable installation. Use a normal game quit before a rebuild that
  must replace a running executable.
- `origin` is Brandon's fork. `upstream` is the GitHub mirror. The mirror
  rewrites LFS assets, so its commit history differs from the `canonical`
  GitLab remote. Use the GitHub mirror for upstream merges. Follow the current
  task's authorization for Git commits and pushes.
- AI-assisted code and assets are permitted in this personal fork, as documented
  at the top of `CONTRIBUTING.md`. Retain the GPL license and applicable credits.

When build commands, tool locations, or personal features change, update the
guide and affected helper scripts in the same task. Describe the checks actually
run and distinguish them from manual gameplay observations.
