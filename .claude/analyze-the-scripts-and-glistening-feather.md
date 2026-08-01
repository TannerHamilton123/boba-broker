# Order Pricing: How It Works & How to Simplify It

## Context
You asked to understand everything that determines an order's price and to find ways to simplify that process. This is an analysis task first — the plan below documents current behavior (verified by reading the source), flags real bugs/dead code found along the way, and proposes a small set of simplification options. Nothing has been changed yet.

## How order price is currently calculated

**Pipeline:** `order_list.gd: add_order()` → `generate_order()` picks ingredients → `generate_market_price()` computes the price → stored on the `order_card` → shown via `order_card.gd: label_order()` → on fulfillment, `order_card.gd` emits `order_fulfilled(order, price)` → `order_manager.gd` adds `price` to `main.player_balance`.

**The formula** — [order_list.gd:107-123](scripts/order_list.gd#L107-L123):
```gdscript
func generate_market_price(order):
	var in_demand = false
	var price_multiplier = difficulty_check()[1]   # computed but never used below
	var order_price = 0.00
	for ingredient in order.keys():
		var base_price = main.game_ingredients[ingredient]["Price"]
		if base_price > 2.51:
			in_demand = true
		var price_variation = randf_range(-0.5, 0.5)
		order_price += (base_price + price_variation) * order[ingredient]
	if in_demand:
		order_price *= 1.20
	return [snappedf(order_price * 1.10, 0.5), in_demand]
```

So price = sum over each ingredient of `(live market price ± $0.50 random noise) × quantity`, then `+20%` if any ingredient's price was above `$2.51`, then a flat `+10%` on top, rounded to the nearest `$0.50`.

**What determines quantity/complexity** — [order_list.gd:143-156](scripts/order_list.gd#L143-L156) `difficulty_check()`: `happiness_score` (0-100) drives `order_difficulty` (1-5), which drives ingredient count (capped at 4) in `generate_order()`. Higher happiness → more ingredients per order → indirectly higher price.

**What determines the live per-ingredient market price** that `generate_market_price` reads:
- Base values start at `main.gd:5-7` (`TeaPrice`/`MilkPrice`/`PearlPrice = 2.5`, plus `2.5` for unlocked ingredients in `upgrade_manager.gd`).
- `event_manager.gd` randomly triggers scheduled market events that cube-multiply an ingredient's price by `event["price_multiplier"]` (defined per-event, e.g. 0.6-2.0), clamp to `[1.0, 5.0]`, and later revert it.
- `price_calculator.gd`'s continuous fluctuation system exists but is fully commented out — currently does nothing but print a debug line every tick.

## Bugs / dead code found (not simplifications — actual defects)

1. **Difficulty's price multiplier is computed but discarded.** `difficulty_check()` returns a `price_multiplier` (1.0-3.0) documented at [order_list.gd:19-29](scripts/order_list.gd#L19-L29) as affecting price, but `generate_market_price()` reads it into a local var and never applies it (comment at line 122: *"price was getting very high, so I'm going to remove the price_multiplier from difficulty for now"*). Difficulty only affects price indirectly today, via ingredient count.
2. **`generate_market_price()` is called twice per order** — [order_list.gd:59-60](scripts/order_list.gd#L59-L60):
   ```gdscript
   new_order.price = generate_market_price(new_order.order)[0]
   new_order.in_demand = generate_market_price(new_order.order)[1]
   ```
   Each call re-rolls its own independent `±0.5` random noise, so the stored `price` and `in_demand` flag can come from two different random rolls — the in-demand highlight can visually mismatch the actual price shown, and it's twice the necessary work.
3. **Event price revert clobbers to a hardcoded `2.5`, not the true prior price.** `event_manager.gd:146,176` — `trigger_event(..., baseline_price := 2.5)` reverts `game_ingredients[ingredient]["Price"]` to the default parameter `2.5` after the event ends, rather than to whatever the price actually was before the event fired. If a second event or fluctuation already changed the price, this silently overwrites it.
4. **"Supply" upgrade promises discounts it never gives.** [upgrades.gd:33-38](scripts/upgrades.gd#L33-L38) labels this upgrade "Bulk Order Discount" / "Supplier Contract" etc., but `upgrade_manager.gd: upgrade_supply()` only increments `supply_level`, which is only consumed by `bubble_spawner.gd` to speed up deal-bubble spawn rate — no ingredient or order cost is ever actually discounted.
5. **`price_bar.gd` is a disconnected prototype.** It never reads `main.game_ingredients`; it animates its own local `price` var that nothing else uses. Real price-bar visualization is done separately by `ui_manager.gd: move_price_icons()`, which reads the actual data.
6. **`price_calculator.gd` is dead.** Its market-fluctuation logic is entirely commented out; only a `print()` remains.

## Simplification options

These are options, not a committed plan — pick which (if any) you want implemented:

- **A. Remove per-ingredient random noise, apply randomness once.** Instead of `randf_range(-0.5,0.5)` per ingredient per call, roll variation once per order (or drop it) — removes the double-random-roll problem (bug #2) at the source and makes price easier to reason about.
- **B. Fix the double-call** by computing `generate_market_price()` once and destructuring `[price, in_demand] = generate_market_price(order)` — smallest possible fix, no behavior redesign needed.
- **C. Collapse the formula into one clear pass with named constants** instead of inline literals (`2.51`, `1.20`, `1.10`, `0.5`) — e.g. `const IN_DEMAND_THRESHOLD`, `const IN_DEMAND_MULTIPLIER`, `const MARKUP`, `const PRICE_VARIATION`, per your CLAUDE.md preference for no hardcoded values inside functions.
- **D. Either delete `price_calculator.gd`/`price_bar.gd` (dead code) or finish wiring them up** — right now they add surface area without doing anything.
- **E. Re-enable difficulty's price effect intentionally**, if you want difficulty to affect price directly again (currently it's indirect-only via ingredient count) — would mean deciding a target price multiplier scale and applying it in `generate_market_price()`.
- **F. Fix the event revert bug** by capturing the ingredient's actual price before the event starts and restoring that value, instead of a hardcoded `2.5` baseline.

## Verification
No code changes were made in this pass. If you choose to implement any of the fixes/simplifications above, verification would be: run the game (`run` skill / F5 in Godot), place several orders across a range of happiness levels, confirm price shown matches the formula, and confirm in-demand highlighting matches the actual displayed price (for fix B).
