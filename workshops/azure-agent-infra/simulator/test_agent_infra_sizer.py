#!/usr/bin/env python3
"""Unit tests for the Azure AI Agent Infrastructure Playbook sizer and decision engine."""

from __future__ import annotations

import unittest
from pathlib import Path

from agent_infra_sizer import (
    E2B_VM_BENCHMARKS,
    RUNTIMES,
    SCENARIOS_12,
    build_report_payload,
    calculate_e2b_vmss_cluster_sizing,
    recommend_runtime,
    simulate_confidential_sandbox_attestation,
    simulate_cua_browser_sandbox_grounding,
    simulate_dependency_cache_virtiofs_dax,
    simulate_durable_agent_workflow_saga_gc,
    simulate_egress_exfiltration_and_mcp_supply_chain,
    simulate_finops_spot_eviction_drain,
    simulate_gpu_heterogeneous_sandbox_mps_mig,
    simulate_multi_agent_swarm_fanout_governance,
    simulate_multiregion_dr_failover,
    simulate_otel_ebpf_observability_pipeline,
    simulate_sovereign_data_residency_crypto_shredding,
    simulate_zero_downtime_canary_live_migration,
)
from e2b_aksclaw_deep_benchmark import (
    decompose_e2b_firecracker_resume,
    evaluate_aksclaw_node_density,
    evaluate_horizondb_checkpoint_slo,
)


