# ModWorkshop page copy — AI Suite

Everything below is written for the public page. The "Description" block is the
part to paste into the description field; the field list above it is for the
page form.

## Page fields

- **Name:** AI Suite
- **Short description:** LIES + Iter + Keepers + Monkeepers for PAYDAY 2 248.2
  x64, bundled and tested as one stack — with Keepers' required dependencies in
  a second download.
- **Category:** BLT → Gameplay Changing
- **Tags:** Lua, Gameplay Changing, Bugfix
- **Version:** 2026.11.07.1
- **Dependencies (required):** SuperBLT (64-bit)
- **Dependencies (recommended):** Useful Bots 2.6.3
  (`https://modworkshop.net/mod/31221`) + HopLib
- **Dependencies (optional):** The Fixes (`https://modworkshop.net/mod/23732`)
- **Thumbnail:** `art/ai-suite-thumbnail.png`
- **Downloads (both files on this page):**
  - `AI-Suite-2026.11.07.1.zip` — the four AI mods (4 folders)
  - `AI-Suite-Dependencies-2026.11.07.1.zip` — Keepers' requirements (3 folders)

## Description (paste this)

**One page, two downloads, one tested stack.** AI Suite packages the PAYDAY 2
248.2 x64 AI setup: **LIES**, **Iter**, **Keepers** and **Monkeepers** — forks we
maintain, tested together — plus a second archive with the three upstream
packages **Keepers requires**: **GoonMod's Custom Waypoints**, **No Duplicated
Bullets** and **Simple Mod Updater**.

Each mod keeps its own folder, settings page, changelog and update path. Nothing
is merged or rewritten.

### Download 1 — the AI mods

