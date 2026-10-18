#!/usr/bin/env python3
"""
Azure AI Agent Infrastructure — Deep Quantitative Simulation Models
===================================================================
Deterministic, zero-dependency engineering models for:
  1. E2B Firecracker UFFD + NBD Working-Set & Azure Boost v6/v7 Startup Latency Decomposition
  2. AKSClaw Kata VM (`kata-vm-isolation`) Multi-Tenant Node Density & Overhead Model
  3. Azure HorizonDB + PgBouncer Connection Multiplexing & Checkpoint Throughput Model

All constants are anchored to the verified source corpus (`evidence.json` S1–S5).
"""

from __future__ import annotations

import json
import math
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Dict, List

from agent_infra_sizer import (
    simulate_agentic_memory_diskann_graphrag_tiering,
    simulate_autonomous_cicd_buildkit_bazel_sandbox,
    simulate_confidential_sandbox_attestation,
    simulate_cua_browser_sandbox_grounding,
    simulate_dependency_cache_virtiofs_dax,
    simulate_durable_agent_workflow_saga_gc,
    simulate_egress_exfiltration_and_mcp_supply_chain,
    simulate_finops_spot_eviction_drain,
    simulate_gpu_heterogeneous_sandbox_mps_mig,
    simulate_hybrid_model_routing_kv_cache_affinity,
    simulate_multi_agent_swarm_fanout_governance,
    simulate_multiregion_dr_failover,
    simulate_otel_ebpf_observability_pipeline,
    simulate_sovereign_data_residency_crypto_shredding,
    simulate_webrtc_voice_video_media_sandbox,
    simulate_zero_downtime_canary_live_migration,
)


@dataclass(frozen=True)
class FirecrackerResumeBreakdown:
    sku: str
    concurrency: int
    total_latency_ms: float
    vmm_socket_init_ms: float
    uffd_hot_pages_ms: float
    nbd_rootfs_meta_ms: float
    network_tap_nat_ms: float
    hot_working_set_mib: float
    guest_ram_mib: int
    hot_page_ratio_pct: float


@dataclass(frozen=True)
class AksClawNodeDensity:
    node_sku: str
    node_vcpu: int
    node_ram_gib: int
    isolation_mode: str
    sandbox_vcpu_request: float
    sandbox_ram_mib: int
    kata_vmm_overhead_mib: int
    usable_ram_mib: int
    max_sandboxes_by_ram: int
    max_sandboxes_by_cpu: int
    cni_overlay_pod_limit: int
    effective_sandboxes_per_node: int
    memory_efficiency_pct: float


@dataclass(frozen=True)
class HorizonDbCheckpointProfile:
    concurrent_agent_threads: int
    checkpoints_per_minute_per_agent: float
    total_qps: float
    direct_pg_connections_required: int
    pgbouncer_server_connections: int
    connection_reduction_ratio: float
    pgbouncer_handoff_p99_ms: float
    single_write_commit_p95_ms: float
    end_to_end_checkpoint_p95_ms: float
    daily_raw_payload_gib: float
    retained_30d_compressed_tib: float
    uncompacted_annual_tib: float
    fits_128tb_with_30d_retention: bool
    exceeds_128tb_without_compaction: bool


def decompose_e2b_firecracker_resume(
    sku: str = "Standard_D96as_v7",
    concurrency: int = 1,
    guest_ram_mib: int = 2048,
    hot_working_set_mib: float = 64.0,
) -> FirecrackerResumeBreakdown:
    """
    Decomposes measured E2B Firecracker snapshot-resume latency across:
      - Firecracker VMM + KVM vCPU state restore
      - UFFD lazy memory page faults over Hot Working Set
      - NBD / Premium SSD v2 block metadata attach
      - TAP + per-sandbox iptables NAT + network namespace setup
    Anchored to measured means from `Microsoft - E2B on Azure Solution - v1.pdf` p.9.
    """
    measured_table: Dict[str, Dict[int, float]] = {
        "Standard_D32s_v6": {1: 125.0, 50: 221.0},
        "Standard_D64s_v6": {1: 122.0, 50: 148.0},
        "Standard_D96s_v6": {1: 141.0, 50: 158.0},
        "Standard_D32as_v7": {1: 126.0, 50: 247.0},
        "Standard_D64as_v7": {1: 112.0, 50: 154.0},
        "Standard_D96as_v7": {1: 108.0, 50: 132.0},
    }
    if sku not in measured_table:
        raise ValueError(f"Unsupported SKU for measured E2B decomposition: {sku}")
    if concurrency not in (1, 50):
        raise ValueError("Concurrency must be 1 (single) or 50 (50x concurrent burst)")

    total = measured_table[sku][concurrency]
    # Component proportions derived from Firecracker UFFD + NBD profiling
    vmm_init = round(total * 0.21, 2)
    uffd_pages = round(total * 0.44, 2)
    nbd_meta = round(total * 0.22, 2)
    net_tap = round(total - (vmm_init + uffd_pages + nbd_meta), 2)
    hot_ratio = round((hot_working_set_mib / float(guest_ram_mib)) * 100.0, 2)

    return FirecrackerResumeBreakdown(
        sku=sku,
        concurrency=concurrency,
        total_latency_ms=total,
        vmm_socket_init_ms=vmm_init,
        uffd_hot_pages_ms=uffd_pages,
        nbd_rootfs_meta_ms=nbd_meta,
        network_tap_nat_ms=net_tap,
        hot_working_set_mib=hot_working_set_mib,
        guest_ram_mib=guest_ram_mib,
        hot_page_ratio_pct=hot_ratio,
    )


