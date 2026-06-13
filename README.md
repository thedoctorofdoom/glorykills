# Glory Kills for Project Brutality

A **Doom Eternal**-inspired add-on for [Project Brutality](https://github.com/pa1nki113r/Project_Brutality) (0.4.1A / master branch). Brings glory kills, the Crucible, Blood Punch, and an Equipment Launcher to PB.

## Features

- **Glory Kills** -- Damage enemies below a health threshold and they'll stagger, highlighted with a glowing shader effect. Move in close and melee to execute them for health, armor, and ammo drops.
- **Crucible** -- An energy sword with up to 3 charges. One-hit kills most enemies with a massive pinata reward. Find Crucible Energy pickups on maps to recharge.
- **Blood Punch** -- A powerful charged melee attack. Every glory kill execution earns Blood Punch tokens; at 5 tokens your Blood Punch is ready.
- **Equipment Launcher** -- Shoulder-mounted Flame Belch and Ice Bomb on cooldown timers, just like Doom Eternal. Flame Belch kills drop armor; Ice Bomb freezes enemies in place.
- **Pinata System** -- Executed enemies explode into health, armor, and ammo pickups that vacuum toward you automatically.

## Requirements

- [UZDoom 4.14.3+](https://zdoom.org/downloads) (the successor to GZDoom)
- [Project Brutality 0.4.1A](https://github.com/pa1nki113r/Project_Brutality) (master branch)

## Installation

1. Download or clone this repository
2. Load it **immediately after** Project Brutality / PB Staging, **before** weapon packs that override PB base weapon files:

```
-file Project_Brutality-PB_Staging.zip
-file glorykills-master.zip
-file PBMonsterPackStagingGKVersion.pk3
-file PBX-Weapons-main.zip
-file PBWP.zip
```

GloryKills uses a thin VFS hook (`BaseWeapon_Melee.zsc` → GK + PB upstream snapshot) so weapon states compile in PB's translation unit (required by UZDoom 4.14+). When PB Staging updates, run `tools/sync_pb_melee_upstream.ps1` to refresh the melee snapshot — GK logic in `BaseWeapon_Glorykill.zsc` stays separate. Weapon packs loaded later must include that GK file in their own `BaseWeapon_Melee` override.

Or drag and drop onto UZDoom with GloryKills loaded second.

## Controls

Bind these keys in **Options > Customize Controls > Glory Kill**:

| Action | Default Bind | Description |
|--------|-------------|-------------|
| Crucible | (unbound) | Hold to ready the Crucible, release to swing |
| Flame Belch | (unbound) | Fire a burst of flames; kills drop armor |
| Ice Bomb | (unbound) | Lob a cryo grenade that freezes enemies |

Glory kills themselves use your normal melee key -- just punch a staggered (glowing) enemy.

## How It Works

1. **Shoot an enemy** until its health drops below its stagger threshold
2. The enemy **freezes and glows orange** (configurable duration, default 4 seconds)
3. **Melee the glowing enemy** to execute it -- you'll get health, armor, and ammo drops
4. Each execution earns **Blood Punch tokens** (5 tokens = Blood Punch ready)
5. Find **Crucible Energy** pickups to charge the Crucible for instant kills

Drop rewards scale with enemy tier -- bigger demons drop more loot.

## Configuration

All settings are accessible in-game via **Options > Glorykill Options**.

### Gameplay

| Setting | Default | Description |
|---------|---------|-------------|
| Glory Kill | On | Master toggle for the entire system |
| Holdable Crucible | On | Hold-to-ready Crucible behavior |
| Protection during Glory Kill | On | Invulnerability while executing |
| Fear during Glory Kill | On | Nearby enemies flee during execution |
| Stun Duration | 4 sec | How long enemies stay staggered (2-12) |
| Hard Mode | Off | Halved health drops, 1-in-3 ammo chance |

### Drops

| Setting | Default | Description |
|---------|---------|-------------|
| Health & Armor Drop | On | Glory kills drop health and armor |
| Additional Bonus Drop | On | Extra tier of bonus pickups |
| Ammo Bonus Drop | On | Glory kills drop ammo |
| Crucible Ammo Bonus | On | Crucible kills drop ammo |
| Bonus Trail Effect | On | Colorful particle trails on pickups |

### Vacuum Collection

| Setting | Default | Description |
|---------|---------|-------------|
| Health & Armor Radius | 0 | Auto-collect radius for health/armor drops |
| Ammo & Grenade Radius | 0 | Auto-collect radius for ammo drops |

Set these above 0 to have pickups fly toward you automatically.

### Equipment Launcher

| Setting | Default | Description |
|---------|---------|-------------|
| Flame Belch Cooldown | 12 sec | Time between Flame Belch uses (10-60) |
| Ice Bomb Cooldown | 35 sec | Time between Ice Bomb uses (10-60) |
| Ammo Consumption | On | Equipment uses PB fuel/rocket ammo |
| Flame Belch Performance Mode | Off | Simplified fire effects for lower-end hardware |

### HUD

| Setting | Default | Description |
|---------|---------|-------------|
| Glory HUD Enable | Off | Show Crucible energy, BP tokens, and equipment status |
| Glory HUD Style | None | Panel style (None / Panel / Eternal) |
| Glory HUD Size | Small | HUD element size |
| Glory HUD X/Y | 0 | Position offset for the HUD overlay |

### Alerts

| Setting | Default | Description |
|---------|---------|-------------|
| Low Health Notification | On | Audio warning at low health |
| Low Health Value | (configurable) | Health threshold for warning |
| Low Armor Notification | On | Audio warning at low armor |
| Low Armor Value | (configurable) | Armor threshold for warning |

## Supported Enemies

Enemies are organized by tier, matching PB's classification:

| Tier | Enemies |
|------|---------|
| T1 -- Grunts | Zombiemen, Shotgunners, Scientists, Chainsaw Zombies |
| T1 -- Imps | Classic, Dark, Nether, Void, Salvage Imps |
| T2 | Pinky Demons, Spectres, Mech Demons |
| T3 | Arachnotrons, Cacodemons, Mancubi, Revenants, Pain Elementals |
| T4 | Hell Knights, Barons, Arch-viles, Summoners |
| Boss | Cyberdemon, Spider Mastermind, Annihilator |

Higher-tier enemies have higher stagger thresholds and drop better loot.

## Console Commands (for testing)

```
give CrucibleEnergy 3     -- Max out Crucible charges
give BPtoken 5            -- Fully charge Blood Punch
summon Crucible            -- Spawn a Crucible Energy pickup
summon PB_Imp1GK           -- Spawn a glory-kill-enabled imp
```

## Credits

- **Glory Kill Mechanics & Pinata Pickup Sound** -- Brutal Doom Black Edition Team
- **Glory Kill Shader** -- D4D Team
- **Crucible Sprite, Sound & Flame Belch Sound** -- D4D Team, EOA Team
- **Crucible Trail** -- Embers of Armageddon
- **Pinata & Ammo Sprites** -- D4D Team, LJG2023
- **Blood Punch Effect** -- EOA Team
- **Low Health Sound** -- D4D Team
- **Item Collecting Mechanics** -- D4D Team
- **Cyberdemon Fatality** -- SgtMarkIV (Brutal Doom)
- **Mastermind Fatality** -- SgtMarkIV (Brutal Doom)
- **Flamethrower Crucible Mod** -- a90doomguy, Tunasz & Officer_D
- **HUD Graphics** -- EOA Team
