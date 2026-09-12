# ADR-002 — Synthetic Ad Spend Table

---

## Context
The Maven Analytics dataset contains no marketing spend data. Without it, 
key acquisition metrics (ROAS, CAC) cannot be computed and the core business 
question — *is this growth sustainable?* — cannot be answered.

## Decision
Design a synthetic `ad_spend` table modelled on real Google/Bing paid search 
benchmarks for e-commerce (2012–2015), covering 4 channels:

| Channel | Campaign | Daily Spend |
|---|---|---|
| gsearch | nonbrand | ~$1,430 |
| gsearch | brand | ~$306 |
| bsearch | nonbrand | ~$245 |
| bsearch | brand | ~$61 |

Spend calibrated to produce a ROAS of ~2x in the final quarter — consistent 
with a business under acquisition pressure. Data covers Q1 2015 only 
(the highest-revenue quarter) to model worst-case sustainability at peak growth.

## Consequences
- ROAS and CAC are scenario-based, not actuals — clearly documented
- Enables `scenario__growth_sustainability` model and the core project narrative
- In a production environment this would connect to a Google Ads or Meta API source
