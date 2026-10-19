# Brandon's Veloren fork

Personal repository: https://github.com/Bklein19/veloren

The `codex/personal-game` branch is the playable personal version. It starts from
Veloren's GitHub mirror, which includes the game assets as regular Git files.
The original GPL-3.0-or-later license and upstream credits still apply.

## Play and edit

Double-click the **Veloren** desktop shortcut, or run `build-and-play.cmd`.
The launcher compiles changed Rust code and then starts this repository's game.
It reads assets from this checkout's `assets` directory. It never updates the
checkout automatically.

- Voxel models, textures, audio, and game data are under `assets/`.
- Shared gameplay components and combat logic are under `common/`.
- World generation, towns, and dungeons are under `world/`.
- AI and server behavior are under `server/` and `rtsim/`.
- Rendering, menus, controls, and the game window are under `voxygen/`.

Close the game before changing source code, then launch again to rebuild it.
Existing assets can also reload while playing when that asset type supports it.

Singleplayer works offline. The launcher uses Cargo's offline mode, so launching
and rebuilding with the cached dependencies does not require internet access.
Adding or updating dependencies requires fetching them online first.

## Rocket glider

Open your glider with **Ctrl**, then tap **Shift** for a burst or hold **Shift**
for continuous rocket thrust. Look upward to climb and steer with the camera.
The rocket has no fuel cost, stamina drain, or cooldown. Releasing Shift returns
to normal gliding. You can also launch from the ground with the glider open.
The **Glider Rocket Boost** binding can be changed in the controls settings.

## Saves

This fork uses `userdata/` inside the checkout. Existing saves and settings were
copied from the portable installation during setup. The original installation
and its saves are kept separately. `userdata/` and `target/` are ignored by Git.

## Windows build setup

This PC has Rust `nightly-2026-06-13-x86_64-pc-windows-gnu` installed with the
minimal rustup profile. Native tools are installed under
`%USERPROFILE%\.codex\tools\veloren`:

- WinLibs GCC 16.2.0, x86_64 POSIX SEH, MinGW-w64 UCRT 14.0.0 r3, in `mingw64/`.
- CMake 3.31.8 in `cmake-3.31.8-windows-x86_64/`.
- Ninja 1.13.2 in `ninja/`.
- Python 3 is available on PATH.

Set `VELOREN_TOOLS` to use the same directory layout elsewhere. The launcher
adds these tools and `%USERPROFILE%\.cargo\bin` to PATH for its own process.
It uses four build jobs and disables incremental compilation and debug symbols
to limit memory and disk use. This is an optimized development build with
singleplayer, plugins, and asset hot reloading enabled.

Build without opening a window:

```bat
build-and-play.cmd --build-only
```

After changing dependencies, fetch them online before building offline:

```bat
"%USERPROFILE%\.cargo\bin\cargo.exe" +nightly-2026-06-13-x86_64-pc-windows-gnu fetch --locked --target x86_64-pc-windows-gnu
```

## Git remotes

- `origin`: your GitHub fork. Push personal changes here.
- `upstream`: the official GitHub mirror. Use this when comparing or merging updates.
- `canonical`: the official GitLab repository, retained as a reference.

GitLab and GitHub have different commit IDs because the GitHub mirror rewrites
Git LFS assets into ordinary Git files. Merge updates from the GitHub `upstream`
remote into this branch. Do not merge the GitLab history directly.

AI-assisted changes are permitted in this personal fork. Upstream has its own
contribution policy, preserved in `CONTRIBUTING.md`.
