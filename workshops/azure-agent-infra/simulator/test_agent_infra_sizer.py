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
        for doc_name in ("README.md", "test-report.md", "test-report-cards.html", "report.json", "evidence.json", "review.md"):
            self.assertTrue((bundle_dir / doc_name).exists(), f"Missing {doc_name}")


if __name__ == "__main__":
    unittest.main()
