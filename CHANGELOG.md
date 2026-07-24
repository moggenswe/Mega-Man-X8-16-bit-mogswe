# Changelog — mogswe build

This document exists specifically so this build can be verified safe for **competitive speedrunning**. Every change below is a bug fix. None of them were made to alter gameplay, balance, or timing on purpose — but because this game's source code was lost and had to be recovered by decompiling the compiled game (see "How this codebase came to exist" below), some of these fixes touch things that could plausibly matter to a run. Those are flagged explicitly, with the reasoning, so you can verify them yourself rather than take my word for it.

**If you only read one section, read "Fixes that affect gameplay/timing behavior" below.**

## How this codebase came to exist

The original source for this speedrun fork was lost. This repository was rebuilt by decompiling the compiled game (`Mega Man X8 16-bit ... Speedrun v10.exe`) with [GDRE Tools](https://github.com/GDRETools/gdre_tools), which recovered all 983 GDScript files and the large majority of resources. Decompiling compiled GDScript bytecode back to source is not always lossless — in a few places the decompiler produced a value that doesn't match what the surrounding code clearly intends (see the tween fixes below). Everything in this changelog is either (a) fixing one of those decompiler artifacts, (b) fixing something broken specifically by the export/build process, or (c) fixing a crash. Nothing here is a deliberate gameplay design change.

---

## Fixes that affect gameplay/timing behavior

These are the ones worth your own scrutiny. Everything else in this changelog is audio/visual polish or build-pipeline-only and cannot affect a run (reasoning given in the later sections).

### 1. Boss/special weapons could only be fired once, ever, per level
**Files:** `src/Actors/Player/BossWeapon.gd`, `src/Actors/Player/BossWeapons/ThunderDancer/ThunderDancerWeapon.gd`

**What was broken:** `start_cooldown()` sets `timer = weapon.cooldown`, then starts a tween meant to count `timer` back down to `0` over `weapon.cooldown` seconds. `PrimaryShot.gd` gates whether you can fire a boss weapon again via `is_cooling_down()`, which is simply `return timer > 0`. The decompiled code had the tween's target value as the integer `0` instead of `0.0` — but `timer` is declared as a float (`var timer: = 0.0`). Godot's tween system requires the target value's type to exactly match the property's type; when it doesn't, the tween silently fails to do anything at all (it does not error loudly, does not crash, just never runs). Concretely: **`timer` would never decrease from `weapon.cooldown` back to `0` after firing any boss weapon once** — meaning every one of the 8 unlockable boss weapons could be fired exactly once per level and then never again, permanently, for the rest of that level.

**Why this can't be intentional:** this would make every boss weapon single-use per level, which is not how Mega Man X games work and is not how this game has ever been played/recorded. This is unambiguously a decompiler artifact — restoring `0.0` restores the mechanic to what the surrounding code (and 8 years of the game being played) already assumes exists.

**Fix:** changed the literal `0` to `0.0` in both files (the only two places in the whole codebase that implement `start_cooldown()` — every other boss weapon inherits one of these two).

**What to verify yourself:** fire a boss weapon, wait for its normal cooldown, fire it again. If it works, this fix behaves as intended. Cooldown *duration* itself was never touched — only the mechanism that counts it down.

### 2. Ride Armor hover ability (blue and green) launched straight to the top of the screen instead of hovering
**File:** `src/Actors/Props/RideArmor/HoverJump.gd`

**What was broken:** same root cause as #1. `tween.attribute("current_jump_speed", 0)` decayed `current_jump_speed` from `jump_speed` (120.0) down to `0` to smoothly end the initial launch and transition into a limited hover. `current_jump_speed` is a float; the tween target was the int `0`, so the tween silently failed, `current_jump_speed` stayed pinned at `120.0` forever, and the ability never transitioned out of "launch upward at full speed" for as long as the button was held.

**Reported and confirmed by the user during testing** (before I'd identified the root cause) — this is the one fix in this list that was found through direct play rather than static analysis.

**Fix:** changed `0` to `0.0`. Only the mechanism that ends the launch phase was touched; `hover_time`, `hover_speed`, `jump_speed`, and `upward_time` (all the actual tunable numbers) are untouched.

### 3. Post-boss teleport sequence (at least Manta Ray, CentralWhite) advanced to the next screen ~1 second earlier than designed
**File:** `src/Levels/CentralWhite/teleport_light.gd`

**What was broken:** `activate()` runs a *sequential* (non-parallel) chain: fade to 0.25 alpha → fade to 1.0 alpha over 1 second → call `play_stage_song()` and `teleport_player()` → fade to 0. The "fade to 1.0 over 1 second" step had its target value as the int `1` against a float shader parameter, so — same mechanism as above — that step failed silently. Critically, in Godot's tween system a step that fails to create doesn't just get skipped, it consumes **no time at all** in the sequence (confirmed by direct testing), so the callbacks immediately after it (`play_stage_song`, `teleport_player`) fired about 1 second sooner than the sequence design intended.

**Fix:** changed `1` and `0` to `1.0` and `0.0`. This is the one fix in this changelog that has a concrete, confirmed effect on a specific timing window (a post-boss transition), not just "restores a broken visual."

### 4. Sub-weapon quick-select wheel (right stick) had dead spots — pushing the stick at certain angles selected nothing
**File:** `src/Options/HotSwap.tscn`

**What was broken:** the weapon wheel positions its cursor from the analog stick using two independent axis readings (`cursor.x` from left/right strength, `cursor.y` from up/down strength — see `HotSwap.gd`'s `_physics_process()`), each with a 0.32 deadzone remapped to a 0–40 unit range. This is not a true circular/polar mapping, so a stick pushed at a diagonal angle doesn't reach the same radial distance from center as a stick pushed at a cardinal angle. Each of the 8 weapon icons only registers a selection when the cursor's own hit circle (radius 16) overlaps that icon's hit circle (radius 6) — there is no "nearest icon" fallback, purely `Area2D.area_entered`. Mapped the actual geometry mathematically and confirmed empirically in a live running instance (temporarily sweeping the cursor through all 360° while reading real `Area2D` overlap state): there are exactly 8 dead zones, each ~4–6° wide, sitting right at the boundary between every adjacent pair of icons (skewed toward whichever of the two is farther from center) — pushing the stick into one of these bands selects nothing at all.

**Fix:** increased the weapon icon hit-circle radius from 6 to 13. Re-ran the same 360° sweep after the change: zero dead angles remain, with only a small (~8°) expected overlap band at each boundary where either adjacent weapon can register — a normal, harmless transition zone, not an ambiguity bug.

**Why this belongs here and not in the audio/visual section:** unlike the other items in this changelog, this isn't a decompiler artifact (both values existed exactly like this in the recovered code) — it's a pre-existing precision issue in the wheel's hit-testing geometry. It affects whether a specific analog stick angle successfully selects a specific sub-weapon, which is a real functional outcome (not cosmetic), so it's listed here for visibility even though it's a menu-input fix rather than an in-level timing fix. It does not change stage timing, damage, or movement in any way.

---

## Fixes that are audio/visual only (cannot affect a run)

Same underlying decompiler bug (int literal where a float was needed), same silent-failure/no-op mechanism, but in every case below the affected tween is either (a) the *only* step in its tween (nothing chained after it to shift), (b) run in explicit parallel mode alongside a correctly-typed sibling that already governs the segment's real duration, or (c) purely cosmetic with no callback or gameplay state depending on it. Manually verified case-by-case:

- **Music/audio fade-outs** (volume only, no gameplay state reads these): `src/Title/theme_music.gd`, `src/Options/SimpleMusicPlayer.gd`, `src/StageSelect/music.gd`, `src/Actors/NewStateMachine/audioplayer.gd`, `src/Actors/Enemies/Throwers/Flamethrower.gd`, `src/Levels/Gateway/SigmaFinale.gd`, `src/Actors/NewStateMachine/NewSongPlayer.gd` (found via runtime audit, see below).
- **HUD focus-bar slide/color** when camera focus switches between player/ride-armor: `src/Levels/HUD.gd` — parallel tween, purely a UI element, doesn't drive any camera or gameplay logic itself.
- **Sprite animation playback speed** (visual only, not used for hit timing): `src/Actors/Player/BossWeapons/OpticShield/OpticRadar.gd`, `src/Actors/Bosses/OpticSunflower/CrushTarget.gd`. Both weapons/enemies use a separate, unaffected real `Timer` node for their actual attack-trigger timing.
- **Boss visual repositioning with nothing chained after it:** `src/Actors/Bosses/GiantMechaniloid/Laser.gd` (laser eye slides into position; no callback depends on when this finishes).
- **Enemy dive wind-up dip:** `src/Actors/Enemies/MantaRay/MantaDive.gd` — this one *is* a chained step before the actual dive movement, so in principle the dive could have started ~0.5s sooner in the broken state, similar to fix #3 above. Flagging this explicitly since I can't rule out a small (~0.5s) timing shift to this specific enemy's dive attack the same way I confirmed for #3. If you route through Manta Ray/CentralWhite competitively, this is worth testing directly.

### Charge-up sound didn't speed up to match Hermes Head's charge time reduction
**File:** `Charge.gd` — not a decompiler artifact, sourced from an existing fix proposed upstream: [AlyssonDaPaz/Mega-Man-X8-16-bit#4](https://github.com/AlyssonDaPaz/Mega-Man-X8-16-bit/pull/4).

Equipping Hermes Head sets `charge_time_reduction = 0.45`, which makes the *visual* charge level thresholds (`get_charge_level()`) trigger ~45% faster. The charge-up sound and the max-charge cue, however, always played at their normal recorded speed — so with Hermes Head equipped, the audio no longer matched how quickly the weapon was actually charging (e.g. the "fully charged" visual/mechanical state could be reached well before the sound's own buildup would suggest). Fixed by scaling `pitch_scale` on both the charge-up sound and the max-charge sound by `1.0 / (1.0 - charge_time_reduction)` — with Hermes Head's 0.45 reduction this works out to ≈1.818x speed, matching the mechanical speed-up exactly. No effect without Hermes Head equipped (`charge_time_reduction == 0` keeps `pitch_scale` at the normal `1.0`). Doesn't change `charge_time_reduction` itself, any charge threshold, or any timing — purely brings the audio in line with mechanics that were already there.

## Crash fixes (no gameplay behavior changed at all)

### `src/System/InputManager.gd`
`get_default_key()` compared `event is InputType` where `InputType` could be `null` (whenever a saved keybind had no prior input event recorded). This is invalid in GDScript and produces a recoverable script error in the editor — but the equivalent operation in a compiled release export is a hard native crash (confirmed reproducible: both a fresh export *and the original v10.exe* crashed identically, on this exact save-file condition, with the exact same crash address). Fixed by returning early when the type can't be determined, before the invalid comparison. This only prevents a crash during save-file loading, before any gameplay begins — it does not change what any keybind maps to, or any input handling during play.

## Build/export pipeline fixes (zero code or gameplay changes — packaging only)

The recovered project ran fine from source in the Godot editor from the start. It did **not** work as a standalone exported `.exe` — every single stage's background/tileset silently failed to load, because those are built from Tiled Map Editor (`.tmx`/`.tsx`) files that GDRE could only partially recover (it recovered the compiled cached result, but not the original source file, which no longer exists). Godot's exporter refuses to package a resource whose source file is missing, so every stage's scenery was silently dropped from any exported build — pressing Start would fail to load the stage and fall back to reloading whatever screen was already on screen.

**Fix:** the 86 affected cached resources were copied out of Godot's internal `.import/` cache into plain project files named `<name>_baked.scn` / `<name>_baked.res` (same binary data, just relocated so the exporter treats them as ordinary resources), and every scene reference was repointed to the new location. Verified by force-loading two different stages directly from an exported build (MetalValley/Panda and PitchBlack) — both loaded cleanly with live gameplay running.

This changed zero GDScript logic and zero resource content — it only makes existing resources actually reach the exported package. It cannot affect run timing since it doesn't touch any script, and the resource data itself is byte-identical to before, just at a different file path.

---

## Methodology / how thoroughly this was checked

- Every one of the ~16 individually-listed tween fixes above was found by grepping every `tween_property(...)` call in the codebase and manually inspecting each one's target property's declared type.
- A separate, more common pattern (`TweenController.attribute()` / `add_attribute()`, and two similar helper functions in `Tools.gd` and `AttackAbility.gd`) is used by roughly 250 additional call sites across boss attacks, enemy behavior, and UI. Rather than manually re-typing all ~250, these three helper functions were fixed at the source: they now check the *actual current value* of the property being tweened and coerce the target value to match automatically. This is a value-preserving fix — it never changes a duration, speed, distance, or any other numeric constant, and it is a no-op for every call that was already correctly typed. It can only ever take a tween that was previously completely non-functional and make it behave as originally coded.
- I ran extensive live-gameplay testing (multiple full sessions including boss fights) with this fix instrumented to log every time it actually corrected a mismatch, to find any instances beyond the manually-identified ones. This surfaced exactly one additional case (`NewSongPlayer.gd`, listed above, audio-only).
- I did **not** exhaustively hand-verify the chain/timing structure of all ~250 wrapper-covered call sites individually (this would mean auditing every boss's full attack-pattern script by hand) — I spot-checked several (Vile, GigaboltManowar, Lumine, WeaponGet screen) and confirmed no additional timing-shift cases among those checked, beyond the MantaDive one flagged above. If your community wants that full audit before trusting this build for record-eligible runs, I can continue it — the instrumentation approach used above is straightforward to re-run against a full boss-by-boss playthrough.
