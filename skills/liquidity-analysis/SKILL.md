---
name: liquidity-analysis
disable-model-invocation: true
description: >
  Advanced liquidity analysis: pool identification, institutional flow detection, DOM/orderbook
  reading, volume concentration mapping, dark pool activity, micro-structure signals, real-time
  liquidity monitoring, slippage modeling, session liquidity patterns, tick data interpretation.
  USE FOR: liquidity pool, liquidity analysis, order flow imbalance, DOM depth of market,
  institutional accumulation, block trade detection, dark pools, spread widening, volume clusters,
  VWAP analysis, liquidity density, tick data, orderbook read, session liquidity patterns,
  forex liquidity zones, futures rollover liquidity, crypto exchange liquidity, position sizing
  for illiquidity, slippage backtesting, liquidity intensity scoring, confluence liquidity clusters,
  resting orders, stop hunts, imbalance zones, volume profile liquidity.
related_skills:
  - ict-smart-money
  - technical-analysis
  - price-action
  - execution-algo-trading
  - market-making-hft
  - risk-and-portfolio
tags:
  - trading
  - liquidity
  - orderflow
  - microstructure
  - institutional
  - execution
skill_level: advanced
kind: analyzer
category: trading/strategies
status: active
---
> **Skill:** Liquidity Analysis  |  **Domain:** trading  |  **Category:** analysis  |  **Level:** advanced
> **Tags:** `trading`, `liquidity`, `orderflow`, `microstructure`, `institutional`, `execution`


# Liquidity Analysis

> Connects: ICT/SMC liquidity sweeps ← **this file** → market microstructure execution
> For BSL/SSL sweep mechanics and trap entries → see `ict-smart-money.md`
> For bid-ask spread, slippage formulas, market impact → see `market-microstructure.md`

## Liquidity Pool Identification & Mapping

### Internal vs External Liquidity

```
EXTERNAL LIQUIDITY (outside price range — draw on liquidity targets):
  ┌─── Previous Day High (PDH)      ← buy stops cluster above
  │    Previous Week High (PWH)      ← larger pool
  │    Previous Month High (PMH)     ← institutional target
  │
  │    [Current Price Action]
  │
  │    Previous Day Low (PDL)        ← sell stops cluster below
  │    Previous Week Low (PWL)       ← larger pool
  └─── Previous Month Low (PML)     ← institutional target

INTERNAL LIQUIDITY (inside price range — fills and rebalancing):
  ├── Fair Value Gaps (FVG)          ← unfilled orders, price returns to fill
  ├── Order Blocks (OB)             ← institutional entry zones
  ├── Breaker Blocks                ← failed OB now acts as magnet
  └── Volume Imbalances             ← one-sided orderbook zones
```

### Liquidity Pool Formation Rules

```
Where pools form (strongest to weakest):
1. Equal highs/lows (EQH/EQL)     → engineered liquidity, highest probability sweep
2. Session highs/lows              → time-based, regular collection
3. Swing structure points          → structural, medium probability
4. Round numbers (00, 50 levels)   → psychological, retail clusters
5. Previous close levels           → institutional reference points

Pool strength scoring:
  +2  Equal highs/lows (multiple touches at same price)
  +2  Untested (first time price approaches)
  +1  Multiple timeframe alignment (4H pool + daily pool)
  +1  Near a key session level (PDH/PDL, PWH/PWL)
  +1  Volume profile thin zone nearby (price will move fast through)
  -1  Already swept once (diminishing returns)
  -2  Third approach (most liquidity already taken)

Score 5+ = high-probability target  |  Score 3-4 = medium  |  Score <3 = skip
```

### Multi-TF Liquidity Alignment

```
Strongest setup: liquidity pools aligned across timeframes

Monthly → Weekly → Daily → 4H → 1H
  │         │        │       │     │
  └─ PMH ───┴─ PWH ──┴─ PDH ─┴─ EQH ─ All pointing to same zone
                                         = MAXIMUM draw on liquidity

Rule: If 3+ timeframes have liquidity resting at the same zone,
      that zone WILL be reached with >80% probability.

Mapping process:
1. Mark monthly highs/lows (PMH/PML) on daily chart
2. Mark weekly highs/lows (PWH/PWL)
3. Mark daily highs/lows (PDH/PDL)
4. Mark 4H equal highs/lows
5. Highlight zones where 2+ levels cluster within 0.3% price range
```

## Institutional Liquidity Behavior

### How Institutions Scale In/Out

