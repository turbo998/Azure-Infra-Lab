"""Unit test suite for Data Lab (Microsoft Fabric x 4-Cloud Competitive Benchmark & Ontology Simulator)."""

from __future__ import annotations

import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))

from data_lab import (  # noqa: E402
    COMPETITIVE_DIMENSIONS,
    PLATFORMS,
    build_sealed_report,
    calculate_five_cloud_tco,
    evaluate_perturbation_robustness,
    evaluate_scaling_latency,
    evaluate_scenario_matrix,
    simulate_ontology_incident,
)


class TestDataLabBenchmarkSuite(unittest.TestCase):
    def test_five_platforms_and_six_dimensions_complete(self) -> None:
        expected_platforms = {"fabric", "databricks", "snowflake", "gcp", "aws"}
        self.assertEqual(set(PLATFORMS.keys()), expected_platforms)
        for pid, pdata in PLATFORMS.items():
            scores = pdata["scores"]
            for dim in COMPETITIVE_DIMENSIONS:
                self.assertIn(dim, scores, f"Missing dimension {dim} in {pid}")
                self.assertGreaterEqual(scores[dim], 0.0)
                self.assertLessEqual(scores[dim], 100.0)

    def test_fabric_leads_semantic_bi_and_databricks_leads_ml(self) -> None:
        self.assertGreater(
            PLATFORMS["fabric"]["scores"]["semantic_ontology_grounding"],
            PLATFORMS["databricks"]["scores"]["semantic_ontology_grounding"],
        )
        self.assertGreater(
            PLATFORMS["fabric"]["scores"]["bi_agentic_app_writeback"],
            PLATFORMS["snowflake"]["scores"]["bi_agentic_app_writeback"],
        )
        self.assertGreater(
            PLATFORMS["databricks"]["scores"]["ml_training_data_engineering"],
            PLATFORMS["fabric"]["scores"]["ml_training_data_engineering"],
        )

    def test_five_cloud_tco_calculator_invariants(self) -> None:
        tco = calculate_five_cloud_tco(
            users=500,
            storage_tb=100.0,
            streaming_eps=25000,
            copilot_queries_per_day=5000,
            m365_e5_or_copilot_licensed=True,
        )
        totals = tco["monthly_totals_usd"]
        self.assertEqual(tco["breakdown"]["fabric"]["ai_token_usd"], 0.0)
        self.assertEqual(tco["breakdown"]["fabric"]["bi_license_usd"], 0.0)
        self.assertLess(totals["fabric"], totals["databricks"])
        self.assertLess(totals["fabric"], totals["snowflake"])
        self.assertLess(totals["fabric"], totals["gcp"])
        self.assertLess(totals["fabric"], totals["aws"])
        self.assertGreater(tco["savings_vs_competitors_pct"]["vs_snowflake"], 35.0)

    def test_energy_dc_ontology_simulation_physics_and_guardrail(self) -> None:
        sim = simulate_ontology_incident("energy_dc_peak")
        self.assertEqual(sim["telemetry"]["initial_load_mw"], 18.84)
        self.assertEqual(sim["multi_agent_plan"]["total_shaved_mw"], 3.45)
        self.assertEqual(sim["multi_agent_plan"]["final_load_mw"], 15.39)
        self.assertLess(sim["multi_agent_plan"]["utilization_after_pct"], 80.0)
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")

    def test_airline_jfk_r25_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("airline_jfk_r25")
        self.assertLess(sim["telemetry"]["friction_coefficient"], sim["telemetry"]["min_safe_friction"])
        self.assertEqual(sim["multi_agent_plan"]["gates_reallocated"], 6)
        self.assertEqual(sim["decision_routing"]["action"], "Act automatically")

    def test_retail_cross_cloud_planning_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("retail_cross_cloud_planning")
        self.assertLess(sim["telemetry"]["days_of_supply_remaining"], sim["telemetry"]["min_safe_days_of_supply"])
        self.assertEqual(sim["multi_agent_plan"]["reallocated_units_from_de_south"], 4500)
        self.assertEqual(sim["multi_agent_plan"]["promo_budget_writeback_usd"], 185000)
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")

    def test_financial_multi_cloud_fraud_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("financial_multi_cloud_fraud")
        self.assertGreater(sim["telemetry"]["fraud_anomaly_score"], sim["telemetry"]["anomaly_threshold"])
        self.assertTrue(sim["telemetry"]["schema_drift_fixed_by_osmos"])
        self.assertEqual(sim["multi_agent_plan"]["payments_held_count"], 38)
        self.assertEqual(sim["multi_agent_plan"]["held_exposure_usd"], 4850000)
        self.assertTrue(sim["foundry_iq_guardrail"]["obo_identity_verified"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Act automatically")

    def test_finops_rayfin_observability_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("finops_rayfin_observability")
        self.assertGreater(
            sim["telemetry"]["capacity_utilization_before_pct"],
            sim["telemetry"]["throttle_threshold_pct"],
        )
        self.assertEqual(sim["telemetry"]["monitored_workspaces_count"], 18)
        self.assertEqual(sim["multi_agent_plan"]["capacity_utilization_after_pct"], 71.2)
        self.assertTrue(sim["foundry_iq_guardrail"]["private_by_default_verified"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Act automatically")

    def test_healthcare_clinical_supply_diskann_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("healthcare_clinical_supply_diskann")
        self.assertGreater(
            sim["telemetry"]["excursion_temp_c"],
            sim["telemetry"]["max_safe_temp_c"],
        )
        self.assertEqual(sim["telemetry"]["affected_biologic_vials"], 420)
        self.assertEqual(sim["telemetry"]["database_hub_monitored_dbs"], 64)
        self.assertEqual(sim["multi_agent_plan"]["patient_dosing_continuity_pct"], 100.0)
        self.assertTrue(sim["foundry_iq_guardrail"]["auto_administer_excursed_lot_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")

    def test_manufacturing_digital_twin_zeroprov_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("manufacturing_digital_twin_zeroprov")
        self.assertGreater(
            sim["telemetry"]["overlay_drift_nm"],
            sim["telemetry"]["max_safe_overlay_nm"],
        )
        self.assertEqual(sim["telemetry"]["at_risk_300mm_wafers"], 75)
        self.assertEqual(sim["telemetry"]["zero_provisioned_burst_cu"], 24)
        self.assertEqual(sim["multi_agent_plan"]["wafer_yield_preserved_pct"], 99.4)
        self.assertTrue(sim["foundry_iq_guardrail"]["unverified_plc_firmware_flash_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["private_link_cmk_verified"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")

    def test_supply_chain_iq_sharing_salesforce_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("supply_chain_iq_sharing_salesforce")
        self.assertGreater(
            sim["telemetry"]["port_delay_hours"],
            sim["telemetry"]["max_safe_delay_hours"],
        )
        self.assertEqual(sim["telemetry"]["impacted_enterprise_accounts"], 42)
        self.assertEqual(sim["telemetry"]["affected_rack_orders"], 1280)
        self.assertEqual(sim["multi_agent_plan"]["on_time_delivery_preserved_pct"], 99.6)
        self.assertTrue(sim["foundry_iq_guardrail"]["purview_confidential_net_price_masked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["external_partner_raw_crm_leak_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")

    def test_scenario_matrix_48_cases_and_explicit_miss(self) -> None:
        matrix = evaluate_scenario_matrix()
        self.assertEqual(matrix["total_scenarios"], 48)
        self.assertEqual(matrix["passed_scenarios"], 47)
        self.assertEqual(matrix["failed_scenarios"], 1)
        self.assertAlmostEqual(matrix["accuracy_pct"], 97.92, places=2)
        misses = [s for s in matrix["scenarios"] if not s["correct"]]
        self.assertEqual(len(misses), 1)
        self.assertEqual(misses[0]["id"], "DL-23")

    def test_ltap_and_cross_cloud_2026_11_02_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-25", "DL-26", "DL-27", "DL-28"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Lakebase", by_id["DL-25"]["expected"])
        self.assertIn("Fabric IQ Planning", by_id["DL-26"]["expected"])
        self.assertIn("OneLake Fine-Grained Security", by_id["DL-27"]["expected"])
        self.assertIn("Apache Ossie", by_id["DL-28"]["expected"])

    def test_osmos_obo_ossie_and_borderless_iceberg_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-29", "DL-30", "DL-31", "DL-32"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Project Osmos", by_id["DL-29"]["expected"])
        self.assertIn("Agent Bricks Supervisor", by_id["DL-30"]["expected"])
        self.assertIn("Apache Ossie YAML", by_id["DL-31"]["expected"])
        self.assertIn("Outbound Access Protection", by_id["DL-32"]["expected"])

    def test_rayfin_observability_objectrefs_graphrag_2026_11_04_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-33", "DL-34", "DL-35", "DL-36"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Rayfin SDK", by_id["DL-33"]["expected"])
        self.assertIn("Single Eventhouse", by_id["DL-34"]["expected"])
        self.assertIn("Fabric IQ Ontology Graph", by_id["DL-35"]["expected"])
        self.assertIn("Zero-Provisioned", by_id["DL-36"]["expected"])

    def test_database_hub_diskann_lakebase_scann_unistore_2026_11_05_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-37", "DL-38", "DL-39", "DL-40"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Database Hub", by_id["DL-37"]["expected"])
        self.assertIn("DiskANN", by_id["DL-38"]["expected"])
        self.assertIn("OneLake BigQuery/Oracle Mirroring", by_id["DL-39"]["expected"])
        self.assertIn("Hybrid Table credit premium", by_id["DL-40"]["expected"])

    def test_digital_twin_builder_zeroprov_streaming_2026_11_06_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-41", "DL-42", "DL-43", "DL-44"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Digital Twin Builder", by_id["DL-41"]["expected"])
        self.assertIn("Zero-Provisioned", by_id["DL-42"]["expected"])
        self.assertIn("Eventstream/Eventhouse", by_id["DL-43"]["expected"])
        self.assertIn("OneLake S3 Shortcut", by_id["DL-44"]["expected"])

    def test_iq_sharing_opensharing_salesforce_sovereign_2026_11_08_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-45", "DL-46", "DL-47", "DL-48"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("OneLake IQ Sharing", by_id["DL-45"]["expected"])
        self.assertIn("Apache Ossie YAML", by_id["DL-46"]["expected"])
        self.assertIn("Salesforce Data 360 Shortcut", by_id["DL-47"]["expected"])
        self.assertIn("SQL Server on Azure Local", by_id["DL-48"]["expected"])

    def test_perturbation_and_scaling_latency(self) -> None:
        pert = evaluate_perturbation_robustness()
        self.assertEqual(len(pert), 6)
        # First 5 governed ontology cases have <= 0.5 pt drift
        for row in pert[:5]:
            self.assertLessEqual(abs(row["change_pts"]), 0.5)
        scaling = evaluate_scaling_latency()
        self.assertEqual(len(scaling), 4)
        for tier in scaling:
            self.assertGreater(tier["speedup_x"], 4.0)

    def test_sealed_report_persistence(self) -> None:
        out_path = ROOT / "reports" / "report.json"
        report = build_sealed_report(out_path)
        self.assertTrue(out_path.exists())
        loaded = json.loads(out_path.read_text(encoding="utf-8"))
        self.assertEqual(loaded["report_id"], report["report_id"])
        self.assertEqual(loaded["scenario_evaluation"]["passed_scenarios"], 47)
        self.assertIn("retail_cross_cloud_planning", loaded["ontology_simulations"])
        self.assertIn("financial_multi_cloud_fraud", loaded["ontology_simulations"])
        self.assertIn("finops_rayfin_observability", loaded["ontology_simulations"])
        self.assertIn("healthcare_clinical_supply_diskann", loaded["ontology_simulations"])
        self.assertIn("manufacturing_digital_twin_zeroprov", loaded["ontology_simulations"])
        self.assertIn("supply_chain_iq_sharing_salesforce", loaded["ontology_simulations"])


if __name__ == "__main__":
    unittest.main()
