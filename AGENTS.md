# GloryKills — Project Brutality Add-on

## Project Overview

This is a [UZDoom](https://zdoom.org/downloads) mod add-on for **Project Brutality** (master branch / 0.4.1A release). It adds Doom Eternal-style mechanics to Project Brutality:

- **Glory Kills** — stagger enemies at low health, then execute them for resource drops
- **Crucible** — energy sword with limited charges
- **Blood Punch** — charged melee attack built from glory kill tokens
- **Equipment Launcher** — Flame Belch and Ice Bomb on cooldown timers
- **Pinata System** — health, armor, and ammo drops from executions with vacuum collection

The mod targets **ZScript version 4.14.0** (declared in `ZSCRIPT.zc`) and extends PB's `PB_WeaponBase` class via `extend class`.

---

## Authoritative References

When evaluating or modifying code in this project, consult these resources:

- **ZScript reference** (primary): <https://github.com/zdoom-docs/stable>
- **UZDoom source** (versioned engine context): <https://github.com/UZDoom/UZDoom/tree/4.14.3>
- **DECORATE format specifications**: <https://zdoom.org/w/index.php?title=DECORATE_format_specifications>
- **Action functions**: <https://zdoom.org/w/index.php?title=Action_functions>
- **Classes**: <https://zdoom.org/w/index.php?title=Classes>
- **Actor flags**: <https://zdoom.org/w/index.php?title=Actor_flags>
- **Actor properties**: <https://zdoom.org/w/index.php?title=Actor_properties>
- **Actor states**: <https://zdoom.org/w/index.php?title=Actor_states>
- **DECORATE expressions**: <https://zdoom.org/w/index.php?title=DECORATE_expressions>
- **ACS (Action Code Script)**: <https://zdoom.org/wiki/ACS>

The parent mod this add-on depends on:

- **Project Brutality (master / 0.4.1A)**: <https://github.com/pa1nki113r/Project_Brutality>

---

## Architecture

### Dual-Language Design

This mod uses **both DECORATE and ZScript**. They serve different roles:

- **DECORATE** (`.txt` files included by `DECORATE`): Defines standalone actors — tokens, pickups, highlights, pinata spawners, particle effects, equipment projectiles, and monster DECORATE replacements organized by tier.
- **ZScript** (`.zc`/`.zsc` files included by `ZSCRIPT.zc`): Extends PB's weapon base class (`extend class PB_WeaponBase`) and defines monster GK replacement classes that inherit from PB monster classes.

### Include Chains

```
DECORATE                         ZSCRIPT.zc (Version "4.14.0")
├── GLORYKILL.txt                ├── zscript/Monsters/Imps.zc
├── Crucible.txt                 ├── zscript/Monsters/Sergeants.zc
├── SOULCUBE.txt                 ├── zscript/Monsters/ZombieMen.zc
├── RANDOMAMMO.txt               ├── zscript/Monsters/ZombieScientist.zc
├── ParticleEffect.txt           ├── zscript/Monsters/Cacodemon.zc
├── EquipmentLauncher.txt        ├── zscript/Monsters/Arachnotron.zc
├── BloodPunch.txt               ├── zscript/Monsters/BaronOfHell.zc
├── HardSettings.txt             ├── zscript/Monsters/Commando.zc
├── Monsters/T1-Grunts.txt       ├── zscript/Monsters/HelmetCommando.zc
├── Monsters/T1-Imps.txt         ├── zscript/Monsters/Mancubus.zc
├── Monsters/T2-Pinkies.txt      ├── zscript/GloryKills/GK_EquipmentHandler.zsc
├── Monsters/T3-Arachnos.txt     └── zscript/AmmoBonus.zsc
├── Monsters/T3-Fats.txt
├── Monsters/T3-Floaters.txt
├── Monsters/T3-Revies.txt
├── Monsters/T4-Nobles.txt
├── Monsters/T4-Viles.txt
└── Monsters/Tz-Bosses.txt
```

> The weapon extension files are daisy-chained: `zscript/Weapons/BaseWeapon_Melee.zsc` includes `zscript/GloryKills/BaseWeapon_Glorykill.zsc` at line 1. `BaseWeapon_Melee.zsc` is NOT included by `ZSCRIPT.zc` — it overrides PB's own `BaseWeapon_Melee.zsc` via the VFS and is loaded by PB's include chain. `BaseWeapon_Functions.zsc` was **deleted** — PB's own version is loaded from PB's archive. `GK_EquipmentHandler.zsc` IS directly included by `ZSCRIPT.zc`.

---

## File Reference

### Root Configuration Files

| File | Purpose |
|------|---------|
| `ZSCRIPT.zc` | Main ZScript entry point; declares version and includes |
| `DECORATE` | Main DECORATE entry point; includes all `.txt` actor files |
| `CVARINFO` | Declares 30 server CVars controlling all mod features |
| `KEYCONF.txt` | Key bindings: Crucible (`+glorysaw`), Flame Belch, Ice Bomb |
| `SNDINFO.GK` | Sound definitions for all mod sounds |
| `menudef.addon` | Options menu: "Glorykill Options" submenu added to OptionsMenu |
| `LOADACS.txt` | Lists 5 ACS scripts to load at startup |
| `GLDEFS` | Hardware shader bindings for glory kill highlight effect |
| `language.enu` | Localized pickup messages |
| `Textures.FX.txt` | Texture composite definitions for visual effects |
| `Credits.txt` | Attribution for borrowed assets and code |

### ZScript Files (`zscript/`)

| File | Role |
|------|------|
| `GloryKills/BaseWeapon_Glorykill.zsc` | `extend class PB_WeaponBase` — glory kill execution logic (`PB_ExecuteGK()`), Crucible weapon states, Blood Punch states, Equipment Launcher states (Flame Belch / Ice Bomb), QuickMelee override |
| `GloryKills/GK_EquipmentHandler.zsc` | `EventHandler` — routes inventory token signals to weapon states each tick. Uses a `bool[] prevGloryMelee` array for rising-edge detection of `DoGloryMelee` (Crucible key press) and routes to `GloryMelee` state; detects `DoShoulderCannon` and routes to `FireShoulderCannon`. Guard checks: skips if player is dead (`health <= 0`), has `CantDoAction`, or weapon's `executingEnemy` is true |
| `Weapons/BaseWeapon_Melee.zsc` | `extend class PB_WeaponBase` — melee combat system: knife attacks, kicks (standard/air/slide/drop), barrel interactions, bloody knife overlays. Includes `GloryKills/BaseWeapon_Glorykill.zsc`. Overrides PB's own `BaseWeapon_Melee.zsc` via VFS |
| `Weapons/BaseWeapon_Functions.zsc` | **DELETED** — was a stale copy of PB's own file; shipping it in the addon overrode PB's updated version via the VFS, breaking PB features. PB's own version is loaded from PB's archive. Do NOT re-add this file. |
| `Monsters/*.zc` | Monster GK replacement classes (see Monster Pattern below) |
| `Monsters/Unused/` | Unused/WIP monster definitions (PinkyDemon, PB_Elemental) |
| `AmmoBonus.zsc` | ZScript inventory classes for ammo bonus pickups (Cartridge, Clip, Shell, Rocket, Cell, Grenade, Gas, StunGrenade) using `TryPickup` override |

### DECORATE Actor Files (root `.txt`)

| File | Contents |
|------|----------|
| `GLORYKILL.txt` | Core system: `HighlightBase` and 12 monster-specific highlight actors, `FinisherToken`, `PainSoundToken`, `GloryKillPuff` |
| `Crucible.txt` | `Crucible` pickup, `CrucibleEnergy` token, `CruciblePuff`, `CrucibleBladeWave`, pinata spawner tiers (`GlorySawPinataLow/Med/Hight/Max`) |
| `SOULCUBE.txt` | `HealthPinata`/`ArmorPinata` base classes with vacuum mechanics, L0-L5 tier variants, `GloryLowPinataSpawn` through `GloryHightPinataSpawn2` spawner actors with hard mode variants |
| `RANDOMAMMO.txt` | `RandomDice` weighted ammo spawners, ammo pinata actors with vacuum mechanics |
| `EquipmentLauncher.txt` | Flame Belch projectiles (`SCFireMissile`, `SCFireMissileSimple`), Ice Bomb (`SC_CryoGrenade`), flame/ice field effects, inventory tokens (`FlameBelchReady`, `IceBombReady`, `DoFlameBelch`, `DoIceBomb`) |
| `BloodPunch.txt` | `BPtoken`, `BloodPunchPuff`, `BloodpunchWave`, `BPImpactPuff`, `BloodPunchArmor` |
| `ParticleEffect.txt` | Colored particle trail actors (`BluePinataParticles`, `GreenPinataParticles`, `RedPinataParticles`, `YellowPinataParticles`, `PinkPinataParticles`, `GoldPinataParticles`) |
| `HardSettings.txt` | Hard-mode (`be_GKHard`) variants of pinata spawners and random dice with reduced drop rates |

### DECORATE Monster Files (`Monsters/`)

Files are organized by tier matching PB's enemy classification:

| File | Tier | Monsters |
|------|------|----------|
| `T1-Grunts.txt` | T1 | Zombiemen, Shotgunners, Scientists, Chainsaw zombies |
| `T1-Imps.txt` | T1 | All imp variants (classic, dark, nether, void, salvage) |
| `T2-Pinkies.txt` | T2 | Pinky demons, spectres, mech demons |
| `T3-Arachnos.txt` | T3 | Arachnotrons, elite/infernal variants |
| `T3-Fats.txt` | T3 | Mancubi, volcabus, daedabus |
| `T3-Floaters.txt` | T3 | Cacodemons, pain elementals, afrits |
| `T3-Revies.txt` | T3 | Revenants, beam rev, heavy rev, draugr |
| `T4-Nobles.txt` | T4 | Hell Knights, Barons, Belphegor, Infernus, Cyber variants |
| `T4-Viles.txt` | T4 | Arch-viles, ice vile, summoners |
| `Tz-Bosses.txt` | Boss | Cyberdemon, Mastermind, Annihilator |

### ACS Scripts (`Source/`)

| File | Script Numbers | Purpose |
|------|---------------|---------|
| `GloryChain.acs` | 6000, 6001 | Glory melee activation/deactivation (bound to `+glorysaw` alias) |
| `GloryHUD.acs` | — | HUD overlay drawing Crucible energy, BP tokens, equipment status |
| `BloodPunch.acs` | — | Monitors BP token count, plays ready sound at 5 tokens |
| `EquipmentLanucher.acs` | 6003, 6005 | Equipment launcher cooldown timers and activation. Grants `FlameBelchReady` and `IceBombReady` at spawn so equipment is available immediately |
| `lowhealth.acs` | — | Low health/armor warning sound system |

### Shader

| File | Purpose |
|------|---------|
| `Shaders/glorykill.shader` | GLSL fragment shader for stagger highlight effect — animated orange/red scan-line glow applied to monster sprites via `GLDEFS` |

---

## Core Patterns

### Monster GK Replacement Pattern (ZScript)

Every supported monster follows this pattern:

```zscript
Class PB_[Monster]GK : PB_[Monster] Replaces PB_[Monster]
{
    Default { WoundHealth [threshold]; }
    States
    {
        Wound:        // Entry point when health drops below WoundHealth
                      // Spawns highlight actor, gives FinisherToken
                      // Branches to Stagger or See based on CVars
        Stagger:      // Chooses highlight sprite or default, goes to StagLooper
        StagLooper:   // Loops checking FinisherToken; plays pain sounds
        Death.Execution:  // Glory kill death — grants BPtoken, spawns pinata
        Death.Crucible:   // Crucible kill — spawns saw pinata tier
        Death.BloodPunch: // Blood Punch kill — gives BloodPunchKilled token
        Death.GloryFire:  // Flame Belch kill — spawns flame pinata
        Pain.GloryFire:   // Flame Belch pain — chance to spawn flame pinata
    }
}
```

### Monster GK Replacement Pattern (DECORATE)

DECORATE monsters in `Monsters/*.txt` follow a similar pattern but use DECORATE syntax:

```
Actor PB_[Variant]GK : PB_[Variant] Replaces PB_[Variant]
{
    WoundHealth [value]
    States
    {
        Wound: ...
        Stagger: ...
        Death.Execution: ...
        Death.Crucible: ...
        Death.BloodPunch: ...
        Death.GloryFire: ...
    }
}
```

### Highlight System

`HighlightBase` (DECORATE in `GLORYKILL.txt`) is the stagger visual indicator:

- Spawned with `SXF_SETMASTER` to track the staggered monster
- Copies the master's sprite frame each tick via `A_CopySpriteFrame`
- Uses additive rendering with orange translation for the glow effect
- Has a hardware shader applied via `GLDEFS` for scan-line animation
- Counts ticks against `be_StaggerLenght * 35` (tics); when expired, heals the monster and removes `FinisherToken`
- Each monster type has its own highlight subclass with appropriate `Scale` and `user_RecoverToAmount`

### Pinata Reward Tiers

Pinata spawners scale with monster tier:

| Spawner | Used By | Drops |
|---------|---------|-------|
| `GloryLowPinataSpawn` | T1 grunts, imps | 5x HealthL0 + optional ammo |
| `GloryLowPinataSpawn2` | T1 variants | 5x HealthL0 + 2x HealthL1 + optional ammo |
| `GloryMedPinataSpawn` | T2/T3 monsters | 5x HealthL0 + 5x ArmorL0 + optional ammo |
| `GloryMedPinataSpawn2` | T3 variants | Med + 3x HealthL1 + 3x ArmorL1 |
| `GloryHightPinataSpawn` | T4 nobles | 10x HealthL0 + 10x ArmorL0 + ammo + bonus |
| `GloryHightPinataSpawn2` | T4 variants | Hight + 5x HealthL1 + 5x ArmorL1 |
| `GlorySawPinataLow/Med/Hight/Max` | Crucible kills | Scaled by monster tier |
| `FlamePinataSpawn` | Flame Belch kills | Armor drops |

All spawners check `be_GKHard` for reduced drops and `be_AmmoBonus`/`be_AdditionalBonus` for optional extra drops.

### Vacuum Pickup Mechanics

All pinata pickups (`HealthPinata`, `ArmorPinata`, ammo pinatas) share vacuum collection:

1. After spawn delay (`DelayVacuum`), scan for nearby `PlayerPawn` via `A_CheckProximity`
2. Set tracer to player, face tracer with `A_FaceTracer`
3. Accelerate toward player with `A_ChangeVelocity` at `PSpeed`
4. Warp to player when within `sv_bonusrange` radius
5. Fade out after lifetime expires (`user_timer`)

---

## Key CVars

All CVars are `server`-scoped. Key ones for gameplay behavior:

| CVar | Type | Default | Controls |
|------|------|---------|----------|
| `be_ExecutionsON` | bool | true | Master toggle for glory kills |
| `be_ExecutionHighlight` | bool | true | Stagger highlight visibility |
| `be_MonsterStagger` | bool | true | Whether monsters freeze during stagger |
| `be_StaggerLenght` | int | 4 | Stagger duration in seconds (2-12) |
| `be_GKHard` | bool | false | Hard mode: halved health drops, 1/3 ammo chance |
| `be_GKBonus` | bool | true | Health/armor drops from glory kills |
| `be_AdditionalBonus` | bool | true | Extra tier of drops |
| `be_AmmoBonus` | bool | true | Ammo drops from glory kills |
| `be_GSAmmoBonus` | bool | true | Ammo drops from Crucible kills |
| `be_Protection` | bool | true | Invulnerability during execution |
| `be_Fear` | bool | true | Fear effect during execution |
| `sv_bonusrange` | int | 0 | Health/armor vacuum radius |
| `sv_ammorange` | int | 0 | Ammo vacuum radius |
| `sv_Flamebelch_Cool` | int | 12 | Flame Belch cooldown (seconds) |
| `sv_Icebomb_Cool` | int | 35 | Ice Bomb cooldown (seconds) |
| `be_UseELammo` | bool | true | Equipment Launcher consumes ammo |
| `be_fuelhud` | bool | false | Glory HUD visibility |
| `be_LowHealthAlert` | bool | true | Low health warning sounds |
| `be_LowArmorAlert` | bool | true | Low armor warning sounds |

---

## Key Inventory Tokens

These tokens drive state machines and communication between actors:

| Token | Max | Purpose |
|-------|-----|---------|
| `FinisherToken` | 1 | On monster: marks as executable by melee |
| `PainSoundToken` | 1 | On monster: triggers pain sound during stagger |
| `DoGloryMelee` | 1 | On player: activates glory melee mode (Crucible key held) |
| `CrucibleEnergy` | 3 | On player: Crucible charges |
| `BPtoken` | 5 | On player: Blood Punch charges (5 = ready) |
| `BloodPunchKilled` | 1 | On player: Blood Punch connected with a target |
| `FlameBelchReady` | 1 | On player: Flame Belch off cooldown |
| `IceBombReady` | 1 | On player: Ice Bomb off cooldown |
| `DoFlameBelch` | 1 | On player: Flame Belch activation requested |
| `DoIceBomb` | 1 | On player: Ice Bomb activation requested |
| `DoShoulderCannon` | 1 | On player: Equipment launcher activation |

---

## Key Damage Types

Custom damage types that trigger specific death states on GK monsters:

| DamageType | Source | Death State |
|------------|--------|-------------|
| `GloryKill` | `GloryKillPuff` | `Death.Execution` |
| `Crucible` | `CruciblePuff` | `Death.Crucible` |
| `BloodPunch` | `BloodPunchPuff` / `BPImpactPuff` | `Death.BloodPunch` |
| `GloryFire` | Flame Belch projectiles | `Death.GloryFire` / `Pain.GloryFire` |
| `Execution` | `A_Die("Execution")` in `PB_ExecuteGK()` | `Death.Execution` |

---

## Editing Guidelines

### Adding a New Monster

1. **DECORATE** (`Monsters/T[tier]-[category].txt`): Create `Actor PB_[Name]GK : PB_[Name] Replaces PB_[Name]` with `WoundHealth`, `Wound`, `Stagger`, `StagLooper`, and all `Death.*` states. Follow existing patterns in the same tier file.
2. **ZScript** (`zscript/Monsters/[Name].zc`): If the monster needs ZScript-level behavior, create a class file and add `#Include` to `ZSCRIPT.zc`.
3. **Highlight** (`GLORYKILL.txt`): Create a `[Name]Highlight : HighlightBase` with appropriate `Scale` and `user_RecoverToAmount`.
4. **Shader bindings** (`GLDEFS`): Add `hardwareshader sprite` entries for the stagger sprite name (8 rotations).
5. **Include** in `DECORATE` if it's a new tier file.

### Modifying Weapon Behavior

All weapon extensions are in `zscript/Weapons/` using `extend class PB_WeaponBase`. The state labels `QuickMelee`, `PerformExecution`, `GloryMelee`, `BloodPunch`, `Crucible`, `FireShoulderCannon` are the key entry points. Weapon states flow back to `GoingToReady` / `GoingToReady2` to return to normal weapon operation.

### Adding New CVars

1. Declare in `CVARINFO` with appropriate scope (`server`) and type
2. Add menu control in `menudef.addon` under the `Glorykills` OptionMenu
3. Check via `GetCvar("cvar_name")` in DECORATE or `CVar.FindCVar` in ZScript

### ACS Script Numbers

Scripts 6000-6005 are used. Avoid conflicts with PB's own ACS scripts. The aliases in `KEYCONF.txt` map key binds to `puke` calls targeting these script numbers.

---

## Compatibility Notes

This add-on targets **PB 0.4.1A (master branch)**. It was originally developed against PB_Staging and ported to the public release. Key compatibility points:

- `PB_WeaponBase` and all helper functions (`PB_Execute`, `PB_SetUsingMelee`, `PB_SetPlayerExecutionProperties`, `PB_SetReloading`, etc.) are present and compatible in 0.4.1A
- `PB_FragGrenade` (now a ZScript class in PB's `SuperGL.zs`) remains compatible as a parent for `SC_CryoGrenade`
- `FlamethrowerMissileNew` (in PB's `FlamerStuff.zsc`) remains compatible as a parent for `SCFireMissile`
- `PB_Fuel`, `PB_RocketAmmo` ammo classes are present in 0.4.1A
- The VFS override mechanism (addon's `BaseWeapon_Melee.zsc` replaces PB's version) works correctly with PB 0.4.1A's include chain
- `BaseWeapon_Functions.zsc` must **not** be shipped — PB 0.4.1A's own version is loaded from PB's archive. Overriding it broke PB features.

---

## Known Issues and Quirks

- `BaseWeapon_Melee.zsc` contains test actors at the bottom (`GayImp1`-`GayImp4` with 10000 health and colored blood) — these are debug/test classes
- `BaseWeapon_Functions.zsc` was deleted — it was a stale copy of PB's own file that overrode PB's updated version via the VFS when loaded after PB. Never ship unmodified PB files in the addon; they will silently replace PB's versions and cause breakage when PB updates
- `EquipmentLanucher.acs` has a typo in the filename ("Lanucher" vs "Launcher")
- Backup files exist in `Monsters/` (`*_Backup.txt`) — these are not included by `DECORATE` and should be ignored
- Unused monster definitions exist in `zscript/Monsters/Unused/`
- The `be_StaggerLenght` CVar has a typo ("Lenght" vs "Length") — changing it would break saved configs
- Some ZScript monsters may still have `Death.Execution` states that use only invisible `TNT1` frames with `Stop` instead of visible sprite frames with `Goto Super::Death.SSG` — these cause the monster to vanish on glory kill. `PB_Imp1GK` was fixed; see plan `fix_imp1_gk_disappear` for the pattern. Remaining candidates: `PB_CacodemonGK`, `PB_HelmetZombiemanGK`, `PB_PistolZombieman1GK`, `PB_PistolZombieman2GK`