```
Accumulation Phase (buying):
1. Create sell-side liquidity → push price below key lows (stop hunt)
2. Absorb selling pressure → large bid stacking on DOM
3. Mark up → aggressive buy orders, displacement candles
4. Distribute at higher prices → sell into retail FOMO

Distribution Phase (selling):
1. Create buy-side liquidity → push price above key highs
2. Absorb buying pressure → large offer stacking
3. Mark down → aggressive selling, displacement
4. Accumulate at lower prices → buy retail panic

Key tells:
- Delta divergence: price rises but cumulative delta flat/falling = distribution
- Volume spikes at extremes (not mid-range) = institutional activity
- Spread widening then tightening = large order absorbed
```

### Block Trade & Iceberg Detection

```
Block trade signatures on chart:
- Single large-volume bar with minimal price impact = absorbed
- Cluster of equal-size orders at same price level = iceberg
- Volume spike with NO price movement = institutional limit order wall

DOM reading for iceberg detection:
- Bid/ask size refreshes at same price after fills = iceberg
- Large resting order that doesn't pull when tested = real
- Large order that pulls when price approaches = spoofing
```

### Dark Pool Dynamics

```
When to expect dark pool activity:
- Equity CFDs during US session (most dark pool volume)
- Index futures near settlement times
- Large-cap stocks during first/last 30 min of session

Dark pool impact on price:
- Price drifts without visible volume → dark pool execution
- Delayed reporting creates "ghost" volume bars
- Price discovers large orders AFTER execution completes
- Watch for post-block momentum: direction of next move reveals institutional intent
```

## Liquidity Dynamics by Session & Asset

### Forex Session Liquidity Map

```
Session        | Liquidity | Spread    | Best For
───────────────┼───────────┼───────────┼─────────────────────
Asia 00-07 UTC | LOW       | WIDE      | Range identification only
London 07-12   | HIGH      | TIGHT     | Breakouts, sweeps, trend starts
NY 13:30-17    | HIGHEST   | TIGHTEST  | All strategies valid
Overlap 13:30-16| PEAK     | MINIMUM   | Maximum opportunity
NY Close 20-22 | DROPPING  | WIDENING  | Exit positions, no new entries
Weekend gap    | ZERO      | MASSIVE   | Gap risk, not trading time

Pair-specific liquidity peaks:
  EUR/USD: London + NY overlap (13:30-16:00 UTC)
  USD/JPY: Asia (00-07) + NY overlap
  GBP/USD: London open (07:00-08:00 UTC) = maximum volatility
  AUD/USD: Asia open (22:00-01:00 UTC)
  XAU/USD: NY session only (13:30-17:00 UTC) — thin outside
```

### Indices Intraday Liquidity Pattern

```
Time (ET)    | Phase           | Liquidity | Action
─────────────┼─────────────────┼───────────┼─────────────────
09:30-10:00  | Opening auction | EXTREME   | ORB, initial direction
10:00-11:30  | Morning flow    | HIGH      | Trend continuation
11:30-13:30  | Lunch doldrums  | LOW       | No new trades, tighten stops
13:30-14:30  | Afternoon start | RISING    | Reversal or continuation
14:30-15:30  | Power hour      | HIGH      | Strong directional moves
15:30-16:00  | MOC imbalance   | EXTREME   | Closing auction, gap risk
```

### Crypto Liquidity Fragmentation

```
Challenge: Liquidity split across 20+ exchanges
  CEX (Binance, Coinbase): 80%+ of BTC liquidity
  DEX (Uniswap, dYdX): 5-10%, higher slippage

Crypto liquidity calendar:
  Best: US business hours (higher CEX volume)
  Worst: Weekend 04:00-08:00 UTC (minimum global activity)
  Dangerous: After large liquidation cascade (thin books)

Unique crypto risk:
  - Exchange-specific flash crashes (thin book + market sell)
  - Funding rate spikes = forced liquidations = liquidity vacuum
  - Stablecoin depegs drain liquidity from ALL pairs
```

## Micro-Level Liquidity Analysis

### Tick Data Interpretation

```python
def order_flow_imbalance(trades_df):
    """Calculate order flow imbalance from tick data.

    Args:
        trades_df: DataFrame with columns [timestamp, price, volume, side]
                   side: 'buy' (market buy hitting ask) or 'sell' (market sell hitting bid)
    """
    buy_vol = trades_df[trades_df['side'] == 'buy']['volume'].sum()
    sell_vol = trades_df[trades_df['side'] == 'sell']['volume'].sum()
    total = buy_vol + sell_vol

    if total == 0:
        return 0.0

    imbalance = (buy_vol - sell_vol) / total  # Range: -1 to +1

    # Interpretation:
    # > +0.3  = strong buying pressure (institutional accumulation?)
    # < -0.3  = strong selling pressure (institutional distribution?)
    # -0.1 to +0.1 = balanced (no edge, ranging market)

    return imbalance
```

### Volume Profile as Liquidity Indicator

