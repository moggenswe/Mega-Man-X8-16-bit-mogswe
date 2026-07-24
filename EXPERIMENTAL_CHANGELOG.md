# Experimental branch changelog

This branch (`experimental`) contains fixes that **may affect gameplay/movement timing** and are therefore kept separate from `main`, which is meant to stay safe for competitive speedrunning. Do not merge this into `main` without community review of each item below.

## Fixed

### 1. Charging a weapon (e.g. ThunderDancer) through a door transition silently loses the charge
**File:** `src/Actors/Modules/Forced.gd`

**Root cause:** Walking through a door (or any other "Forced" movement sequence — capsules, certain cutscene repositions) starts the `Forced` ability, which is marked `is_high_priority()`. `BaseAbility.StopAnyConflictingMoves()` force-ends *any* currently-executing ability when a high-priority ability starts, unless that ability explicitly declares `"Nothing"` in its own `conflicting_moves`. `Charge` declares no such exemption, so `Forced` was unconditionally calling `Charge.Interrupt()` → `Charge._Interrupt()`, which does `charged_time = 0`. If you were mid-charge when a door transition began, your accumulated charge was silently wiped — but since raw input reading for `Charge` bypasses `listening_to_inputs` (`Charge.should_always_listen_to_inputs()` returns `true`), the button-held state itself was never lost, so the ability just silently restarted charging from zero without any visible cue. Releasing shortly after (thinking you'd charged for the original duration) produced a much weaker or fully uncharged shot instead.

**Fix:** Overrode `StopAnyConflictingMoves()` specifically in `Forced.gd` to skip ending the `Charge` ability, while leaving all other high-priority interruptions (most importantly `Damage` — getting hit should still, and does still, cancel your charge) completely unchanged. This is scoped to `Forced` only, not a blanket change to `Charge`'s conflict rules.

**What could change for a run:** if you were previously relying on a door transition to "reset" your charge state for some reason (unlikely, but flagging it), that side effect is gone. Otherwise this should only fix the reported bug — charge now correctly survives a door transition and fires/switches at the level you actually built up.

### 2. Icarus armor's max-charge shot (Laser Buster) — sound/visual didn't fire correctly
**File:** `src/Actors/Player/BossWeapons/SqueezeBomb/SqueezeBomb.gd`

**What was broken:** Icarus's level-3 charged shot (`Laser Buster.tscn`) reuses the `SqueezeBomb.gd` script (the same beam-projectile logic as the SqueezeBomb boss weapon — this is intentional reuse, not a mix-up, confirmed by matching node names in the scene). That script's lifecycle only ever starts (`_Setup()` — which plays the sound and the flash animation, and activates damage/movement) when `.initialize(direction)` is called. Boss weapons fire via `instantiate_projectile()`, which does call `.initialize()`. But X's own Buster fires via a *different* path (`Weapon.position_shot()` → `shot.projectile_setup(direction, spawn_point)`), and `SqueezeBomb.gd` overrode `projectile_setup()` as a no-op (`pass`). Net effect: firing Icarus's Laser Buster through the normal charge-and-release flow never actually activated the shot — no sound, no flash, no damage, no cleanup. Confirmed with an isolated test: `active` stayed `false` indefinitely before this fix.

**Fix:** `projectile_setup(_d, _f)` now calls `initialize(_d)` instead of doing nothing. Verified empirically: after the fix, `active` becomes `true`, and both the fire sound and the flash animation correctly trigger within the same frame window.

**What could change for a run:** Icarus's max-charge shot now actually deals damage and consumes its normal travel/lifetime behavior, where before it was inert. If any route currently exploits "Icarus max-charge shot does nothing" (e.g., as a no-op button press for some timing reason), that exploit is gone — but a shot that does nothing at all seems extremely unlikely to be an intentional route element.

## Investigated, not fixed — needs more information

### 3. PitchBlack, last moving elevator: jumping off it only allows a single jump, not the Icarus double-jump
I traced the double-jump gating logic (`ExtraDashJump.gd`) thoroughly:
- Air jumps reset on the `land` signal (`Character.check_for_land()`, based on `is_on_floor()`).
- Air-jump additionally requires `time_since_on_floor > leeway_time` (0.1s) AND `is_in_reach_for_walljump() == 0` — i.e., air-jump is deliberately *disabled* when a nearby wall is detected via raycast, so the game can prioritize wall-jump instead.
- My leading hypothesis: PitchBlack's elevator shafts are narrow, and the wall-proximity raycast used to gate air-jump (`is_in_reach_for_walljump()`) may be detecting the shaft walls as "walljump available" even where an actual wall-jump isn't geometrically possible off this specific elevator, silently blocking the air-jump instead of falling back to it.
- I ruled out one theory: platforms in this elevator chain only `queue_free()` once they're off-screen, which can't happen while a player is actively standing on one (it would still be on-screen, following the camera) — so "the platform disappears out from under you mid-jump" is not the mechanism.

I could not confirm the wall-proximity hypothesis without either directly reproducing it in-game or inspecting the exact tile geometry around that elevator, and I didn't want to guess-fix a wall-jump/air-jump interaction (used by every enemy and boss in the game via the shared ability framework) without being sure. If you can confirm exactly where (top or bottom of the shaft, which direction you're moving) and whether it also happens faintly on the other PitchBlack elevators, that would narrow this down a lot faster than further static code reading.