**LIES 8.57.33 — enemy AI** · [source and details](https://github.com/met94/Little-Intelligence-Enhancements-x64)

Cops detect you more plausibly, lose track of you, evaluate cover against the
actual threat, aim and suppress with more variation, and coordinate pushes as
squads instead of trickling in one by one. Includes fixes for special units
(shields, tasers, tanks, phalanx) and optional "Spicy Tactics" spawn pressure
(off by default). Every part is tunable in its own menu.

**Iter 205.3 — navigation** · [source and details](https://github.com/met94/payday2-mod-Iter)

Fixes how NPCs move between places. Paths are streamlined and cached, ladders,
doors and vaults are queued instead of dogpiled, units can be sent directly to a
position, and their path is extended ahead while they walk. Adds per-level nav
fixes for maps whose nav data broke after U247.

**Keepers 239.3 — bot orders** · [source and details](https://github.com/met94/payday2-mod-Keepers)

Command your AI teammates and jokers: stationary, use cover, patrol, follow and
hold; precise positioning via waypoints; sending bots to interact with objects
or carry bags; revive assistance; custom joker names and health bars; shout
filtering so marking cops does not reassign your bots.

**Monkeepers 87.4 — bot bag logistics** · [source and details](https://github.com/met94/payday2-mod-Monkeepers)

Your bots pick up, carry and drop loot bags like players. It learns routes from
where you take a bag to where it lands, applies them to the bags around that
spot, and expires them on its own. Bots catch thrown bags, use bag-capable
ziplines and pick bags off shelves. Requires Keepers.

### Download 2 — dependencies (required by Keepers)

**Simple Mod Updater 34** · **GoonMod's Custom Waypoints 50** · **No Duplicated
Bullets 10**

These are the original authors' packages, unmodified. Keepers needs the
waypoints for its positioning orders and the bullet fix for consistent
client-side damage; Simple Mod Updater is the updater those two use, so it comes
along to keep them current from the original z77 feed. If you already have all
three installed and updated, you can skip this archive.

### How our forks differ from the originals

All four AI mods are forks of existing projects, maintained here for PAYDAY 2
248.2 x64. The upstream design is kept; what follows is what we changed.

**LIES** — fork of fugsystem's 8.57 (33 fork patch releases)
- 248.2 x64 (Diesel 3) port: nav-v6 door handling, updated engine calls, its own
  Lua cover search, rebuilt aim/attention paths.
- Crash fixes upstream does not have: the taser settled-facing `u_key` crash
  (8.57.31), a stale nav-tracker crash, a missing-logic exit crash.
- Reaction Level reworked: one hold per acquisition instead of a continuous
  delay, plus a new HIGH (0.5 s) setting, verified with in-game counters.
- Door-watching measurements, suppression-alarm fix and group-AI repairs ported
  to 248.2.

**Iter** — fork of TdlQ's r205 (maintenance by BangL)
- The nav core is reimplemented on the 248.2 v6 nav data; upstream r201-r205 is
  adopted where it applies.
- 21 per-level nav-patch blocks fixed for U247+ data (Branch Bank, Firestarter
  day 1, Gallery/Framing Frame day 1, Met).
- Queue and reservation fixes: dead-holder release, stale live-holder sweep,
  wait-stamp leak, dead-nav-link stall, cache expiry.
- Coarse-search cache correctness, path extender, direct-to-pos and an optional
  watch digest for troubleshooting.

**Keepers** — fork of TdlQ's r239 (r237-r239 maintenance by BangL)
- 248.2 fixes: `PlayerStandard._get_interaction_target` forwards `secondary`
  (U240.3), bot bag pickups use `sync_carry_interacted` (U241).
- Built to compose with LIES: wrappers capture the function that is current at
  load time, the `kpr_done` completion path, and a chained
  `chk_action_forbidden` so LIES' hold rule still runs.
- Hard dependencies enforced through SuperBLT, plus a pre-hook `Keepers` global
  so other mods' load-time checks see it before hooks run.

**Monkeepers** — fork of TdlQ's r87
- 248.2 fixes: person-and-bag ziplines (`"both"`) are bag-capable, vehicle
  dropzone filters mirror 248.2 loot rules, shelf-carry activation fixed.
- Hard Keepers dependency; retired its own team-idle override in favour of the
  suite's LIES guard.

Everything else is the original authors' design. Upstream projects:
[fugsystem/LIES](https://github.com/fuglore/Little-Intelligence-Enhancements),
[TdlQ's mods](http://pd2mods.z77.fr/).

### Requirements

- **PAYDAY 2 248.2 x64** and **SuperBLT** — required.
- **Useful Bots 2.6.3 + HopLib** — recommended; this is the bot combat and
  utility layer the suite is tested with (intimidation, marking, target
  priority), on Hoppip's page: https://modworkshop.net/mod/31221
- **The Fixes** — optional general-fix mod, works alongside the suite:
  https://modworkshop.net/mod/23732

### Installation

1. Close PAYDAY 2.
2. Extract **both** archives so all seven folders end up in
   `...\PAYDAY 2\mods\`: `LIES`, `Iter`, `Keepers`, `Monkeepers`,
   `GoonmodCustomWaypoints`, `NoDuplicatedBullets`, `Simple Mod Updater` — each
   with its `mod.txt` directly inside.
3. Start the game. Settings appear under **Mod Options**.

Keep the folder names exactly as they are: the mods find each other by name, and
Monkeepers requires Keepers. Do not keep two copies of the same mod folder.

Already using one of these mods standalone? The bundle's copy replaces it. Save
files are shared with the standalone versions, so your settings carry over.

### Updating

- LIES, Iter, Keepers and Monkeepers update through SuperBLT's normal update
  prompt.
- Simple Mod Updater, GoonMod's Custom Waypoints and No Duplicated Bullets stay
  on the original author's update chain; this bundle does not change it.
- Each mod is versioned separately, so updating one does not force a new bundle
  download.

### If something breaks

1. Check the newest file in `PAYDAY 2\mods\logs\` — a Lua error names the file
   and therefore the mod that failed.
2. Report the bug on that mod's repository (linked under each mod above), or on
   the original project page for the three dependencies.
3. Installation or packaging problems belong in the bundle repository:
   https://github.com/met94/payday2-ai-suite

### Credits

- **LIES** — original mod and AI design by fugsystem; 248.2 x64 fork maintenance
  by met94.
- **Iter**, **Keepers**, **Monkeepers** — original mods by TdlQ; Iter maintenance
  by BangL; translations by the authors listed in each `mod.txt`; 248.2 fork
  maintenance by met94.
- **GoonMod's Custom Waypoints** — Wilko (original), TdlQ (extensions); r50
  248.2 update by BangL, redistributed unmodified.
- **No Duplicated Bullets** — TdlQ; 248.2 maintenance by met94.
- **Simple Mod Updater** — TdlQ, code maintenance by BangL, translations by
  LR_Daring and Kilowide.
- **Useful Bots** — Hoppip (not part of this download).
- Decompiled game reference: steam-test1/Payday-2-LuaJIT-Complete.

The four AI mods ship their own `README.md`, `changelog.txt`, `MENU_OPTIONS.md`
and `LICENSE`. The three dependencies ship their original `mod.txt` and
`changelog.txt`; they carry no license file and are redistributed unchanged with
credit.

### License

The bundle repository is public domain (Unlicense). LIES is AGPL-3.0; Iter,
Keepers and Monkeepers are Unlicense; the three dependencies carry no license
file. Bundling them does not relicense anything.

### Changelog

**2026.11.07.1** — split into two downloads: the four AI mods, plus a separate
archive with Keepers' required dependencies (Simple Mod Updater 34, GoonMod's
Custom Waypoints 50, No Duplicated Bullets 10). Useful Bots is now listed as a
recommended external mod instead of being implied as part of the pack.

**2026.11.07** — LIES 8.57.33: updates move to SuperBLT.

**2026.11.06.2** — GoonMod's Custom Waypoints 50 and No Duplicated Bullets 10
added to the download.

**2026.11.06** — first bundle: LIES 8.57.32, Iter 205.3, Keepers 239.3,
Monkeepers 87.4.

## Notes for the upload

- Upload both zips from the GitHub release
  `https://github.com/met94/payday2-ai-suite/releases/tag/v2026.11.07.1`, plus
  both release-notes files.
- Archive roots contain the folders directly (four and three); no wrapper
  folder.
- ModWorkshop renders Markdown; the description above is plain Markdown.