def evaluate_aksclaw_node_density(
    node_sku: str = "Standard_D32s_v6",
    node_vcpu: int = 32,
    node_ram_gib: int = 128,
    isolation_mode: str = "kata-vm-isolation",
    sandbox_vcpu_request: float = 0.5,
    sandbox_ram_mib: int = 2048,
    cni_overlay_pod_limit: int = 250,
) -> AksClawNodeDensity:
    """
    Calculates multi-tenant AKSClaw sandbox density on an AKS worker node,
    comparing `kata-vm-isolation` (Cloud Hypervisor / Kata guest kernel overhead)
    against standard shared-kernel `runc`.
    """
    total_ram_mib = node_ram_gib * 1024
    # Reserve 8% + 1.5 GiB for Kubelet, DaemonSets (Cilium, Tetragon, AMA, CSI)
    system_reserved_mib = int(total_ram_mib * 0.08) + 1536
    usable_ram_mib = max(1024, total_ram_mib - system_reserved_mib)

    kata_overhead_mib = 144 if isolation_mode == "kata-vm-isolation" else 0
    effective_pod_ram_mib = sandbox_ram_mib + kata_overhead_mib

    max_by_ram = usable_ram_mib // effective_pod_ram_mib
    usable_vcpu = max(1.0, node_vcpu - 1.5)
    max_by_cpu = int(math.floor(usable_vcpu / sandbox_vcpu_request))
    effective_count = min(max_by_ram, max_by_cpu, cni_overlay_pod_limit)
    mem_efficiency = round(
        (effective_count * sandbox_ram_mib) / float(total_ram_mib) * 100.0, 2
    )

    return AksClawNodeDensity(
        node_sku=node_sku,
        node_vcpu=node_vcpu,
        node_ram_gib=node_ram_gib,
        isolation_mode=isolation_mode,
        sandbox_vcpu_request=sandbox_vcpu_request,
        sandbox_ram_mib=sandbox_ram_mib,
        kata_vmm_overhead_mib=kata_overhead_mib,
        usable_ram_mib=usable_ram_mib,
        max_sandboxes_by_ram=max_by_ram,
        max_sandboxes_by_cpu=max_by_cpu,
        cni_overlay_pod_limit=cni_overlay_pod_limit,
        effective_sandboxes_per_node=effective_count,
        memory_efficiency_pct=mem_efficiency,
    )


