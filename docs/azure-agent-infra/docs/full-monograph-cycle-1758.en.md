# Cycle 1758 Topic: Cosmos DB Agent State Partitioning and RU Cost

## Summary
This topic defines partitioning and RU governance patterns for multi-turn agent state, prioritizing tenant/session locality and hot/cold tiering.

## Key findings
1) bad partitioning amplifies cross-partition RU, 2) index/TTL policy determines long-run cost, 3) replayability should be ledger-driven.
