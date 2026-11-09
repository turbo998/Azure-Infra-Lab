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

    def test_telecom_5g_eventhouse_vs_dynamic_tables_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("telecom_5g_eventhouse_vs_dynamic_tables")
        self.assertGreater(
            sim["telemetry"]["slice_jitter_ms"],
            sim["telemetry"]["max_sla_jitter_ms"],
        )
        self.assertEqual(sim["telemetry"]["streaming_ingest_eps"], 120000)
        self.assertEqual(sim["telemetry"]["impacted_enterprise_slices"], 18500)
        self.assertEqual(sim["multi_agent_plan"]["jitter_after_reroute_ms"], 1.15)
        self.assertTrue(sim["foundry_iq_guardrail"]["e911_emergency_voice_slice_protected"])
        self.assertTrue(sim["foundry_iq_guardrail"]["unverified_bgp_blackhole_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Act automatically")

    def test_core_banking_oracle_open_mirroring_cdc_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("core_banking_oracle_open_mirroring_cdc")
        self.assertEqual(sim["telemetry"]["fabric_mirroring_replication_compute_cost_usd"], 0)
        self.assertEqual(sim["telemetry"]["oltp_change_rate_tps"], 48000)
        self.assertEqual(sim["multi_agent_plan"]["cdc_pipeline_monthly_tco_saved_usd"], 11400)
        self.assertTrue(sim["foundry_iq_guardrail"]["pan_cvv_column_level_masked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["retail_payroll_account_freeze_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")

    def test_omni_channel_snowflake_iceberg_onelake_xtable_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("omni_channel_snowflake_iceberg_onelake_xtable")
        self.assertEqual(sim["telemetry"]["active_skus_evaluated"], 85000)
        self.assertEqual(sim["telemetry"]["onelake_xtable_metadata_translation_ms"], 14)
        self.assertEqual(sim["multi_agent_plan"]["format_conversion_compute_cost_usd"], 0)
        self.assertTrue(sim["foundry_iq_guardrail"]["minimum_advertised_price_floor_enforced"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Act automatically")
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 1620000)

    def test_wealth_advisory_htap_diskann_vs_lakebase_unistore_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("wealth_advisory_htap_diskann_vs_lakebase_unistore")
        self.assertEqual(sim["telemetry"]["indexed_compliance_vectors_millions"], 120)
        self.assertEqual(sim["telemetry"]["diskann_ssd_vector_search_ms"], 16)
        self.assertEqual(sim["telemetry"]["ram_saved_vs_hnsw_pct"], 92.0)
        self.assertEqual(sim["multi_agent_plan"]["vector_htap_monthly_tco_saved_usd"], 8640)
        self.assertTrue(sim["foundry_iq_guardrail"]["retail_leveraged_etf_auto_buy_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Act automatically")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 450)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 1950000)

    def test_sovereign_healthcare_obo_purview_vs_uc_abac_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("sovereign_healthcare_obo_purview_vs_uc_abac")
        self.assertEqual(sim["telemetry"]["enrolled_trial_patients"], 145000)
        self.assertEqual(sim["telemetry"]["governed_engines_enforced_from_single_policy"], 5)
        self.assertEqual(sim["telemetry"]["obo_token_validation_and_rls_eval_ms"], 11)
        self.assertEqual(sim["telemetry"]["service_principal_unauthorized_row_leak_pct"], 0.0)
        self.assertEqual(sim["multi_agent_plan"]["governance_ops_monthly_tco_saved_usd"], 7880)
        self.assertTrue(sim["foundry_iq_guardrail"]["service_principal_super_token_rejected"])
        self.assertTrue(sim["foundry_iq_guardrail"]["unmasked_genomic_sequence_export_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 431)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 2800000)

    def test_auto_telematics_gluten_velox_autoscale_vs_photon_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("auto_telematics_gluten_velox_autoscale_vs_photon")
        self.assertEqual(sim["telemetry"]["connected_evs_monitored"], 2400000)
        self.assertEqual(sim["telemetry"]["daily_parquet_compaction_tb"], 60.0)
        self.assertEqual(sim["telemetry"]["gluten_velox_vectorized_speedup_x"], 2.8)
        self.assertEqual(sim["telemetry"]["native_engine_extra_cu_surcharge_usd"], 0)
        self.assertEqual(sim["multi_agent_plan"]["monthly_spark_finops_saved_usd"], 8680)
        self.assertTrue(sim["foundry_iq_guardrail"]["in_motion_highway_power_cutoff_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["driver_consent_ota_notification_enforced"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 422)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 2450000)

    def test_global_pharma_fabric_data_agent_vs_genie_cortex_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("global_pharma_fabric_data_agent_vs_genie_cortex")
        self.assertEqual(sim["telemetry"]["enterprise_business_users"], 2500)
        self.assertEqual(sim["telemetry"]["semantic_metric_hallucination_drift_pct"], 0.0)
        self.assertEqual(sim["telemetry"]["affected_biologics_lots"], 11)
        self.assertEqual(sim["multi_agent_plan"]["monthly_agentic_bi_seat_tco_saved_usd"], 10800)
        self.assertTrue(sim["foundry_iq_guardrail"]["unverified_llm_metric_sql_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["unapproved_lot_auto_release_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 417)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 3150000)

    def test_retail_supply_osmos_medallion_healing_vs_lakeflow_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("retail_supply_osmos_medallion_healing_vs_lakeflow")
        self.assertEqual(sim["telemetry"]["upstream_breaking_schema_changes_detected"], 3)
        self.assertEqual(sim["telemetry"]["autonomous_pr_generation_and_unit_test_sec"], 38)
        self.assertEqual(sim["telemetry"]["monthly_pipeline_ops_and_orchestration_tco_usd"], 4850)
        self.assertEqual(sim["multi_agent_plan"]["healed_medallion_notebooks_and_views"], 3)
        self.assertEqual(sim["multi_agent_plan"]["monthly_orchestration_tco_saved_usd"], 10050)
        self.assertTrue(sim["foundry_iq_guardrail"]["unreviewed_production_drop_column_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["direct_prod_mutation_without_git_pr_blocked"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 415)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 2900000)

    def test_global_conglomerate_finops_surge_rayfin_vs_dbu_credits_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("global_conglomerate_finops_surge_rayfin_vs_dbu_credits")
        self.assertEqual(sim["telemetry"]["governed_business_unit_workspaces"], 38)
        self.assertEqual(sim["telemetry"]["background_cu_rejection_threshold_pct"], 75.0)
        self.assertEqual(sim["telemetry"]["executive_directlake_p95_latency_under_surge_ms"], 182)
        self.assertEqual(sim["multi_agent_plan"]["protected_mission_critical_bi_workspaces"], 37)
        self.assertEqual(sim["multi_agent_plan"]["monthly_finops_overage_saved_usd"], 13380)
        self.assertTrue(sim["foundry_iq_guardrail"]["unapproved_capacity_upscale_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["mission_critical_bi_throttling_blocked"])
        self.assertEqual(sim["decision_routing"]["action"], "Act automatically")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 399)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 160560)

    def test_global_payments_cicd_git_tmdl_deployment_vs_dabs_snowcli_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("global_payments_cicd_git_tmdl_deployment_vs_dabs_snowcli")
        self.assertEqual(sim["telemetry"]["regulated_settlement_regions"], 14)
        self.assertEqual(sim["telemetry"]["coordinated_workspace_artifacts"], 64)
        self.assertEqual(sim["telemetry"]["zero_copy_branch_workspace_storage_overhead_usd"], 0)
        self.assertEqual(sim["multi_agent_plan"]["environment_connection_drift_incidents"], 0)
        self.assertEqual(sim["multi_agent_plan"]["monthly_dataops_tco_saved_usd"], 21600)
        self.assertTrue(sim["foundry_iq_guardrail"]["unreviewed_binary_pbix_overwrite_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["hardcoded_uat_connection_string_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 383)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 2120000)

    def test_sovereign_wealth_private_link_managed_vnet_exfil_defense_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("sovereign_wealth_private_link_managed_vnet_exfil_defense")
        self.assertEqual(sim["telemetry"]["sovereign_regulated_workspaces"], 22)
        self.assertEqual(sim["telemetry"]["public_internet_ingress_exposure_endpoints"], 0)
        self.assertEqual(sim["telemetry"]["customer_managed_nat_firewall_surcharge_usd"], 0)
        self.assertEqual(sim["multi_agent_plan"]["exfiltration_bytes_leaked"], 0)
        self.assertEqual(sim["multi_agent_plan"]["monthly_netsec_tco_saved_usd"], 18900)
        self.assertTrue(sim["foundry_iq_guardrail"]["unapproved_outbound_internet_egress_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["public_storage_firewall_bypass_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 367)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 4200000)

    def test_global_clearing_bank_bcdr_cmk_regional_failover_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("global_clearing_bank_bcdr_cmk_regional_failover")
        self.assertEqual(sim["telemetry"]["regulated_clearing_volume_tb"], 180)
        self.assertEqual(sim["telemetry"]["achieved_rpo_seconds"], 42)
        self.assertEqual(sim["telemetry"]["achieved_rto_seconds"], 165)
        self.assertEqual(sim["telemetry"]["cmk_edition_upgrade_surcharge_usd"], 0)
        self.assertEqual(sim["multi_agent_plan"]["monthly_bcdr_cmk_tco_saved_usd"], 22200)
        self.assertTrue(sim["foundry_iq_guardrail"]["cmk_fips_140_3_key_custody_verified"])
        self.assertTrue(sim["foundry_iq_guardrail"]["unencrypted_cross_region_snapshot_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 351)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 3650000)

    def test_b2b_retail_media_iq_sharing_clean_room_monetization_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("b2b_retail_media_iq_sharing_clean_room_monetization")
        self.assertEqual(sim["telemetry"]["shared_pos_loyalty_volume_tb"], 45)
        self.assertEqual(sim["telemetry"]["external_cpg_brand_partner_tenants"], 68)
        self.assertEqual(sim["telemetry"]["provider_replication_compute_surcharge_usd"], 0)
        self.assertEqual(sim["telemetry"]["partner_semantic_metric_drift_pct"], 0.0)
        self.assertEqual(sim["multi_agent_plan"]["monthly_b2b_sharing_tco_saved_usd"], 20500)
        self.assertTrue(sim["foundry_iq_guardrail"]["raw_customer_pii_cross_tenant_exposure_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["sub_50_cohort_reidentification_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 335)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 3900000)

    def test_global_retail_dwh_tsql_vorder_directlake_vs_snowflake_dbsql_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("global_retail_dwh_tsql_vorder_directlake_vs_snowflake_dbsql")
        self.assertEqual(sim["telemetry"]["governed_edw_volume_tb"], 65)
        self.assertEqual(sim["telemetry"]["monday_morning_concurrent_bi_users"], 1800)
        self.assertEqual(sim["telemetry"]["multi_cluster_sql_spinup_surcharge_usd"], 0)
        self.assertEqual(sim["telemetry"]["directlake_p95_query_latency_ms"], 194)
        self.assertEqual(sim["multi_agent_plan"]["monthly_edw_bi_tco_saved_usd"], 23400)
        self.assertTrue(sim["foundry_iq_guardrail"]["below_margin_floor_price_lock_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["multi_cluster_sql_queue_starvation_prevented"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 319)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 4450000)

    def test_global_reinsurance_ai_functions_multimodal_claims_vs_cortex_mosaic_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("global_reinsurance_ai_functions_multimodal_claims_vs_cortex_mosaic")
        self.assertEqual(sim["telemetry"]["multimodal_catastrophe_dossiers_count"], 1200000)
        self.assertEqual(sim["telemetry"]["warehouse_ai_credit_markup_surcharge_usd"], 0)
        self.assertEqual(sim["telemetry"]["duplicate_fraudulent_claims_blocked"], 19)
        self.assertEqual(sim["multi_agent_plan"]["monthly_multimodal_ai_tco_saved_usd"], 24900)
        self.assertTrue(sim["foundry_iq_guardrail"]["unverified_llm_payout_hallucination_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["cross_state_duplicate_claim_ring_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 303)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 4800000)

    def test_gigafactory_digital_twin_builder_iot_ot_vs_sitewise_lakeflow_ontology_simulation(self) -> None:
        sim = simulate_ontology_incident("gigafactory_digital_twin_builder_iot_ot_vs_sitewise_lakeflow")
        self.assertEqual(sim["telemetry"]["monitored_battery_coating_lines"], 36)
        self.assertEqual(sim["telemetry"]["shop_floor_opcua_mqtt_eps"], 140000)
        self.assertEqual(sim["telemetry"]["per_property_tag_metering_surcharge_usd"], 0)
        self.assertEqual(sim["multi_agent_plan"]["protected_electrode_coils"], 18)
        self.assertEqual(sim["multi_agent_plan"]["monthly_digital_twin_tco_saved_usd"], 26400)
        self.assertTrue(sim["foundry_iq_guardrail"]["unsafe_mechanical_roll_jump_blocked"])
        self.assertTrue(sim["foundry_iq_guardrail"]["aldo_air_gapped_edge_fallback_verified"])
        self.assertTrue(sim["foundry_iq_guardrail"]["compliant"])
        self.assertEqual(sim["decision_routing"]["action"], "Confirm")
        self.assertEqual(sim["decision_routing"]["end_to_end_latency_ms"], 287)
        self.assertEqual(sim["decision_routing"]["projected_savings_usd"], 5100000)

    def test_scenario_matrix_112_cases_and_explicit_miss(self) -> None:
        matrix = evaluate_scenario_matrix()
        self.assertEqual(matrix["total_scenarios"], 112)
        self.assertEqual(matrix["passed_scenarios"], 111)
        self.assertEqual(matrix["failed_scenarios"], 1)
        self.assertAlmostEqual(matrix["accuracy_pct"], 99.11, places=2)
        self.assertEqual(matrix["avg_latency_ms"], 461.0)
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

    def test_realtime_eventhouse_vs_dynamic_tables_dlt_2026_11_08_r2_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-49", "DL-50", "DL-51", "DL-52"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Snowflake Dynamic Tables", by_id["DL-49"]["expected"])
        self.assertIn("Databricks Lakeflow", by_id["DL-50"]["expected"])
        self.assertIn("Eventhouse KQL", by_id["DL-51"]["expected"])
        self.assertIn("Amsterdam-IXP SRv6 Steer", by_id["DL-52"]["expected"])

    def test_mirroring_zero_etl_vs_cdc_openflow_lakeflow_2026_11_09_r3_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-53", "DL-54", "DL-55", "DL-56"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("$0 replication compute", by_id["DL-53"]["expected"])
        self.assertIn("Oracle GoldenGate 23ai", by_id["DL-54"]["expected"])
        self.assertIn("1GB Free Fabric SQL", by_id["DL-55"]["expected"])
        self.assertIn("Save $2.35M Default", by_id["DL-56"]["expected"])

    def test_onelake_iceberg_delta_uniform_polaris_s3tables_2026_11_09_r4_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-57", "DL-58", "DL-59", "DL-60"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("OneLake XTable Bidirectional Virtualization", by_id["DL-57"]["expected"])
        self.assertIn("Delta UniForm", by_id["DL-58"]["expected"])
        self.assertIn("AWS S3 Tables", by_id["DL-59"]["expected"])
        self.assertIn("Protect $1.62M Margin", by_id["DL-60"]["expected"])

    def test_htap_vector_diskann_vs_lakebase_unistore_2026_11_09_r5_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-61", "DL-62", "DL-63", "DL-64"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("SSD-backed Vamana + PQ", by_id["DL-61"]["expected"])
        self.assertIn("Databricks Lakebase", by_id["DL-62"]["expected"])
        self.assertIn("Snowflake Unistore Hybrid Tables", by_id["DL-63"]["expected"])
        self.assertIn("Protect $1.95M Exposure", by_id["DL-64"]["expected"])

    def test_onelake_purview_obo_governance_vs_4clouds_2026_11_09_r6_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-65", "DL-66", "DL-67", "DL-68"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("OneLake Unified Security", by_id["DL-65"]["expected"])
        self.assertIn("Mosaic AI Gateway", by_id["DL-66"]["expected"])
        self.assertIn("Snowflake Horizon", by_id["DL-67"]["expected"])
        self.assertIn("Mitigate $2.80M GDPR/EMA Risk", by_id["DL-68"]["expected"])

    def test_spark_native_gluten_autoscale_vs_photon_snowpark_2026_11_09_r7_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-69", "DL-70", "DL-71", "DL-72"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Fabric Spark Native Execution Engine", by_id["DL-69"]["expected"])
        self.assertIn("Databricks Serverless GPU", by_id["DL-70"]["expected"])
        self.assertIn("Snowflake Snowpark/SPCS", by_id["DL-71"]["expected"])
        self.assertIn("Mitigate $2.45M Recall Risk", by_id["DL-72"]["expected"])

    def test_fabric_data_agents_copilot_vs_genie_cortex_2026_11_09_r8_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-73", "DL-74", "DL-75", "DL-76"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Microsoft Fabric Data Agent", by_id["DL-73"]["expected"])
        self.assertIn("Databricks AI/BI Genie & Agent Bricks", by_id["DL-74"]["expected"])
        self.assertIn("Power BI Semantic Models", by_id["DL-75"]["expected"])
        self.assertIn("Protect $3.15M Biologics", by_id["DL-76"]["expected"])

    def test_fabric_data_factory_osmos_vs_lakeflow_tasks_composer_2026_11_09_r9_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-77", "DL-78", "DL-79", "DL-80"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Project Osmos Data Engineering Agent", by_id["DL-77"]["expected"])
        self.assertIn("Databricks Lakeflow/DLT", by_id["DL-78"]["expected"])
        self.assertIn("Materialized Lake Views", by_id["DL-79"]["expected"])
        self.assertIn("Protect $2.90M Black Friday Orders", by_id["DL-80"]["expected"])

    def test_fabric_capacity_finops_surge_rayfin_vs_4clouds_2026_11_09_r10_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-81", "DL-82", "DL-83", "DL-84"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Fabric Surge Protection (75% Background CU Cap)", by_id["DL-81"]["expected"])
        self.assertIn("Snowflake Resource Monitors", by_id["DL-82"]["expected"])
        self.assertIn("Databricks Serverless Budget Policy", by_id["DL-83"]["expected"])
        self.assertIn("182ms DirectLake P95", by_id["DL-84"]["expected"])

    def test_fabric_cicd_git_tmdl_pipelines_vs_dabs_snowcli_2026_11_09_r11_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-85", "DL-86", "DL-87", "DL-88"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("PBIP + TMDL Human-Readable Semantic Model Serialization", by_id["DL-85"]["expected"])
        self.assertIn("fabric-cicd", by_id["DL-86"]["expected"])
        self.assertIn("Snowflake CREATE OR ALTER", by_id["DL-87"]["expected"])
        self.assertIn("Protect $2.12M SLA", by_id["DL-88"]["expected"])

    def test_fabric_private_link_managed_vnet_security_vs_4clouds_2026_11_09_r12_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-89", "DL-90", "DL-91", "DL-92"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Outbound Access Protection (OAP)", by_id["DL-89"]["expected"])
        self.assertIn("Databricks Classic VNet Injection", by_id["DL-90"]["expected"])
        self.assertIn("Snowflake Business Critical 1.5x tier surcharge", by_id["DL-91"]["expected"])
        self.assertIn("Protect $4.20M DORA Fine", by_id["DL-92"]["expected"])

    def test_fabric_bcdr_cross_region_cmk_recovery_vs_4clouds_2026_11_09_r13_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-93", "DL-94", "DL-95", "DL-96"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Fabric Capacity BCDR OneLake Geo-Replication Switch", by_id["DL-93"]["expected"])
        self.assertIn("Snowflake Business Critical Client Redirect", by_id["DL-94"]["expected"])
        self.assertIn("Spark DEEP CLONE compute DBU burn", by_id["DL-95"]["expected"])
        self.assertIn("Protect $3.65M Clearing SLA", by_id["DL-96"]["expected"])

    def test_fabric_external_data_sharing_clean_room_vs_4clouds_2026_11_09_r14_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-97", "DL-98", "DL-99", "DL-100"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Fabric External Data Sharing (In-Place Cross-Tenant OneLake Shortcut)", by_id["DL-97"]["expected"])
        self.assertIn("Snowflake Data Clean Rooms", by_id["DL-98"]["expected"])
        self.assertIn("Databricks OpenSharing", by_id["DL-99"]["expected"])
        self.assertIn("Protect $3.90M RMN ARR", by_id["DL-100"]["expected"])

    def test_fabric_warehouse_tsql_vorder_directlake_vs_4clouds_2026_11_09_r15_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-101", "DL-102", "DL-103", "DL-104"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Fabric Warehouse (full read-write T-SQL + multi-table ACID + auto V-Order", by_id["DL-101"]["expected"])
        self.assertIn("DirectLake in-memory framing (194ms P95)", by_id["DL-102"]["expected"])
        self.assertIn("Liquid Clustering", by_id["DL-103"]["expected"])
        self.assertIn("Protect $4.45M Pricing SLA", by_id["DL-104"]["expected"])

    def test_fabric_ai_functions_multimodal_rag_vs_cortex_mosaic_2026_11_10_r16_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-105", "DL-106", "DL-107", "DL-108"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("Fabric AI Functions (df.ai.extract / df.ai.classify)", by_id["DL-105"]["expected"])
        self.assertIn("save 69.6% multimodal AI TCO", by_id["DL-106"]["expected"])
        self.assertIn("Databricks Mosaic AI", by_id["DL-107"]["expected"])
        self.assertIn("Protect $4.80M SLA", by_id["DL-108"]["expected"])

    def test_fabric_digital_twin_builder_iot_ot_vs_sitewise_4clouds_2026_11_10_r17_scenarios(self) -> None:
        matrix = evaluate_scenario_matrix()
        by_id = {s["id"]: s for s in matrix["scenarios"]}
        for sid in ("DL-109", "DL-110", "DL-111", "DL-112"):
            self.assertIn(sid, by_id)
            self.assertTrue(by_id[sid]["correct"])
        self.assertIn("No-Code Digital Twin Builder Ontology ($0 Per-Property Fee)", by_id["DL-109"]["expected"])
        self.assertIn("eliminate SiteWise per-property/per-alarm fees (-71.5% TCO)", by_id["DL-110"]["expected"])
        self.assertIn("Snowflake 60s Dynamic Tables", by_id["DL-111"]["expected"])
        self.assertIn("Protect $5.10M Yield", by_id["DL-112"]["expected"])

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
        self.assertEqual(loaded["scenario_evaluation"]["passed_scenarios"], 111)
        self.assertEqual(loaded["scenario_evaluation"]["routing_matrix_denominator_n"], 112)
        self.assertEqual(loaded["scenario_evaluation"]["routing_matrix_mean_modeled_latency_ms"], 461.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["total_ontology_simulations"], 24)
        self.assertEqual(loaded["ontology_simulations_summary"]["ontology_simulation_mean_modeled_latency_ms"], 471.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r16_23_simulation_mean_modeled_latency_ms"], 479.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r15_22_simulation_mean_modeled_latency_ms"], 487.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r14_21_simulation_mean_modeled_latency_ms"], 495.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r13_20_simulation_mean_modeled_latency_ms"], 503.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r12_19_simulation_mean_modeled_latency_ms"], 511.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r11_18_simulation_mean_modeled_latency_ms"], 519.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r10_17_simulation_mean_modeled_latency_ms"], 527.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r9_16_simulation_mean_modeled_latency_ms"], 535.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r8_15_simulation_mean_modeled_latency_ms"], 543.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r7_14_simulation_mean_modeled_latency_ms"], 552.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r6_13_simulation_mean_modeled_latency_ms"], 562.0)
        self.assertEqual(loaded["ontology_simulations_summary"]["r5_12_simulation_mean_modeled_latency_ms"], 572.92)
        self.assertEqual(loaded["ontology_simulations_summary"]["r4_11_simulation_mean_modeled_latency_ms"], 584.09)
        self.assertEqual(loaded["ontology_simulations_summary"]["r3_10_simulation_mean_modeled_latency_ms"], 596.0)
        refs = loaded["provenance"]["vendor_published_spec_references"]
        self.assertEqual(len(refs), 20)
        for ref in refs:
            self.assertTrue(ref["official_url"].startswith("https://"))
            self.assertIn(ref["as_of"], ("2026-11-08", "2026-11-09", "2026-11-10"))
        self.assertIn("retail_cross_cloud_planning", loaded["ontology_simulations"])
        self.assertIn("financial_multi_cloud_fraud", loaded["ontology_simulations"])
        self.assertIn("finops_rayfin_observability", loaded["ontology_simulations"])
        self.assertIn("healthcare_clinical_supply_diskann", loaded["ontology_simulations"])
        self.assertIn("manufacturing_digital_twin_zeroprov", loaded["ontology_simulations"])
        self.assertIn("supply_chain_iq_sharing_salesforce", loaded["ontology_simulations"])
        self.assertIn("telecom_5g_eventhouse_vs_dynamic_tables", loaded["ontology_simulations"])
        self.assertIn("core_banking_oracle_open_mirroring_cdc", loaded["ontology_simulations"])
        self.assertIn("omni_channel_snowflake_iceberg_onelake_xtable", loaded["ontology_simulations"])
        self.assertIn("wealth_advisory_htap_diskann_vs_lakebase_unistore", loaded["ontology_simulations"])
        self.assertIn("sovereign_healthcare_obo_purview_vs_uc_abac", loaded["ontology_simulations"])
        self.assertIn("auto_telematics_gluten_velox_autoscale_vs_photon", loaded["ontology_simulations"])
        self.assertIn("global_pharma_fabric_data_agent_vs_genie_cortex", loaded["ontology_simulations"])
        self.assertIn("retail_supply_osmos_medallion_healing_vs_lakeflow", loaded["ontology_simulations"])
        self.assertIn("global_conglomerate_finops_surge_rayfin_vs_dbu_credits", loaded["ontology_simulations"])
        self.assertIn("global_payments_cicd_git_tmdl_deployment_vs_dabs_snowcli", loaded["ontology_simulations"])
        self.assertIn("sovereign_wealth_private_link_managed_vnet_exfil_defense", loaded["ontology_simulations"])
        self.assertIn("global_clearing_bank_bcdr_cmk_regional_failover", loaded["ontology_simulations"])
        self.assertIn("b2b_retail_media_iq_sharing_clean_room_monetization", loaded["ontology_simulations"])
        self.assertIn("global_retail_dwh_tsql_vorder_directlake_vs_snowflake_dbsql", loaded["ontology_simulations"])
        self.assertIn("global_reinsurance_ai_functions_multimodal_claims_vs_cortex_mosaic", loaded["ontology_simulations"])
        self.assertIn("gigafactory_digital_twin_builder_iot_ot_vs_sitewise_lakeflow", loaded["ontology_simulations"])


if __name__ == "__main__":
    unittest.main()