```
POC (Point of Control):
  = Price level with highest traded volume
  = Where most limit orders were filled
  = Strong support/resistance (liquidity magnet)

VAH/VAL (Value Area High/Low):
  = 70% of volume traded between these levels
  = Price outside VA = in thin liquidity zone → fast moves
  = Price returning to VA = seeking liquidity → mean reversion

Liquidity interpretation by VP shape:
  D-SHAPE:  Heavy center, thin edges → ranging, fade extremes
  P-SHAPE:  Top-heavy → sellers exhausting, potential reversal down
  B-SHAPE:  Bottom-heavy → buyers exhausting, potential reversal up
  THIN:     No dominant level → trending, trade with momentum
  BIMODAL:  Two POCs → market undecided, trade the space between
```

### DOM/Level 2 Reading

```
Key DOM patterns:
1. BID STACKING: Large resting bids below current price
   → Support building, institutional buying interest
   → BUT: could be spoofing (pulls when tested)
   → Confirmation: bids don't pull when touched + absorption

2. OFFER STACKING: Large resting asks above current price
   → Resistance building, institutional selling interest
   → Same spoofing risk — watch for pulls

3. ABSORPTION: Large orders at a level keep getting filled
                but price doesn't move through
   → Strong institutional defense of that level
   → High-probability reversal zone

4. PULLING: Large orders disappear when price approaches
   → Spoofing / bluffing — price will move THROUGH that level
   → Often precedes a sweep

5. FLIPPING: Bid stacking switches to offer stacking (or reverse)
   → Institutional intent changing
   → Strong directional signal
```

## Liquidity-Based Entry & Exit Rules

### When NOT to Trade (Liquidity Dry-Up)

```
NO TRADE conditions:
□ Spread > 2x normal for this session/pair
□ Volume < 30% of 20-bar average
□ ATR last 5 bars < 40% of session ATR average
□ Within 15 min of red-folder news event
□ Bid-ask depth < 50% of normal (DOM thinning)
□ Friday after 17:00 UTC (weekend risk, thin markets)

If 2+ conditions met → NO NEW TRADES
If 3+ conditions met → CLOSE or TIGHTEN existing positions
```

### Position Sizing for Liquidity

```python
def liquidity_adjusted_size(base_lots, symbol, session, spread_now, spread_avg):
    """Adjust position size based on current liquidity conditions."""

    # Spread ratio: current spread vs session average
    spread_ratio = spread_now / spread_avg if spread_avg > 0 else 2.0

    # Liquidity multiplier
    if spread_ratio <= 1.0:
        mult = 1.0          # Normal liquidity — full size
    elif spread_ratio <= 1.5:
        mult = 0.75          # Slightly thin — reduce 25%
    elif spread_ratio <= 2.0:
        mult = 0.5           # Thin — half size
    elif spread_ratio <= 3.0:
        mult = 0.25          # Very thin — quarter size
    else:
        mult = 0.0           # No trade — liquidity gone

    return round(base_lots * mult, 2)
```

### Slippage Prediction Model

```
Expected slippage by condition:

Condition                           | Expected Slippage
────────────────────────────────────┼──────────────────
Normal session, major pair          | 0.0-0.2 pips
Normal session, minor/exotic        | 0.5-2.0 pips
News release (first 30 sec)        | 5-50 pips
Low-liquidity session (Asia FX)    | 0.3-1.0 pips
Large position (>5 std lots)       | 0.5-3.0 pips
Market close / rollover            | 1.0-5.0 pips
Flash crash / liquidity vacuum     | 20-200+ pips

Rule: If expected slippage > 20% of stop loss distance → DO NOT TRADE
      Position too large or market too thin for this setup.
```

## Liquidity Clusters & Confluence Scoring

### Cluster Identification

```
A liquidity CLUSTER forms when 3+ factors converge:

Example cluster:
  PDH at 2045.50           ← external liquidity
  + Equal highs at 2045.80 ← engineered pool
  + Fib 1.618 at 2046.00   ← algorithmic orders
  + Round number 2050       ← psychological level
  = STRONG liquidity cluster (4 factors within 0.2% range)

Scoring:
  2 factors = moderate cluster (trade normally)
  3 factors = strong cluster (likely target, use as TP)
  4+ factors = extreme cluster (almost certain to be reached)

Action at clusters:
  - If price APPROACHING cluster → hold/add to position (target being reached)
  - If price AT cluster → take profits (liquidity being consumed)
  - If price SWEPT cluster → look for reversal (purpose fulfilled)
```

### Multi-TF Liquidity Heat Map