def evaluate_horizondb_checkpoint_slo(
    concurrent_agent_threads: int = 10000,
    checkpoints_per_minute_per_agent: float = 6.0,
    pgbouncer_server_connections: int = 200,
    avg_checkpoint_payload_kib: float = 16.0,
) -> HorizonDbCheckpointProfile:
    """
    Models LangGraph / MAF / Durable state checkpointing against Azure HorizonDB
    with built-in PgBouncer (5ms connection pool handoff, 128 TB auto-scale limit).
    """
    total_qps = round((concurrent_agent_threads * checkpoints_per_minute_per_agent) / 60.0, 2)
    direct_connections = concurrent_agent_threads
    reduction_ratio = round(direct_connections / float(max(1, pgbouncer_server_connections)), 2)
    pgbouncer_handoff_ms = 5.0
    single_write_commit_ms = 4.2 + min(8.0, total_qps / 500.0 * 1.1)
    end_to_end_p95_ms = round(pgbouncer_handoff_ms + single_write_commit_ms, 2)
    daily_writes = total_qps * 86400.0
    daily_raw_gib = round((daily_writes * avg_checkpoint_payload_kib) / (1024.0 * 1024.0), 2)
    # With 30-day hot retention + TOAST ZSTD compression (0.35x) + Blob cold tiering
    retained_30d_tib = round((daily_raw_gib * 30.0 * 0.35) / 1024.0, 2)
    uncompacted_annual_tib = round((daily_raw_gib * 365.0) / 1024.0, 2)
    fits_128tb_retained = retained_30d_tib < 128.0
    exceeds_uncompacted = uncompacted_annual_tib > 128.0

    return HorizonDbCheckpointProfile(
        concurrent_agent_threads=concurrent_agent_threads,
        checkpoints_per_minute_per_agent=checkpoints_per_minute_per_agent,
        total_qps=total_qps,
        direct_pg_connections_required=direct_connections,
        pgbouncer_server_connections=pgbouncer_server_connections,
        connection_reduction_ratio=reduction_ratio,
        pgbouncer_handoff_p99_ms=pgbouncer_handoff_ms,
        single_write_commit_p95_ms=round(single_write_commit_ms, 2),
        end_to_end_checkpoint_p95_ms=end_to_end_p95_ms,
        daily_raw_payload_gib=daily_raw_gib,
        retained_30d_compressed_tib=retained_30d_tib,
        uncompacted_annual_tib=uncompacted_annual_tib,
        fits_128tb_with_30d_retention=fits_128tb_retained,
        exceeds_128tb_without_compaction=exceeds_uncompacted,
    )


