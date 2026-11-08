# Agent A2A Retry Jitter Window Selection FAQ (Fixed-Interval Retries vs Exponential Backoff + Jitter)

## 0) Executive takeaway
- **Default to exponential backoff + jitter in production**; fixed intervals synchronize retries and amplify outages.
- **Fixed interval is acceptable only for low-concurrency non-critical paths**.
- **Retry policy must be tied to idempotency keys and circuit thresholds**.

## 1) What are you deciding?
- Fixed interval: constant wait between retries.
- Exponential backoff + jitter: increasing window with randomness.

## 2) When fixed interval is acceptable
- small request volume
- stable downstream capacity
- retry bursts are tolerable

## 3) When backoff+jitter is mandatory
- A2A multi-agent fan-out
- constrained MCP downstreams
- fault spikes requiring anti-synchronization

## 4) Architecture sketch
```mermaid
flowchart LR
  Fail[Request Failed] --> Retry[Retry Planner]
  Retry --> Backoff[Exponential Backoff]
  Backoff --> Jitter[Random Jitter]
  Jitter --> Gate[Idempotency + Circuit Gate]
  Gate --> ReReq[Retry Request]
```

## 5) Decision matrix
| Dimension | Fixed interval | Exponential backoff + jitter |
|---|---|---|
| Implementation complexity | Low | Medium |
| Peak suppression | Weak | Strong |
| Retry storm risk | High | Low |
| Downstream protection | Weak | Strong |
| Production robustness | Medium | High |

## 6) Recomputable example
Assume failure rate=8% and 3000 req/s:
- Fixed interval: retry peak overlap factor = 1.9x
- Backoff+jitter: retry peak overlap factor = 1.2x

Retry peak pressure drops by about **36.8%**.
