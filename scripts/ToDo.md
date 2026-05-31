# Boba Broker — Task List

---

## 1. Tutorial
At the start of the game, a character pops up on screen with text bubbles describing the UI and game mechanics.
- Each bubble is filled with typed (typewriter-style) text
- A **Close** button at the bottom of each bubble lets the player advance the tutorial

---

## 2. Price Updating Animations
When the player's bank account balance changes, display a floating number that jumps and fades out from the balance:
- **Money lost** → red floating value
- **Money gained** → green floating value

---

## 3. Can't Afford Animation
If the player cannot afford an ingredient or an upgrade, show a popup in the **lower part of the screen** indicating they cannot afford it.

---

## 4. Price Change Events
Along the clock and calendar, ingredient icons appear with **up/down arrows** representing upcoming price change events.
- Events are moderately random but consistent across all ingredients
- Events should be visible before they take effect so the player can react

---

## 5. Upgrade Costs and Effects
Each upgrade level has a specific cost that increases with each level. When the player clicks an upgrade:
1. Check if the player can afford it
2. If **no** → play the Can't Afford animation (see #3)
3. If **yes** → subtract cost from bank account, apply the upgrade, and update the displayed cost for the next level

---

## 6. Start Next Week (End of Week Screen)
On the End of Week screen, add a **"Start Next Week"** button that:
1. Calls `queue_free()` on the EOW screen
2. Resumes all timers in main
3. Starts the new week
4. Respawns Price Change Events (see #4)

---

## Bugs

- Load bar at end of week is not full, despite being full right before showing EOW
- Update rent display $
- Round upgrade prices to whole $
- Proofread tutorial

---

## Would Be Nice

- **Dynamic demand multiplier (pricing v2):** Add a demand scalar that fluctuates independently of ingredient costs. High demand = orders pay a bonus on top of the base boba price; low demand = base price only. This gives the sell side its own decision layer without coupling order value to ingredient prices, and creates a natural reason to sometimes hold stock and wait for a spike rather than fulfilling immediately.
- Pause button during game
- Transition from title screen to tutorial