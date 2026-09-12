# ADR-001 — COPY INTO over Auto Loader

**Status:** Accepted  
**Date:** 2025

---

## Context
Raw e-commerce data is a static historical CSV dataset (1.7M rows, March 2012–2015). 
No continuous file stream. Ingestion runs once.

## Decision
Use `COPY INTO` instead of Auto Loader.

| | COPY INTO | Auto Loader |
|---|---|---|
| Best for | Batch / static files | High-volume streaming |
| Idempotent | ✅ Yes | ✅ Yes |
| Setup complexity | Low | Medium |
| File discovery | Directory scan | Cloud notification service |

## Consequence
- Simpler setup with no stream configuration overhead
- Not suitable if the source evolves into a real-time feed
- **Future state:** migrating to Auto Loader when connecting Azure Data Lake Gen2 as the source
