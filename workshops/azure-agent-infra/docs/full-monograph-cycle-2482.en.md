# Cycle #2482 Core Engineering Monograph: Private Link Hub-Spoke Zero-Trust Egress (en)

- Round/Cycle: `1077 / 2482`
- Topic: `private-link-hubspoke-zero-trust-egress-faq-r1077`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Objective

Build a zero-trust network baseline for mixed Foundry/AKS/ACA planes through private access, centralized egress, and layered controls.

## 2) Core formulas

```text
required_ips = pods + node_overhead + reserves + surge
min_prefix = 32 - ceil(log2(required_ips))
required_snat_ports = concurrency * conn_per_session * retry_factor
failover_rto_seconds = detect + dns_ttl + switch + warmup
```

Thresholds:
- `ip_utilization_p95 < 0.85`
- `snat_utilization_p95 < 0.70`
- `failover_rto_p95 < 90s`

## 3) Runnable snippets (Bicep / YAML / Policy / KQL)

### Bicep

```bicep
resource firewall 'Microsoft.Network/azureFirewalls@2023-11-01' = {
  name: 'afw-agent-hub-premium'
  sku: { name: 'AZFW_VNet', tier: 'Premium' }
}
```

### YAML

```yaml
egressPolicy:
  defaultDeny: true
  maxSnatUtilization: 0.70
```

### Policy

```yaml
policy:
  if: { privateEndpointBypassDetected: true }
  then: { effect: deny }
```

### KQL

```kql
ZeroTrustEgressTelemetry
| where TimeGenerated > ago(30m)
| summarize ip_util_p95=percentile(SubnetIpUtilization,95), snat_p95=percentile(SnatUtilization,95), rto_p95=percentile(FailoverRtoSeconds,95) by TenantId, bin(TimeGenerated, 5m)
| where ip_util_p95 > 0.85 or snat_p95 > 0.7 or rto_p95 > 90
```

## 4) Triage flow

1. IP utilization breach: gate new sessions and expand CIDR.  
2. SNAT saturation: throttle and expand egress port pool.  
3. DNS drift: switch to fallback resolver path and freeze rollout.

## 5) Conclusion

Zero-trust egress topology is a foundational stability requirement: model-layer optimization cannot sustain SLA while network and DNS consistency remain uncontrolled.
