# Cycle 1920 专题：APIM Gateway Cache Keyspace Salt Rotation Fairness 选型

## 摘要
本轮聚焦网关缓存 keyspace salt 轮换公平治理，通过分层 keyspace 与回压降低命中偏置。

## 结论
salt rotation fairness 能在高峰期同时改善公平性与延迟稳定性。
