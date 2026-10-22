# Cheese — Spell Activation Overlays for WoW 3.3.5a

[English](#english) | [中文](#中文)

---

## English

**Cheese** is a spell-activation-overlay addon for World of Warcraft **3.3.5a** (Wrath of the Lich King private servers). It backports the Cataclysm-style **SpellActivationOverlay** UI: when a proc happens, class-specific artwork flashes on screen (e.g. the fiery double arcs for Hot Streak) and the relevant action-bar buttons light up with the "ants" glow.

### What's fixed / added in this version

1. **Fixed: Hot Streak never displayed.**
   The overlay data entry for Hot Streak (spell 48108) required a stack count of ≥ 1, but non-stacking buffs report a stack count of `0` on 3.3.5a servers — so the check `not (count < 1)` always failed and neither the on-screen arcs nor the Pyroblast button glow could ever trigger. The requirement is now `0` (fire whenever the buff exists), matching how other non-stacking procs (e.g. Brain Freeze) are declared in the same table.

2. **Added: "Heating Up" early-warning module** (`HeatingUp.lua`).
   Restores the modern two-stage fire-mage proc display. After the **first crit** of Fireball / Fire Blast / Scorch / Living Bomb / Frostfire Bolt, half-size side arcs appear — meaning "one more crit triggers Hot Streak (instant Pyroblast)". The half arcs hide on a non-crit of those spells, or when Hot Streak is gained (the full-size built-in overlay then takes over).
   - Mage-only: the combat-log listener is not even registered on other classes.
   - Spell names are matched via `GetSpellInfo` (localized, rank-independent), with nil-guards for servers with custom spell data.
   - Visuals reuse the stock `HOT_STREAK.BLP` texture at 50 % scale; no new assets.
   - Respects the existing master toggle `cheeseDisplaySpellActivationOverlays`.

3. **New API** in `APISpellActivationOverlay.lua`: `Cheese_FireOverlayShow(spellID, texture, positions, scale, r, g, b)` and `Cheese_FireOverlayHide(spellID)` let non-aura-driven modules (like the combat-log state machine above) display screen overlays through the normal event pipeline.

### Installation

1. Download: **Code → Download ZIP** (or grab the packaged zip from **Releases** if available).
2. Extract; make sure the folder is named exactly `Cheese` (rename `Cheese-main` → `Cheese`).
3. Move it into `World of Warcraft\Interface\AddOns\`.
4. Restart the game or run `/reload`.

### Compatibility

- Client: World of Warcraft **3.3.5a** (build 12340).
- Tested on private servers (Triumvirate/泰坦时光, Whitemane FrostmourneRebuffed). Aura stack-count semantics differ between server cores; the fixes in this version work under both `count = 0` and `count = 1` conventions for non-stacking buffs.

---

## 中文

**Cheese** 是一个魔兽世界 **3.3.5a**（巫妖王之怒私服）法术激活提醒插件，移植自大地的裂变（Cataclysm）风格的 SpellActivationOverlay 官方界面：当触发类特效（proc）出现时，屏幕两侧/顶部会闪现职业专属的美术纹理（例如法师法术连击的火焰双弧），同时动作条上对应按钮亮起"蚂蚁线"发光。

### 本版本的修复与新增内容

1. **修复：法术连击（Hot Streak，法术ID 48108）永远不提示的问题。**
   overlay 数据表中该条目的"最低层数要求"被误写为 `1`，而不可叠加 buff 在 3.3.5a 服务端下发的层数为 `0`，导致 `not (0 < 1)` 恒为假——屏幕双弧与炎爆术按钮发光全部被门控拦截、从未触发。现已改为 `0`（buff 存在即触发），与同表中其他不可叠加触发（如脑部冻结）的写法一致。

2. **新增：热力迸发（Heating Up）预警模块**（`HeatingUp.lua`）。
   还原了现代客户端法师的两段式提示：火球术 / 火焰冲击 / 灼烧 / 活动炸弹 / 霜火之箭**首次暴击**后，屏幕两侧显示半格小火弧——表示"再暴击一次即触发法术连击（瞬发炎爆）"。上述法术未暴击、或获得法术连击后小火弧消失（由内置的完整大弧接管）。
   - 仅法师生效：其他职业根本不注册战斗日志监听，零性能开销。
   - 法术名通过 `GetSpellInfo` 本地化匹配（与技能等级无关），并对返回 nil 的情况做了防护（兼容自定义法术数据的服务端）。
   - 视觉复用自带的 `HOT_STREAK.BLP`，50% 缩放，无新增素材。
   - 遵循既有总开关 `cheeseDisplaySpellActivationOverlays`。

3. **新增 API**（`APISpellActivationOverlay.lua`）：`Cheese_FireOverlayShow(spellID, texture, positions, scale, r, g, b)` 与 `Cheese_FireOverlayHide(spellID)`，允许非 aura 驱动的模块（如上述战斗日志状态机）通过正常事件管线显示屏幕纹理。

### 安装方法

1. 下载：**Code → Download ZIP**（或到 **Releases** 下载打包好的 zip）。
2. 解压后确认文件夹名称为 `Cheese`（若是 `Cheese-main` 请重命名）。
3. 放入 `World of Warcraft\Interface\AddOns\` 目录。
4. 重启游戏或 `/reload`。

### 兼容性

- 客户端：魔兽世界 **3.3.5a**（build 12340）。
- 已在私服环境实测（Triumvirate/泰坦时光、Whitemane FrostmourneRebuffed）。不同服务端内核对不可叠加 buff 的层数下发口径不同（0 或 1），本版本的修复在两种口径下均能正常工作。
