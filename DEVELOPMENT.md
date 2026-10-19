# Developing Brandon's Veloren fork

This is the development reference for future sessions working on this personal
game. Start with the requested change, inspect its current implementation, and
use the existing Windows build setup.

## Find the right checkout

On Brandon's PC the game source is:

```text
C:\Users\Brandon\Documents\ChatGPT\Cubeworld\veloren
```

The surrounding `Cubeworld` directory has a separate `.git`; the game lives in
the nested repository. Check the working directory and current changes first:

```powershell
Set-Location 'C:\Users\Brandon\Documents\ChatGPT\Cubeworld\veloren'
git rev-parse --show-toplevel
git status --short
git branch --show-current
git remote -v
```

The personal repository is [Bklein19/veloren](https://github.com/Bklein19/veloren).
The playable branch is `codex/personal-game`. `origin` points to that fork;
`upstream` points to the official GitHub mirror. `canonical` points to GitLab for
reference. GitHub rewrites LFS assets into regular files, so its commit history
differs from GitLab. Merge updates from the GitHub `upstream` remote when needed.

## Build and play

From PowerShell in the game repository:

```powershell
.\build-and-play.cmd --build-only
.\build-and-play.cmd
```

The first command compiles without launching. The second builds and launches.
An unchanged build reuses the cache. The desktop **Veloren** shortcut runs the
same launcher. It never downloads game updates or pulls Git changes.

The launcher uses:

| Setting | Working value |
| --- | --- |
| Rust toolchain | `nightly-2026-06-13-x86_64-pc-windows-gnu` |
| Compilation target | `x86_64-pc-windows-gnu` |
| Binary | `veloren-voxygen` |
| Cargo features | `--no-default-features --features default-publish,hot-reloading,shaderc-from-source` |
| Dependency mode | `--locked --offline` |
| Build jobs | `4` |
| Environment | `CARGO_INCREMENTAL=0`, `CARGO_PROFILE_DEV_DEBUG=0`, `CMAKE_GENERATOR=Ninja`, `CMAKE_BUILD_PARALLEL_LEVEL=4` |
| Assets | This checkout's `assets/` |
| User data | This checkout's `userdata/` |

Rust is under `%USERPROFILE%\.cargo\bin`. The launcher adds native tools from
`%USERPROFILE%\.codex\tools\veloren` to its process PATH:

- `mingw64\bin`, WinLibs GCC and its runtime DLLs.
- `cmake-3.31.8-windows-x86_64\bin`.
- `ninja`.

`VELOREN_TOOLS` can override that native tools root. Read the launcher for the
exact command before running Cargo manually. MSVC is not part of this setup.
Launching the executable directly without the launcher's PATH can miss the GNU
runtime DLLs.

The executable is `target\x86_64-pc-windows-gnu\debug\veloren-voxygen.exe`.
Before replacing it, check whether this source-built game is running:

```powershell
Get-Process -Name veloren-voxygen -ErrorAction SilentlyContinue |
    Select-Object Id, Path, MainWindowTitle
```

Quit normally to save the world before a rebuild needs to replace the running
executable. Documentation edits need no restart or compilation. Rust edits need
a rebuild; some asset types support hot reloading in this build.

The initial source build took about 26 minutes on this PC. A shared movement
change later took about 6 minutes to rebuild the game. Shared Rust changes can
recompile the client, server, and world code. Let a progressing build finish;
preserve `target/` and the Cargo caches during ordinary work.

Singleplayer and cached builds work offline. Adding dependencies or updating the
lockfile may require a network fetch. See [README-FORK.md](README-FORK.md) for
that command and the installed tool versions.

## Locate the implementation

| Change | Start here |
| --- | --- |
| Movement, gliding, abilities, character states | `common/src/states/` |
| Shared ECS components and controller inputs | `common/src/comp/` |
| Physics, forces, collision, simulation systems | `common/systems/src/`, especially `phys/` |
| Keyboard actions and held keys | `voxygen/src/game_input.rs`, `voxygen/src/key_state.rs` |
| Default keyboard and controller bindings | `voxygen/src/settings/control.rs`, `voxygen/src/settings/controller.rs` |
| Input processing and client movement | `voxygen/src/session/mod.rs` |
| Menus, HUD, settings | `voxygen/src/hud/`, `voxygen/src/menu/`, `voxygen/src/settings/` |
| Figures and voxel model loading | `voxygen/src/scene/figure/` |
| Particle effects and graphics | `voxygen/src/scene/particle.rs`, `voxygen/src/render/`, `assets/voxygen/shaders/` |
| Sound event mapping and sound definitions | `voxygen/src/audio/sfx/`, `assets/voxygen/audio/sfx.ron` |
| NPC AI and server behavior | `server/agent/src/`, `server/src/`, `rtsim/src/` |
| World generation | `world/src/` |
| Item and ability data, crafting, loot | `assets/common/items/`, `assets/common/abilities/`, `assets/common/crafting/`, `assets/common/loot_tables/` |
| Models, textures, sound files, English text | `assets/voxygen/voxel/`, `assets/voxygen/texture/`, `assets/voxygen/audio/`, `assets/voxygen/i18n/en/` |

Use `rg` to follow an existing comparable feature through code and assets. An
input-driven ability usually needs both client input wiring and shared gameplay
logic. Singleplayer also runs a server, so implement authoritative movement in
the shared state or systems rather than only changing the rendered character.

For a new input, check the `GameInput` enum, defaults for keyboard and controller,
held-key state, session handling, English localization, and shared controller
data. Update exhaustive matches. Shared keys can also trigger another action;
check those interactions, as Shift originally also toggled sneak.

## Add or change assets

Trace an existing item of the same type before adding a new one. Asset IDs
generally use dotted paths without extensions. For example,
`common.items.glider.basic_white` identifies
`assets/common/items/glider/basic_white.ron`.

A glider illustrates the separate references:

- Item definition: `assets/common/items/glider/basic_white.ron`.
- Voxel model: `assets/voxygen/voxel/glider/basic_white.vox`.
- Equipped model and offsets: `assets/voxygen/voxel/humanoid_glider_manifest.ron`.
- Inventory image: `assets/voxygen/item_image_manifest.ron`.
- Item text mapping: `assets/common/item_i18n_manifest.ron`.
- English item text: `assets/voxygen/i18n/en/item/armor/other.ftl`.

For new items, follow the relevant recipe, loot, loadout, or spawning references
so the item is obtainable. A model file alone does not register an item. Keep
existing asset formats and record third-party attribution when applicable.
Verify that referenced assets load and appear at the intended size and offsets.

## Validate changes

Run checks that exercise the behavior being changed. Documentation edits need
link and whitespace checks. For game code, run focused tests where useful,
format the changed Rust files, and build the actual game with the launcher.
For movement changes, test sustained behavior and different tick rates.

Shared-system tests have a helper that sets the same tools and memory settings
as the launcher:

```powershell
.\test-gameplay.cmd
.\test-gameplay.cmd rocket_glider_tests
```

This runs the `veloren-common-systems` library tests. Other crates need their own
package selection and applicable features. Check the test count when using a
filter. Use the helper as the working
environment and command reference. The pinned nightly's `-Z panic-abort-tests`
and `--profile dev` support this project's `panic = "abort"` development profile.
Changing test profiles or feature sets may compile additional dependencies.

To check only changed Rust files, including staged files:

```powershell
$changedRust = @(git -c core.quotepath=false diff HEAD --name-only --diff-filter=ACMR -- '*.rs')
if ($changedRust.Count -gt 0) {
    & "$env:USERPROFILE\.cargo\bin\rustfmt.exe" `
        +nightly-2026-06-13-x86_64-pc-windows-gnu `
        --edition 2024 --check --config skip_children=true @changedRust
}
git diff --check
git diff --cached --check
```

Add new, untracked Rust paths explicitly or stage them before this check. Remove
`--check` to format the selected files. Avoid unrelated formatting across the
whole workspace.

For a runtime check, launch through the shortcut or launcher and verify the
process path points into this checkout. Logs are under
`userdata/voxygen/logs/`. Use the newest log and relevant errors rather than
dumping old logs. A first world generation can take time after the window opens.
Report automated checks and actual gameplay observations separately.

## Current custom features

### Unlimited rocket glider

Added in commit `6ab6d8db0f`. Open the glider with Ctrl. Tap Shift for a burst or
hold Shift for continuous thrust. Look upward to climb; release Shift for normal
gliding. It supports ground takeoff and has no fuel cost, stamina drain, or
cooldown. The control is named **Glider Rocket Boost**. Flames and engine sound
reuse existing effects.

The implementation crosses these files:

- `common/src/states/glide.rs`: `rocket_boost_velocity`, the `ROCKET_SPEED`,
  `ROCKET_RESPONSE`, and `ROCKET_TAKEOFF_SPEED` constants, and `Boost::Rocket`.
- `common/src/states/glide_wield.rs`: transition into powered flight from ground.
- `common/src/comp/controller.rs`: `ControllerInputs.glider_boost` and input updates.
- `voxygen/src/game_input.rs`, `key_state.rs`, `settings/control.rs`,
  `settings/controller.rs`, and `session/mod.rs`: action, binding, held input,
  and the shared Shift/sneak interaction.
- `assets/voxygen/i18n/en/gameinput.ftl`: control label.
- `voxygen/src/scene/particle.rs` and
  `voxygen/src/audio/sfx/event_mapper/movement/mod.rs`: engine effects.
- `common/systems/src/phys/mod.rs`: `rocket_glider_tests`, exercising real drag
  and gravity for a full simulated minute at 30, 60, and 144 ticks per second,
  plus takeoff without a jump.

Keep the held control separate from the previous tick's visual boost marker so
releasing Shift stops rocket thrust. Thrust should stay bounded as it approaches
the target speed. Normal gliding resumes on release, and water or an unequipped
glider still ends flight.

## Preserve local data and keep the guide current

This checkout's `userdata/` contains `singleplayer_worlds/` and `voxygen/`,
including settings, profile, logs, and saves. It and `target/` are Git-ignored.
The original downloaded installation remains at
`C:\Users\Brandon\AppData\Local\Programs\Veloren-Portable\game` with separate
user data. Keep those copies separate when editing or testing.

Preserve unrelated working changes and inspect the diff before committing.
Follow the user's requested Git workflow; check the destination before pushing.
Retain the personal-fork scope at the top of `CONTRIBUTING.md` and the existing
license notices.

Update this guide when build commands, tool locations, or custom behavior
change. The Codex skill source is in
`tools/codex-skills/veloren-fork-development/`. Its installed copy on this PC is
`C:\Users\Brandon\.codex\skills\veloren-fork-development\`. When changing the
skill itself, update the versioned source and refresh that installed copy.
The skill reads this guide on each use so gameplay details have one maintained
reference.