## New feature: debug menu save state / load state

**Files:** `src/Scripts/GameManager.gd`, `src/HUD/Debugger.gd`, `src/HUD/DebugAndCheats.tscn`

Added `save_state` / `load_state` buttons to the debug menu (only visible with `GameManager.debug_enabled` or when running from the editor). Captures stage, exact position/direction/velocity, health, current weapon + all weapons' ammo, collectibles, all `GlobalVariables` (subtank charges, unlocks, story flags), and the boss RNG seed into a single in-memory slot; loading restores all of it by reloading the stage and repositioning via a synthetic checkpoint.

Two bugs found and fixed after initial testing:
- **Loading right after passing through a door left you stuck in it.** The synthetic checkpoint didn't reference any door, so on reload the door reset to closed while the saved position was already on the other side of it. Fixed by carrying forward the `last_door` of whatever real checkpoint was active at save time, so that door still gets marked as already-passed on load.
- **Loading during a boss fight sent you back to the start of the stage.** `GameManager.start_level()` calls `clear_checkpoint()` as its very first action. The synthetic checkpoint was being assigned *before* calling `start_level()`/`restart_level()`, so it got wiped out immediately whenever the load needed to go through `start_level()` (this happens whenever the saved stage doesn't match the current one at load time — which a boss encounter can trigger). Fixed by assigning the checkpoint *after* triggering the reload instead of before.

**Also added:** save state now captures whether the player is riding a Ride Armor or Bike, and re-mounts them on load. This surfaced that Ride Armor and Bike use two entirely different "Ride" base classes despite the shared naming convention:
- Bike (`RideChaser.tscn` → child node `Riden`, `BikeRiden.gd extends src/Actors/Props/Ride.gd`, the older Ability-based framework): `make_rider(body)` takes the collision body as an argument.
- Ride Armor (`RideArmor.tscn`/`RideArmorNoCannon.tscn` → child node `Ride`, `src/Actors/Props/RideArmor/Ride.gd`, NewAbility-based): `make_rider()` takes no arguments — `rider` must be assigned as a property first, then execution triggered manually via `_on_signal()`.

Restoration branches on which child node exists (`Riden` vs `Ride`) to call the correct one. Verified end-to-end: mounted a Ride Armor, saved (capturing its scene path and health), unmounted and moved away, loaded, and confirmed the player was remounted on a fresh instance with the exact saved health.

This is a debug-only tool, not something that ships active in a real playthrough, so it doesn't need the same speedrun-timing scrutiny as the other items above — noted here for completeness and in case it's ever adapted into something player-facing.