class TestAgentInfraSizer(unittest.TestCase):
    def test_six_canonical_runtimes_present(self) -> None:
        self.assertEqual(len(RUNTIMES), 6)
        self.assertLess(
            RUNTIMES["foundry_hosted_agents"].ops_responsibility_score,
            RUNTIMES["e2b_on_azure_vmss"].ops_responsibility_score,
        )

    def test_e2b_startup_benchmarks_match_deck(self) -> None:
        by_sku = {row["sku"]: row for row in E2B_VM_BENCHMARKS}
        self.assertEqual(by_sku["Standard_D96s_v6"]["base_sandbox_startup_ms"], 116)
        self.assertEqual(by_sku["Standard_D96s_v6"]["code_interpreter_v1_startup_ms"], 159)
        self.assertEqual(by_sku["Standard_D96s_v6"]["linux_ondemand_hourly_usd"], 4.838)
        self.assertEqual(by_sku["Standard_D96as_v6"]["base_sandbox_startup_ms"], 239)
        self.assertEqual(by_sku["Standard_D96as_v6"]["code_interpreter_v1_startup_ms"], 255)
        self.assertEqual(by_sku["Standard_D96as_v7"]["base_sandbox_startup_ms"], 108)
        self.assertEqual(by_sku["Standard_D96as_v7"]["code_interpreter_v1_startup_ms"], 132)

    def test_decision_tree_blocks_unmet_control_without_dev_team(self) -> None:
        res = recommend_runtime(
            audience="To-B",
            needs_infra_control_beyond_managed=True,
            has_dedicated_dev_team=False,
            executes_untrusted_code=True,
            needs_stateful_workspace_pause_resume=False,
            needs_long_approval_workflow=False,
            concurrent_sandboxes=100,
            requires_sub_150ms_microvm=False,
            existing_k8s_platform=False,
        )
        self.assertEqual(res["primary_runtime"], "partner_or_csu_enablement_first")
        self.assertIn("Blocked", res["delivery_gate"])

    def test_decision_tree_routes_100k_sandboxes_to_e2b_vmss(self) -> None:
        res = recommend_runtime(
            audience="To-C",
            needs_infra_control_beyond_managed=True,
            has_dedicated_dev_team=True,
            executes_untrusted_code=True,
            needs_stateful_workspace_pause_resume=True,
            needs_long_approval_workflow=False,
            concurrent_sandboxes=100_000,
            requires_sub_150ms_microvm=True,
            existing_k8s_platform=False,
        )
        self.assertEqual(res["primary_runtime"], "e2b_on_azure_vmss")

    def test_decision_tree_routes_multi_tenant_k8s_to_aksclaw(self) -> None:
        res = recommend_runtime(
            audience="To-B",
            needs_infra_control_beyond_managed=True,
            has_dedicated_dev_team=True,
            executes_untrusted_code=True,
            needs_stateful_workspace_pause_resume=True,
            needs_long_approval_workflow=False,
            concurrent_sandboxes=800,
            requires_sub_150ms_microvm=False,
            existing_k8s_platform=True,
        )
        self.assertEqual(res["primary_runtime"], "aks_kata_aksclaw")

    def test_100k_sizing_fits_vmss_flexible_limit(self) -> None:
        sizing = calculate_e2b_vmss_cluster_sizing(100_000)
        self.assertTrue(sizing["fits_single_vmss_flexible"])
        self.assertLessEqual(sizing["client_pool_vmss_nodes"], 1000)
        self.assertGreaterEqual(sizing["client_pool_vmss_nodes"], 200)

    def test_report_payload_integrity(self) -> None:
        payload = build_report_payload()
        self.assertEqual(len(SCENARIOS_12), 12)
        self.assertEqual(payload["summary_metrics"]["scenarios_auto_or_confirm"], 9)
        self.assertEqual(payload["summary_metrics"]["failure_boundaries_caught"], 3)
        self.assertEqual(len(payload["sha256"]), 64)

    def test_bundle_assets_and_h5_suite(self) -> None:
        import xml.etree.ElementTree as ET
        bundle_dir = Path(__file__).resolve().parent.parent
        svg_files = sorted((bundle_dir / "assets").glob("*.svg"))
        self.assertEqual(len(svg_files), 8)
        for svg in svg_files:
            ET.fromstring(svg.read_text(encoding="utf-8"))
        for h5_name in ("index.html", "demo.html", "selector.html", "cards.html"):
            p = bundle_dir / "h5" / h5_name
            self.assertTrue(p.exists(), f"Missing H5 file {h5_name}")
            self.assertGreater(p.stat().st_size, 20_000)
        for doc_name in (
            "README.md",
            "workshop-runbook.md",
            "test-report.md",
            "test-report-cards.html",
            "report.json",
            "evidence.json",
            "review.md",
        ):
            self.assertTrue((bundle_dir / doc_name).exists(), f"Missing {doc_name}")
        for bp_name in (
            "aksclaw-kata-fleet.yaml",
            "e2b-apim-per-host-policy.xml",
            "e2b-vmss-d96as-v7.bicep",
            "horizondb-langgraph-checkpointer.py",
            "aca-dynamic-sessions-pool.bicep",
            "entra-agent-id-ai-gateway-policy.xml",
        ):
            bp_path = bundle_dir / "blueprints" / bp_name
            self.assertTrue(bp_path.exists(), f"Missing blueprint {bp_name}")
            self.assertGreater(bp_path.stat().st_size, 500)

    def test_e2b_firecracker_resume_decomposition(self) -> None:
        d96_single = decompose_e2b_firecracker_resume("Standard_D96as_v7", 1)
        d96_burst = decompose_e2b_firecracker_resume("Standard_D96as_v7", 50)
        d32_burst = decompose_e2b_firecracker_resume("Standard_D32s_v6", 50)
        self.assertEqual(d96_single.total_latency_ms, 108.0)
        self.assertEqual(d96_burst.total_latency_ms, 132.0)
        self.assertLess(d96_burst.total_latency_ms, d32_burst.total_latency_ms)
        self.assertAlmostEqual(
            d96_single.vmm_socket_init_ms
            + d96_single.uffd_hot_pages_ms
            + d96_single.nbd_rootfs_meta_ms
            + d96_single.network_tap_nat_ms,
            108.0,
            places=2,
        )

    def test_aksclaw_node_density_kata_vs_runc(self) -> None:
        kata = evaluate_aksclaw_node_density("Standard_D64s_v6", 64, 256, "kata-vm-isolation")
        runc = evaluate_aksclaw_node_density("Standard_D64s_v6", 64, 256, "runc-shared-kernel")
        self.assertEqual(kata.kata_vmm_overhead_mib, 144)
        self.assertEqual(runc.kata_vmm_overhead_mib, 0)
        self.assertGreaterEqual(runc.max_sandboxes_by_ram, kata.max_sandboxes_by_ram)

    def test_horizondb_pgbouncer_checkpoint_slo(self) -> None:
        profile = evaluate_horizondb_checkpoint_slo(10000, 6.0, 200)
        self.assertEqual(profile.total_qps, 1000.0)
        self.assertEqual(profile.connection_reduction_ratio, 50.0)
        self.assertTrue(profile.fits_128tb_with_30d_retention)
        self.assertTrue(profile.exceeds_128tb_without_compaction)
        self.assertLess(profile.end_to_end_checkpoint_p95_ms, 20.0)

    def test_markdown_relative_links_resolve(self) -> None:
        import re
        import urllib.parse

        bundle_dir = Path(__file__).resolve().parent.parent
        for md_file in bundle_dir.rglob("*.md"):
            text = md_file.read_text(encoding="utf-8")
            text = re.sub(r"```.*?```", "", text, flags=re.S)
            for link in re.findall(r"\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)", text):
                parsed = urllib.parse.urlsplit(link)
                if not parsed.scheme and not parsed.netloc and parsed.path:
                    target = (md_file.parent / urllib.parse.unquote(parsed.path)).resolve()
                    self.assertTrue(
                        target.exists(),
                        f"Broken relative link in {md_file.relative_to(bundle_dir)}: {link}",
                    )

    def test_live_demo_self_test_and_trace_integrity(self) -> None:
        import json
        import subprocess
        import sys

        bundle_dir = Path(__file__).resolve().parent.parent
        demo_script = bundle_dir / "demo" / "run_live_demo.py"
        proc = subprocess.run(
            [sys.executable, str(demo_script), "--self-test"],
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertIn("DEMO VERIFICATION", proc.stdout)
        trace_path = bundle_dir / "demo" / "latest-demo-trace.json"
        trace = json.loads(trace_path.read_text(encoding="utf-8"))
        for key in (
            "demo_1_aksclaw",
            "demo_2_e2b_vmss",
            "demo_3_multi_agent",
            "demo_4_deep_models",
            "demo_5_multiregion_dr",
            "demo_6_finops_spot_drain",
            "demo_7_confidential_attestation",
            "demo_8_zero_trust_egress_and_mcp_attestation",
            "demo_9_gpu_mig_mps_kaito_sizing",
            "trace_sha256",
        ):
            self.assertIn(key, trace)
        self.assertEqual(len(trace["demo_4_deep_models"]["e2b_firecracker_resume_decomposition"]), 12)

    def test_multiregion_dr_failover_warm_vs_cold(self) -> None:
        warm = simulate_multiregion_dr_failover("eastus2_centralus", 10_000, 32.0, 15, 0.25)
        cold = simulate_multiregion_dr_failover("eastus2_centralus", 10_000, 32.0, 15, 0.05)
        eu = simulate_multiregion_dr_failover("swedencentral_westeurope", 10_000, 32.0, 15, 0.25)
        self.assertTrue(warm["meets_5s_warm_dr_slo"])
        self.assertLess(warm["total_failover_rto_sec"], 5.0)
        self.assertFalse(cold["meets_5s_warm_dr_slo"])
        self.assertGreater(cold["total_failover_rto_sec"], 30.0)
        self.assertGreater(eu["inter_region_rtt_ms"], warm["inter_region_rtt_ms"])

    def test_finops_spot_eviction_drain_and_chargeback(self) -> None:
        inc = simulate_finops_spot_eviction_drain(100_000, 0.60, 32.0, True, 30.0, 0.65)
        raw = simulate_finops_spot_eviction_drain(100_000, 0.60, 32.0, False, 30.0, 0.0)
        self.assertTrue(inc["survives_30s_spot_notice"])
        self.assertLess(inc["total_node_drain_sec"], 5.0)
        self.assertFalse(raw["survives_30s_spot_notice"])
        self.assertGreater(raw["total_node_drain_sec"], 30.0)
        self.assertGreater(inc["net_compute_savings_pct"], 40.0)
        self.assertLess(inc["total_cost_per_1k_tasks_usd"], raw["total_cost_per_1k_tasks_usd"])

    def test_confidential_sandbox_attestation_skr(self) -> None:
        cold = simulate_confidential_sandbox_attestation("Standard_DC64as_v5", "cold_skr_handshake", "dm_verity_crypt")
        cached = simulate_confidential_sandbox_attestation("Standard_DC64as_v5", "cached_jwt", "dm_verity_crypt")
        std = simulate_confidential_sandbox_attestation("Standard_D64s_v6", "none", "standard_overlay")
        self.assertTrue(cold["is_confidential_sev_snp"])
        self.assertTrue(cold["host_root_memory_dump_blocked"])
        self.assertFalse(std["host_root_memory_dump_blocked"])
        self.assertEqual(cold["effective_sandboxes_per_node"], 106)
        self.assertEqual(std["effective_sandboxes_per_node"], 109)
        self.assertLess(cached["end_to_end_boot_ms"], cold["end_to_end_boot_ms"])
        self.assertTrue(cold["meets_220ms_confidential_slo"])

    def test_egress_exfiltration_and_mcp_supply_chain(self) -> None:
        zt = simulate_egress_exfiltration_and_mcp_supply_chain(25_000, "cilium_ebpf_fw_pls", 8, "cached_slsa_cosign")
        legacy = simulate_egress_exfiltration_and_mcp_supply_chain(25_000, "legacy_iptables_public_nat", 2, "unverified")
        self.assertLess(zt["l1_policy_latency_ms"], 0.08)
        self.assertGreater(legacy["l1_policy_latency_ms"], 1.5)
        self.assertAlmostEqual(zt["dns_tunnel_block_rate_pct"], 99.94)
        self.assertTrue(zt["snat_exhaustion_safe"])
        self.assertFalse(legacy["snat_exhaustion_safe"])
        self.assertTrue(zt["unsigned_mcp_blocked"])
        self.assertFalse(legacy["unsigned_mcp_blocked"])
        self.assertLess(zt["net_egress_rtt_delta_ms"], 0.0)

    def test_gpu_heterogeneous_sandbox_mps_mig(self) -> None:
        mig = simulate_gpu_heterogeneous_sandbox_mps_mig("Standard_NC40ads_H100_v5", "mig_1g_10gb", 32, 0.78)
        mps = simulate_gpu_heterogeneous_sandbox_mps_mig("Standard_NC80adis_H100_v5", "cuda_mps_shared_sm", 32, 0.78)
        ts = simulate_gpu_heterogeneous_sandbox_mps_mig("Standard_NC40ads_H100_v5", "default_timeslicing", 32, 0.0)
        self.assertTrue(mig["hardware_fault_isolated"])
        self.assertEqual(mig["cross_tenant_jitter_pct"], 0.0)
        self.assertEqual(mig["slices_per_gpu"], 7)
        self.assertAlmostEqual(mps["throughput_gain_vs_timeslicing_pct"], 28.4)
        self.assertLess(mps["grounding_p95_ms"], ts["grounding_p95_ms"])
        self.assertAlmostEqual(mig["effective_ttft_ms"], 42.0)
        self.assertAlmostEqual(mig["ttft_reduction_pct"], 77.3)
        self.assertLess(mig["total_cost_per_10k_trajectories_usd"], ts["total_cost_per_10k_trajectories_usd"])

    def test_otel_ebpf_observability_pipeline(self) -> None:
        hybrid = simulate_otel_ebpf_observability_pipeline(100_000, "hybrid_3tier_tail_adx", 0.05)
        raw = simulate_otel_ebpf_observability_pipeline(100_000, "unsampled_raw_law", 1.0)
        self.assertAlmostEqual(hybrid["raw_ingest_gbps"], 4.85)
        self.assertAlmostEqual(hybrid["raw_daily_tb"], 419.0)
        self.assertTrue(hybrid["cpu_overhead_within_slo"])
        self.assertFalse(raw["cpu_overhead_within_slo"])
        self.assertAlmostEqual(hybrid["host_ebpf_cpu_overhead_pct"], 0.95)
        self.assertAlmostEqual(hybrid["volume_reduction_pct"], 91.6)
        self.assertAlmostEqual(hybrid["cost_per_1k_tasks_usd"], 0.42)
        self.assertAlmostEqual(raw["cost_per_1k_tasks_usd"], 3.62)
        self.assertAlmostEqual(hybrid["cost_reduction_pct"], 88.4)
        self.assertAlmostEqual(hybrid["security_alert_p95_sec"], 1.8)

    def test_durable_agent_workflow_saga_gc(self) -> None:
        opt = simulate_durable_agent_workflow_saga_gc(5_000, 15.0, "suspend_on_wait_outbox_gc", 40)
        naive = simulate_durable_agent_workflow_saga_gc(5_000, 15.0, "pinned_memory_naive_retry", 40)
        self.assertAlmostEqual(opt["pinned_idle_waste_pct"], 94.2)
        self.assertAlmostEqual(opt["pinned_daily_cost_usd"], 1420.0)
        self.assertAlmostEqual(opt["effective_daily_cost_usd"], 146.2)
        self.assertAlmostEqual(opt["ram_residency_reduction_pct"], 89.7)
        self.assertAlmostEqual(opt["cost_savings_pct"], 89.7)
        self.assertAlmostEqual(opt["rehydration_latency_ms"], 188.0)
        self.assertTrue(opt["exactly_once_guaranteed"])
        self.assertFalse(naive["exactly_once_guaranteed"])
        self.assertEqual(opt["duplicate_side_effect_pct"], 0.0)
        self.assertAlmostEqual(naive["duplicate_side_effect_pct"], 4.8)
        self.assertAlmostEqual(opt["zombie_reap_latency_sec"], 4.5)
        self.assertAlmostEqual(naive["zombie_ram_leak_pct"], 18.0)

    def test_cua_browser_sandbox_grounding(self) -> None:
        opt = simulate_cua_browser_sandbox_grounding(10_000, "zygote_axtree_dirtyrect", 0.24)
        cold = simulate_cua_browser_sandbox_grounding(10_000, "cold_chromium_pure_vision", 1.0)
        self.assertAlmostEqual(opt["per_sandbox_pss_mib"], 310.0)
        self.assertAlmostEqual(opt["memory_reduction_pct"], 62.2)
        self.assertAlmostEqual(opt["sandbox_2gib_headroom_gib"], 1.7)
        self.assertAlmostEqual(opt["first_tab_ready_ms"], 68.0)
        self.assertAlmostEqual(opt["stream_mbps_per_sandbox"], 0.62)
        self.assertAlmostEqual(opt["bandwidth_reduction_pct"], 95.6)
        self.assertAlmostEqual(opt["som_vision_token_reduction_pct"], 58.4)
        self.assertAlmostEqual(opt["task_15step_latency_sec"], 7.9)
        self.assertAlmostEqual(opt["latency_reduction_pct"], 72.2)
        self.assertAlmostEqual(opt["cost_per_15step_task_usd"], 0.013)
        self.assertAlmostEqual(opt["cost_reduction_pct"], 72.9)
        self.assertTrue(opt["oom_kill_protected"])
        self.assertFalse(cold["oom_kill_protected"])

    def test_dependency_cache_virtiofs_dax(self) -> None:
        dax = simulate_dependency_cache_virtiofs_dax(100, 3.2, "virtiofs_dax_overlaybd_osv")
        cold = simulate_dependency_cache_virtiofs_dax(100, 3.2, "cold_pip_full_oci_pull")
        self.assertAlmostEqual(dax["pkg_install_ready_ms"], 38.0)
        self.assertAlmostEqual(dax["pkg_install_reduction_pct"], 99.8)
        self.assertAlmostEqual(dax["dax_ram_saved_gib"], 42.8)
        self.assertAlmostEqual(dax["oci_boot_latency_sec"], 0.95)
        self.assertAlmostEqual(dax["oci_boot_reduction_pct"], 95.1)
        self.assertAlmostEqual(dax["hot_block_fetch_ratio_pct"], 4.2)
        self.assertAlmostEqual(dax["osv_scan_overhead_ms"], 14.0)
        self.assertEqual(dax["malicious_hook_block_rate_pct"], 100.0)
        self.assertTrue(dax["supply_chain_protected"])
        self.assertFalse(cold["supply_chain_protected"])

    def test_multi_agent_swarm_fanout_governance(self) -> None:
        gov = simulate_multi_agent_swarm_fanout_governance(32, "hierarchical_budget_intent_prewarm_ast_lease")
        unb = simulate_multi_agent_swarm_fanout_governance(32, "unbounded_recursive_keda_reactive")
        self.assertEqual(gov["max_depth"], 2)
        self.assertEqual(gov["max_fanout_per_node"], 16)
        self.assertAlmostEqual(gov["redundant_token_savings_pct"], 63.8)
        self.assertAlmostEqual(gov["prewarm_lead_time_ms"], 800.0)
        self.assertAlmostEqual(gov["warm_pool_hit_rate_pct"], 99.4)
        self.assertAlmostEqual(gov["subagent_spawn_p95_ms"], 185.0)
        self.assertLess(gov["deadlock_detection_latency_ms"], 2.5)
        self.assertAlmostEqual(gov["merge_conflict_rollback_rate_pct"], 0.4)
        self.assertTrue(gov["swarm_governed"])
        self.assertAlmostEqual(unb["token_amplification_factor"], 14.6)
        self.assertAlmostEqual(unb["warm_pool_hit_rate_pct"], 32.0)
        self.assertAlmostEqual(unb["merge_conflict_rollback_rate_pct"], 29.4)
        self.assertFalse(unb["swarm_governed"])

    def test_sovereign_data_residency_crypto_shredding(self) -> None:
        sov = simulate_sovereign_data_residency_crypto_shredding("EU_DATA_BOUNDARY", "geofenced_fpe_hsm_cryptoshred")
        unp = simulate_sovereign_data_residency_crypto_shredding("EU_DATA_BOUNDARY", "global_unpinned_row_delete")
        self.assertAlmostEqual(sov["apim_geofence_overhead_ms"], 0.35)
        self.assertAlmostEqual(sov["cross_border_spillover_rate_pct"], 0.0)
        self.assertAlmostEqual(sov["in_boundary_availability_pct"], 99.99)
        self.assertAlmostEqual(sov["fpe_tokenization_latency_ms"], 3.8)
        self.assertAlmostEqual(sov["external_saas_plaintext_pii_exposure_pct"], 0.0)
        self.assertAlmostEqual(sov["crypto_shred_purge_sec"], 1.45)
        self.assertEqual(sov["residual_readable_bytes"], 0)
        self.assertTrue(sov["sovereign_compliant"])
        self.assertAlmostEqual(unp["cross_border_spillover_rate_pct"], 14.2)
        self.assertAlmostEqual(unp["baseline_row_delete_sec"], 15120.0)
        self.assertFalse(unp["sovereign_compliant"])

    def test_zero_downtime_canary_live_migration(self) -> None:
        can = simulate_zero_downtime_canary_live_migration(10_000, "surge_nvme_mana_live_canary")
        naive = simulate_zero_downtime_canary_live_migration(10_000, "naive_kubectl_drain_in_place")
        self.assertEqual(can["max_surge_pct"], 33)
        self.assertAlmostEqual(can["nvme_prewarm_duration_sec"], 42.0)
        self.assertAlmostEqual(can["upgrade_window_p95_ms"], 172.0)
        self.assertLessEqual(can["upgrade_window_p95_ms"], 220.0)
        self.assertAlmostEqual(can["live_migration_freeze_ms"], 340.0)
        self.assertLess(can["live_migration_freeze_ms"], 500.0)
        self.assertAlmostEqual(can["active_task_disruption_rate_pct"], 0.0)
        self.assertAlmostEqual(can["canary_rollback_latency_sec"], 8.5)
        self.assertLess(can["blast_radius_sessions_pct"], 1.0)
        self.assertTrue(can["zero_downtime_slo_met"])
        self.assertAlmostEqual(naive["upgrade_window_p95_ms"], 6420.0)
        self.assertAlmostEqual(naive["active_task_disruption_rate_pct"], 22.4)
        self.assertFalse(naive["zero_downtime_slo_met"])


if __name__ == "__main__":
    unittest.main()