```
Build a heat map by marking liquidity levels from multiple TFs:

Monthly  ━━━━━━━━━━━━━━━━━━━━━━ PMH (2100)

Weekly   ─────────────────────── PWH (2080)

Daily    ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ PDH (2055)
4H       ............EQH (2052)
         ............EQH (2048)  ← CLUSTER: PDH + 4H EQH within 7 pts

         [Current price: 2030]

4H       ............EQL (2015)
Daily    ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ PDL (2010)  ← CLUSTER: PDL + 4H EQL
Weekly   ─────────────────────── PWL (1995)
Monthly  ━━━━━━━━━━━━━━━━━━━━━━ PML (1950)

Trade logic:
  If TRENDING UP → target PDH/EQH cluster (2048-2055)
  If TRENDING DOWN → target PDL/EQL cluster (2010-2015)
  PWH/PWL = extended targets for swing trades
```

## Real-Time Liquidity Monitoring

### Spread Behavior as Signal

```
Spread tightening (converging to minimum):
  → Liquidity increasing → safe to enter
  → Typically: session open, pre-news positioning

Spread widening (expanding above average):
  → Liquidity decreasing → reduce exposure
  → Typical: news release, session close, flash event

Rapid spread spike then return:
  → Large market order absorbed → institutional activity
  → Watch price direction after absorption = institutional intent
```

### Volume Surge Detection

```python
def detect_volume_surge(df, lookback=20, threshold=2.5):
    """Flag bars where volume exceeds threshold × rolling average."""
    avg_vol = df['volume'].rolling(lookback).mean()
    df['vol_ratio'] = df['volume'] / avg_vol
    df['is_surge'] = df['vol_ratio'] > threshold

    # Surge + displacement = institutional breakout
    # Surge + no price movement = absorption (reversal signal)
    # Surge + wick rejection = stop hunt / liquidity sweep

    return df
```

## Case Studies: Trap vs Real Move

### Identifying False Sweeps (Bait)

```
FALSE SWEEP (trap — don't chase):
  - Wick pokes through level but body closes back inside
  - Volume on sweep bar is LOW (not institutional)
  - No displacement candle follows within 3 bars
  - Spread doesn't widen significantly during sweep
  → Result: Price reverses — the sweep was the move

REAL BREAKOUT (institutional — trade continuation):
  - Full body close through level with displacement
  - Volume on break bar is HIGH (2x+ average)
  - Immediate follow-through bars in same direction
  - Spread tightens after break (liquidity flowing into direction)
  → Result: Price continues — the break was institutional commitment

Key distinction: VOLUME + DISPLACEMENT + FOLLOW-THROUGH
  All three present → real move
  Any missing → likely trap
```

### Accumulation vs Retail Trap

```
ACCUMULATION (institutional buying):
  Time: Days/weeks of ranging price action
  Volume: Gradually increasing on up-bars, decreasing on down-bars
  Delta: Slowly building positive cumulative delta
  DOM: Persistent bid stacking that doesn't pull
  Result: Eventually breaks up with massive displacement

RETAIL TRAP (designed to shake out weak hands):
  Time: Hours, usually during killzone transitions
  Volume: Spike on stop-hunt bar, then normalizes
  Delta: Sharp negative spike then rapid recovery
  DOM: Bids appear then immediately pull (spoofing)
  Result: Price reverses violently after shakeout
```

## Liquidity & Risk Management

### Position Size by Market Liquidity

```
Tier 1 (deepest liquidity) → full 1% risk:
  EUR/USD, USD/JPY, GBP/USD, XAU/USD (NY session)
  ES, NQ, SPY during RTH

Tier 2 (good liquidity) → 0.75% risk:
  AUD/USD, USD/CAD, USD/CHF
  BTC/USD (major CEX, US hours)
  Index CFDs during RTH

Tier 3 (moderate liquidity) → 0.5% risk:
  Cross pairs (EUR/GBP, GBP/JPY)
  Stock CFDs (TSLA, AAPL during RTH)
  XAG/USD, USOILm

Tier 4 (thin liquidity) → 0.25% risk:
  Exotic pairs (USD/TRY, USD/ZAR)
  Crypto altcoins
  Any instrument outside its primary session
  Pre/post-market stock CFDs
```

### Drawdown Amplification in Thin Markets

```
In low-liquidity conditions:
  - Stop slippage increases 3-10x
  - Gap risk becomes significant
  - Correlation spikes (all positions move together)
  - Drawdown compounds faster than expected

Protection rules:
  □ Maximum 3% portfolio heat in thin markets (vs 6% normal)
  □ No positions held through major news in illiquid instruments
  □ Close or hedge exotic/crypto positions before weekend
  □ Use guaranteed stops where available (accept wider cost)
```

---

## Related Skills

- [Ict Smart Money](../ict-smart-money.md)
- [Market Microstructure](../market-microstructure.md)
- [Technical Analysis](../technical-analysis.md)
- [Price Action](../price-action.md)
- [Execution Algo Trading](../execution-algo-trading.md)
- [Market Making Hft](../market-making-hft.md)
- [Risk And Portfolio](../risk-and-portfolio.md)