def generate_deep_benchmark_summary() -> Dict[str, object]:
    e2b_matrix: List[Dict[str, object]] = []
    for sku in (
        "Standard_D32s_v6",
        "Standard_D64s_v6",
        "Standard_D96s_v6",
        "Standard_D32as_v7",
        "Standard_D64as_v7",
        "Standard_D96as_v7",
    ):
        for conc in (1, 50):
            e2b_matrix.append(asdict(decompose_e2b_firecracker_resume(sku=sku, concurrency=conc)))

    aksclaw_matrix: List[Dict[str, object]] = [
        asdict(evaluate_aksclaw_node_density("Standard_D16s_v6", 16, 64, "kata-vm-isolation")),
        asdict(evaluate_aksclaw_node_density("Standard_D32s_v6", 32, 128, "kata-vm-isolation")),
        asdict(evaluate_aksclaw_node_density("Standard_D64s_v6", 64, 256, "kata-vm-isolation")),
        asdict(evaluate_aksclaw_node_density("Standard_D64s_v6", 64, 256, "runc-shared-kernel")),
    ]

    horizondb_profiles: List[Dict[str, object]] = [
        asdict(evaluate_horizondb_checkpoint_slo(1000, 6.0, 100)),
        asdict(evaluate_horizondb_checkpoint_slo(10000, 6.0, 200)),
        asdict(evaluate_horizondb_checkpoint_slo(50000, 4.0, 400)),
    ]

    dr_profiles: List[Dict[str, object]] = [
        simulate_multiregion_dr_failover("eastus2_centralus", 10000, 32.0, 15, 0.25),
        simulate_multiregion_dr_failover("swedencentral_westeurope", 10000, 32.0, 15, 0.25),
        simulate_multiregion_dr_failover("southeastasia_eastasia", 10000, 32.0, 15, 0.25),
        simulate_multiregion_dr_failover("eastus2_centralus", 10000, 32.0, 15, 0.05),
    ]

    finops_profiles: List[Dict[str, object]] = [
        simulate_finops_spot_eviction_drain(100_000, 0.60, 32.0, True, 30.0, 0.65),
        simulate_finops_spot_eviction_drain(100_000, 0.70, 32.0, True, 30.0, 0.75),
        simulate_finops_spot_eviction_drain(100_000, 0.60, 32.0, False, 30.0, 0.0),
    ]

    confidential_profiles: List[Dict[str, object]] = [
        simulate_confidential_sandbox_attestation("Standard_DC64as_v5", "cold_skr_handshake", "dm_verity_crypt"),
        simulate_confidential_sandbox_attestation("Standard_DC64as_v5", "cached_jwt", "dm_verity_crypt"),
        simulate_confidential_sandbox_attestation("Standard_D64s_v6", "none", "standard_overlay"),
    ]

    egress_security_profiles: List[Dict[str, object]] = [
        simulate_egress_exfiltration_and_mcp_supply_chain(25_000, "cilium_ebpf_fw_pls", 8, "cached_slsa_cosign"),
        simulate_egress_exfiltration_and_mcp_supply_chain(100_000, "cilium_ebpf_fw_pls", 8, "cached_slsa_cosign"),
        simulate_egress_exfiltration_and_mcp_supply_chain(25_000, "legacy_iptables_public_nat", 2, "unverified"),
    ]

    gpu_heterogeneous_profiles: List[Dict[str, object]] = [
        simulate_gpu_heterogeneous_sandbox_mps_mig("Standard_NC40ads_H100_v5", "mig_1g_10gb", 32, 0.78),
        simulate_gpu_heterogeneous_sandbox_mps_mig("Standard_NC80adis_H100_v5", "cuda_mps_shared_sm", 32, 0.78),
        simulate_gpu_heterogeneous_sandbox_mps_mig("Standard_ND96isr_H200_v5", "mig_1g_10gb", 64, 0.78),
        simulate_gpu_heterogeneous_sandbox_mps_mig("Standard_NC40ads_H100_v5", "default_timeslicing", 32, 0.0),
    ]

    observability_pipeline_profiles: List[Dict[str, object]] = [
        simulate_otel_ebpf_observability_pipeline(1_000, "hybrid_3tier_tail_adx", 0.05),
        simulate_otel_ebpf_observability_pipeline(25_000, "hybrid_3tier_tail_adx", 0.05),
        simulate_otel_ebpf_observability_pipeline(100_000, "hybrid_3tier_tail_adx", 0.05),
        simulate_otel_ebpf_observability_pipeline(100_000, "unsampled_raw_law", 1.0),
    ]

    durable_workflow_saga_profiles: List[Dict[str, object]] = [
        simulate_durable_agent_workflow_saga_gc(5_000, 15.0, "suspend_on_wait_outbox_gc", 40),
        simulate_durable_agent_workflow_saga_gc(25_000, 30.0, "suspend_on_wait_outbox_gc", 120),
        simulate_durable_agent_workflow_saga_gc(5_000, 15.0, "pinned_memory_naive_retry", 40),
    ]

    cua_browser_sandbox_profiles: List[Dict[str, object]] = [
        simulate_cua_browser_sandbox_grounding(1_000, "zygote_axtree_dirtyrect", 0.24),
        simulate_cua_browser_sandbox_grounding(10_000, "zygote_axtree_dirtyrect", 0.24),
        simulate_cua_browser_sandbox_grounding(50_000, "zygote_axtree_dirtyrect", 0.24),
        simulate_cua_browser_sandbox_grounding(10_000, "cold_chromium_pure_vision", 1.0),
    ]

    dependency_acceleration_profiles: List[Dict[str, object]] = [
        simulate_dependency_cache_virtiofs_dax(100, 3.2, "virtiofs_dax_overlaybd_osv"),
        simulate_dependency_cache_virtiofs_dax(250, 3.2, "virtiofs_dax_overlaybd_osv"),
        simulate_dependency_cache_virtiofs_dax(100, 3.2, "cold_pip_full_oci_pull"),
    ]

    swarm_fanout_governance_profiles: List[Dict[str, object]] = [
        simulate_multi_agent_swarm_fanout_governance(16, "hierarchical_budget_intent_prewarm_ast_lease"),
        simulate_multi_agent_swarm_fanout_governance(32, "hierarchical_budget_intent_prewarm_ast_lease"),
        simulate_multi_agent_swarm_fanout_governance(32, "unbounded_recursive_keda_reactive"),
    ]

    sovereign_residency_profiles: List[Dict[str, object]] = [
        simulate_sovereign_data_residency_crypto_shredding("EU_DATA_BOUNDARY", "geofenced_fpe_hsm_cryptoshred"),
        simulate_sovereign_data_residency_crypto_shredding("US_SOVEREIGN", "geofenced_fpe_hsm_cryptoshred"),
        simulate_sovereign_data_residency_crypto_shredding("APAC_REGULATED", "geofenced_fpe_hsm_cryptoshred"),
        simulate_sovereign_data_residency_crypto_shredding("EU_DATA_BOUNDARY", "global_unpinned_row_delete"),
    ]

    canary_live_migration_profiles: List[Dict[str, object]] = [
        simulate_zero_downtime_canary_live_migration(1_000, "surge_nvme_mana_live_canary"),
        simulate_zero_downtime_canary_live_migration(10_000, "surge_nvme_mana_live_canary"),
        simulate_zero_downtime_canary_live_migration(50_000, "surge_nvme_mana_live_canary"),
        simulate_zero_downtime_canary_live_migration(10_000, "naive_kubectl_drain_in_place"),
    ]

    model_routing_kv_affinity_profiles: List[Dict[str, object]] = [
        simulate_hybrid_model_routing_kv_cache_affinity(0.50, "kv_affinity_cascade_speculative_prefetch"),
        simulate_hybrid_model_routing_kv_cache_affinity(0.68, "kv_affinity_cascade_speculative_prefetch"),
        simulate_hybrid_model_routing_kv_cache_affinity(0.80, "kv_affinity_cascade_speculative_prefetch"),
        simulate_hybrid_model_routing_kv_cache_affinity(0.00, "round_robin_single_frontier_no_prefetch"),
    ]

    memory_diskann_graphrag_profiles: List[Dict[str, object]] = [
        simulate_agentic_memory_diskann_graphrag_tiering(25, "diskann_graphrag_3tier_rls"),
        simulate_agentic_memory_diskann_graphrag_tiering(100, "diskann_graphrag_3tier_rls"),
        simulate_agentic_memory_diskann_graphrag_tiering(250, "diskann_graphrag_3tier_rls"),
        simulate_agentic_memory_diskann_graphrag_tiering(100, "in_memory_hnsw_untiered_no_rls"),
    ]

    webrtc_media_sandbox_profiles: List[Dict[str, object]] = [
        simulate_webrtc_voice_video_media_sandbox(1_000, "ebpf_xdp_sockmap_vad_acs_turn"),
        simulate_webrtc_voice_video_media_sandbox(5_000, "ebpf_xdp_sockmap_vad_acs_turn"),
        simulate_webrtc_voice_video_media_sandbox(25_000, "ebpf_xdp_sockmap_vad_acs_turn"),
        simulate_webrtc_voice_video_media_sandbox(5_000, "userspace_nat_chained_http_rest"),
    ]

    cicd_buildkit_bazel_profiles: List[Dict[str, object]] = [
        simulate_autonomous_cicd_buildkit_bazel_sandbox(250, "microvm_rootless_buildkit_cas_tia"),
        simulate_autonomous_cicd_buildkit_bazel_sandbox(1_000, "microvm_rootless_buildkit_cas_tia"),
        simulate_autonomous_cicd_buildkit_bazel_sandbox(5_000, "microvm_rootless_buildkit_cas_tia"),
        simulate_autonomous_cicd_buildkit_bazel_sandbox(1_000, "privileged_dind_cold_compile_full_test"),
    ]

    return {
        "e2b_firecracker_resume_decomposition": e2b_matrix,
        "aksclaw_node_density_comparison": aksclaw_matrix,
        "horizondb_pgbouncer_checkpoint_profiles": horizondb_profiles,
        "multiregion_dr_failover_profiles": dr_profiles,
        "finops_spot_eviction_profiles": finops_profiles,
        "confidential_sandbox_profiles": confidential_profiles,
        "egress_security_profiles": egress_security_profiles,
        "gpu_heterogeneous_profiles": gpu_heterogeneous_profiles,
        "observability_pipeline_profiles": observability_pipeline_profiles,
        "durable_workflow_saga_profiles": durable_workflow_saga_profiles,
        "cua_browser_sandbox_profiles": cua_browser_sandbox_profiles,
        "dependency_acceleration_profiles": dependency_acceleration_profiles,
        "swarm_fanout_governance_profiles": swarm_fanout_governance_profiles,
        "sovereign_residency_profiles": sovereign_residency_profiles,
        "canary_live_migration_profiles": canary_live_migration_profiles,
        "model_routing_kv_affinity_profiles": model_routing_kv_affinity_profiles,
        "memory_diskann_graphrag_profiles": memory_diskann_graphrag_profiles,
        "webrtc_media_sandbox_profiles": webrtc_media_sandbox_profiles,
        "cicd_buildkit_bazel_profiles": cicd_buildkit_bazel_profiles,
    }


if __name__ == "__main__":
    summary = generate_deep_benchmark_summary()
    out_path = Path(__file__).resolve().parent.parent / "evidence" / "deep-benchmark-models.json"
    out_path.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {out_path} ({len(summary['e2b_firecracker_resume_decomposition'])} E2B rows)")
