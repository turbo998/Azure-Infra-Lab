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
    simulate_a2a_verified_id_quic_federation_mesh,
    simulate_agentic_memory_diskann_graphrag_tiering,
    simulate_agentic_payment_confidential_ledger_guardrail,
    simulate_automotive_sdv_v2x_ota_sandbox,
    simulate_autonomous_cicd_buildkit_bazel_sandbox,
    simulate_aviation_irops_swim_do178c_sandbox,
    simulate_biopharma_alphafold_wetlab_sila2_sandbox,
    simulate_carbon_aware_greenops_fleet_scheduler,
    simulate_chaos_byzantine_fault_injection_gameday,
    simulate_confidential_sandbox_attestation,
    simulate_cua_browser_sandbox_grounding,
    simulate_cyber_defense_detonation_sentinel_sandbox,
    simulate_datacenter_cooling_bacnet_pue_sandbox,
    simulate_dependency_cache_virtiofs_dax,
    simulate_durable_agent_workflow_saga_gc,
    simulate_edge_disconnected_iot_operations_sandbox,
    simulate_egress_exfiltration_and_mcp_supply_chain,
    simulate_embodied_robotics_digital_twin_sandbox,
    simulate_finops_spot_eviction_drain,
    simulate_gpu_heterogeneous_sandbox_mps_mig,
    simulate_healthcare_fhir_dicom_cfr11_sandbox,
    simulate_hybrid_model_routing_kv_cache_affinity,
    simulate_hyperlight_wasm_microsandbox_dispatch,
    simulate_lakehouse_duckdb_onelake_sandbox,
    simulate_maritime_port_crane_colregs_sandbox,
    simulate_media_openusd_3dgs_c2pa_sandbox,
    simulate_mining_ahs_iso21815_sandbox,
    simulate_multi_agent_swarm_fanout_governance,
    simulate_multicloud_confidential_cleanroom_federation,
    simulate_multiregion_dr_failover,
    simulate_online_rft_verifier_selfplay_sandbox,
    simulate_otel_ebpf_observability_pipeline,
    simulate_pqc_hybrid_mtls_agent_crypto_agility,
    simulate_precision_ag_isobus_ndvi_sandbox,
    simulate_quant_trading_fix_afxdp_risk_sandbox,
    simulate_quantum_classical_hybrid_qir_sandbox,
    simulate_rail_ertms_etcs_sil4_sandbox,
    simulate_retail_pos_esl_vision_edge_sandbox,
    simulate_scientific_hpc_lustre_mpi_sandbox,
    simulate_semiconductor_eda_rtl_gdsii_sandbox,
    simulate_smart_building_ashrae_nfpa72_sandbox,
    simulate_sovereign_data_residency_crypto_shredding,
    simulate_smart_grid_iec61850_pmu_sandbox,
    simulate_space_orbital_satellite_edge_sandbox,
    simulate_supplychain_amr_mapf_coldchain_sandbox,
    simulate_telco_oran_network_slicing_sandbox,
    simulate_water_utility_ro_scada_sdwa_sandbox,
    simulate_emergency_wildfire_cad_nims_sandbox,
    simulate_offshore_wind_subsea_rov_esd_sandbox,
    simulate_circular_recycling_battery_xrf_sandbox,
    simulate_steelmaking_eaf_casting_sil3_sandbox,
    simulate_cement_kiln_ccus_pyro_sandbox,
    simulate_green_hydrogen_electrolyzer_ammonia_sandbox,
    simulate_fusion_tokamak_plasma_quench_sandbox,
    simulate_particle_accelerator_synchrotron_beam_sandbox,
    simulate_deep_space_telescope_adaptive_optics_sandbox,
    simulate_subsea_cabled_observatory_tsunami_bop_sandbox,
    simulate_geothermal_egs_induced_seismicity_turbine_sandbox,
    simulate_smr_nuclear_neutronics_class1e_rts_sandbox,
    simulate_tbm_tunnel_boring_geomechanics_sil3_sandbox,
    simulate_petrochemical_fcc_refinery_sil3_esd_sandbox,
    simulate_aerospace_composite_autoclave_ndt_sil3_sandbox,
    simulate_lng_cryogenic_c3mr_bog_sil3_esd_sandbox,
    simulate_hvdc_subsea_interconnector_mmc_dcr_sil3_dccb_sandbox,
    simulate_dac_carbon_sequestration_vtsa_sco2_class6_sil3_sandbox,
    simulate_bess_grid_storage_eis_thermal_ul9540a_sil3_sandbox,
    simulate_additive_manufacturing_lpbf_meltpool_nfpa484_sil3_sandbox,
    simulate_euv_lithography_scanner_lpp_overlay_semi_s2_sil3_sandbox,
    simulate_saf_ptl_fischer_tropsch_rwgs_astm_d7566_sil3_sandbox,
    simulate_quantum_superconducting_qec_cryo_dilution_sil3_sandbox,
    simulate_leo_megaconstellation_oisl_conjunction_iso24113_sil3_sandbox,
    simulate_deepsea_mineral_collector_riser_isa_dnv_sil3_sandbox,
    simulate_biomanufacturing_perfusion_bioreactor_pat_gmp_sil3_sandbox,
    simulate_hypersonic_cmc_cvi_arcjet_tps_nfpa86_sil3_sandbox,
    simulate_subsea_cable_lay_plough_otdr_das_dnv_sil3_sandbox,
    simulate_psh_pumped_hydro_waterhammer_vortex_iec60308_sil3_sandbox,
    simulate_fpso_turret_mooring_riser_slugging_apirp14c_sil3_sandbox,
    simulate_sic_pvt_boule_crystal_growth_htcvd_semis2_sil3_sandbox,
    simulate_polar_icebreaker_ice_routing_azimuth_thruster_imopolar_sil3_sandbox,
    simulate_gravitational_wave_interferometer_fabry_perot_newtonian_sil3_sandbox,
    simulate_stratospheric_hale_solar_haps_aeroelastic_dala_sandbox,
    simulate_gen4_liquid_metal_sfr_lbe_swr_class1e_sil3_sandbox,
    simulate_subsalt_mpd_drilling_lwd_kick_apirp53_sil3_sandbox,
    simulate_hts_rebco_superconducting_cable_sfcl_quench_sil3_sandbox,
    simulate_cryogenic_lh2_lch4_launch_pad_chilldown_geyser_sil3_sandbox,
    simulate_airborne_wind_energy_crosswind_kite_tether_sil3_sandbox,
    simulate_maglev_eds_ems_lsm_levitation_airgap_en50129_sil4_sandbox,
    simulate_ptes_carnot_battery_brayton_turbocompressor_sil3_sandbox,
    simulate_vleo_abep_atmosphere_breathing_ion_thruster_sil3_sandbox,
    simulate_offshore_ccus_co2_pipeline_caprock_sequestration_sil3_sandbox,
    simulate_fsw_friction_stir_welding_cryo_tank_paut_awsd17_sil3_sandbox,
    simulate_perovskite_silicon_tandem_pv_slot_die_laser_scribing_sil3_sandbox,
    simulate_solid_state_sulfide_battery_dry_electrode_isobaric_h2s_sil3_sandbox,
    simulate_pem_fuel_cell_ccm_ultrasonic_spray_bipolar_plate_saej2579_sil3_sandbox,
    simulate_soec_high_temp_steam_co2_coelectrolysis_ceramic_sil3_sandbox,
    simulate_h2_dri_shaft_furnace_hydrogen_reduction_clustering_sil3_sandbox,
    simulate_cryo_har_plasma_etch_3dnand_esc_oes_semis2_sil3_sandbox,
    simulate_mrna_lnp_microfluidic_mixing_tff_dls_gmp_sil3_sandbox,
    simulate_ultradeep_10km_superhot_rock_drilling_fwi_iso15156_sil3_sandbox,
    simulate_cmp_planarization_hybrid_w2w_bonding_epd_semis2_sil3_sandbox,
    simulate_single_crystal_superalloy_bridgman_lmc_casting_ams2280_sil3_sandbox,
    simulate_subsea_methane_hydrate_depressurization_sand_control_dts_sil3_sandbox,
    simulate_uhv_mbe_quantum_epitaxy_rheed_bet_semis2_sil3_sandbox,
    simulate_ldpe_hypercompressor_tubular_reactor_ftnir_api618_sil3_sandbox,
    simulate_medical_cyclotron_radiopharma_hotcell_usp823_sil3_sandbox,
    simulate_hollowcore_optical_fiber_draw_tower_meniscus_itu_sil3_sandbox,
    simulate_polysilicon_siemens_cvd_fbr_trichlorosilane_semis2_sil3_sandbox,
    simulate_cryogenic_asu_air_separation_lox_reboiler_eiga65_sil3_sandbox,
    simulate_chlor_alkali_membrane_electrolyzer_cl2_h2_eurochlor_sil3_sandbox,
    simulate_carbon_fiber_pan_oxidation_carbonization_hcn_nfpa86_sil3_sandbox,
    simulate_dle_lithium_brine_sorption_libs_epauic_sil3_sandbox,
    simulate_vrfb_flow_battery_ldes_uvvis_nfpa855_sil3_sandbox,
    simulate_ebam_electron_beam_titanium_elo_ams4999_sil3_sandbox,
    simulate_webrtc_voice_video_media_sandbox,
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
            "aksclaw-green-hydrogen-electrolyzer-ammonia-pool.bicep",
            "aksclaw-fusion-tokamak-plasma-quench-pool.bicep",
            "aksclaw-particle-accelerator-synchrotron-beam-pool.bicep",
            "aksclaw-deep-space-telescope-adaptive-optics-pool.bicep",
            "aksclaw-subsea-cabled-observatory-tsunami-bop-pool.bicep",
            "aksclaw-geothermal-egs-induced-seismicity-turbine-pool.bicep",
            "aksclaw-smr-nuclear-neutronics-class1e-rts-pool.bicep",
            "aksclaw-tbm-tunnel-boring-geomechanics-sil3-pool.bicep",
            "aksclaw-petrochemical-fcc-refinery-sil3-esd-pool.bicep",
            "aksclaw-aerospace-composite-autoclave-ndt-sil3-pool.bicep",
            "aksclaw-lng-cryogenic-c3mr-bog-sil3-esd-pool.bicep",
            "aksclaw-hvdc-subsea-interconnector-mmc-dcr-sil3-dccb-pool.bicep",
            "aksclaw-dac-carbon-sequestration-vtsa-sco2-class6-sil3-pool.bicep",
            "aksclaw-bess-grid-storage-eis-thermal-ul9540a-sil3-pool.bicep",
            "aksclaw-additive-manufacturing-lpbf-meltpool-nfpa484-sil3-pool.bicep",
            "aksclaw-euv-lithography-scanner-lpp-overlay-semi-s2-sil3-pool.bicep",
            "aksclaw-saf-ptl-fischer-tropsch-rwgs-astm-d7566-sil3-pool.bicep",
            "aksclaw-quantum-superconducting-qec-cryo-dilution-sil3-pool.bicep",
            "aksclaw-leo-megaconstellation-oisl-conjunction-iso24113-sil3-pool.bicep",
            "aksclaw-deepsea-mineral-collector-riser-isa-dnv-sil3-pool.bicep",
            "aksclaw-biomanufacturing-perfusion-bioreactor-pat-gmp-sil3-pool.bicep",
            "aksclaw-hypersonic-cmc-cvi-arcjet-tps-nfpa86-sil3-pool.bicep",
            "aksclaw-subsea-cable-lay-plough-otdr-das-dnv-sil3-pool.bicep",
            "aksclaw-psh-pumped-hydro-waterhammer-vortex-iec60308-sil3-pool.bicep",
            "aksclaw-fpso-turret-mooring-riser-slugging-apirp14c-sil3-pool.bicep",
            "aksclaw-sic-pvt-boule-crystal-growth-htcvd-semis2-sil3-pool.bicep",
            "aksclaw-polar-icebreaker-ice-routing-azimuth-imopolar-sil3-pool.bicep",
            "aksclaw-gravitational-wave-interferometer-fabry-perot-sil3-pool.bicep",
            "aksclaw-stratospheric-hale-solar-haps-aeroelastic-dala-pool.bicep",
            "aksclaw-gen4-liquid-metal-sfr-lbe-swr-class1e-sil3-pool.bicep",
            "aksclaw-subsalt-mpd-drilling-lwd-kick-apirp53-sil3-pool.bicep",
            "aksclaw-hts-rebco-superconducting-cable-sfcl-quench-sil3-pool.bicep",
            "aksclaw-cryogenic-lh2-lch4-launch-pad-chilldown-geyser-sil3-pool.bicep",
            "aksclaw-airborne-wind-energy-crosswind-kite-tether-iec61400-sil3-pool.bicep",
            "aksclaw-maglev-eds-ems-lsm-levitation-airgap-en50129-sil4-pool.bicep",
            "aksclaw-ptes-carnot-battery-brayton-turbocompressor-thermocline-sil3-pool.bicep",
            "aksclaw-vleo-abep-atmosphere-breathing-ion-thruster-dsmc-sil3-pool.bicep",
            "aksclaw-offshore-ccus-co2-pipeline-decompression-fracture-sccs-iso27914-sil3-pool.bicep",
            "aksclaw-fsw-friction-stir-welding-cryo-tank-phased-array-ut-awsd17-sil3-pool.bicep",
            "aksclaw-perovskite-silicon-tandem-pv-slot-die-laser-scribing-iec61215-sil3-pool.bicep",
            "aksclaw-solid-state-sulfide-battery-dry-electrode-isobaric-h2s-ul9540a-sil3-pool.bicep",
            "aksclaw-pem-fuel-cell-ccm-ultrasonic-spray-bipolar-plate-saej2579-sil3-pool.bicep",
            "aksclaw-soec-high-temp-steam-co2-coelectrolysis-ceramic-iso22734-sil3-pool.bicep",
            "aksclaw-h2-dri-shaft-furnace-hydrogen-reduction-clustering-nfpa86-sil3-pool.bicep",
            "aksclaw-cryo-har-plasma-etch-3dnand-esc-oes-semis2-sil3-pool.bicep",
            "aksclaw-mrna-lnp-microfluidic-mixing-tff-dls-gmp-nfpa30-sil3-pool.bicep",
            "aksclaw-ultradeep-10km-superhot-rock-drilling-fwi-iso15156-sil3-pool.bicep",
            "aksclaw-cmp-planarization-hybrid-w2w-bonding-epd-semis2-sil3-pool.bicep",
            "aksclaw-single-crystal-superalloy-bridgman-lmc-casting-ams2280-sil3-pool.bicep",
            "aksclaw-subsea-methane-hydrate-depressurization-sand-control-dts-sil3-pool.bicep",
            "aksclaw-uhv-mbe-quantum-epitaxy-rheed-bet-semis2-sil3-pool.bicep",
            "aksclaw-ldpe-hypercompressor-tubular-reactor-ftnir-api618-sil3-pool.bicep",
            "aksclaw-medical-cyclotron-radiopharma-hotcell-usp823-sil3-pool.bicep",
            "aksclaw-hollowcore-optical-fiber-draw-tower-meniscus-itu-sil3-pool.bicep",
            "aksclaw-polysilicon-siemens-cvd-fbr-trichlorosilane-semis2-sil3-pool.bicep",
            "aksclaw-cryogenic-asu-air-separation-lox-reboiler-eiga65-sil3-pool.bicep",
            "aksclaw-chlor-alkali-membrane-electrolyzer-cl2-h2-eurochlor-sil3-pool.bicep",
            "aksclaw-carbon-fiber-pan-oxidation-carbonization-hcn-nfpa86-sil3-pool.bicep",
            "aksclaw-dle-lithium-brine-sorption-libs-epauic-sil3-pool.bicep",
            "aksclaw-vrfb-flow-battery-ldes-uvvis-nfpa855-sil3-pool.bicep",
            "aksclaw-ebam-electron-beam-titanium-elo-ams4999-sil3-pool.bicep",
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
            [sys.executable, "-B", str(demo_script), "--self-test"],
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

    def test_hybrid_model_routing_kv_cache_affinity(self) -> None:
        cas = simulate_hybrid_model_routing_kv_cache_affinity(0.68, "kv_affinity_cascade_speculative_prefetch")
        rr = simulate_hybrid_model_routing_kv_cache_affinity(0.00, "round_robin_single_frontier_no_prefetch")
        self.assertAlmostEqual(cas["kv_cache_hit_rate_pct"], 88.4)
        self.assertAlmostEqual(cas["ttft_p95_ms"], 210.0)
        self.assertAlmostEqual(cas["ttft_reduction_pct"], 88.6)
        self.assertAlmostEqual(cas["input_token_cost_savings_pct"], 44.2)
        self.assertLess(cas["classifier_overhead_ms"], 1.8)
        self.assertAlmostEqual(cas["blended_cost_per_1k_tasks_usd"], 51.40)
        self.assertAlmostEqual(cas["cost_reduction_pct"], 63.8)
        self.assertAlmostEqual(cas["mean_turn_latency_reduction_pct"], 46.5)
        self.assertAlmostEqual(cas["task_resolution_parity_pct"], 99.2)
        self.assertAlmostEqual(cas["speculative_lead_time_ms"], 180.0)
        self.assertAlmostEqual(cas["speculative_io_saved_ms"], 145.0)
        self.assertEqual(cas["unsafe_speculative_mutation_rate_pct"], 0.0)
        self.assertTrue(cas["cascade_governed"])
        self.assertAlmostEqual(rr["kv_cache_hit_rate_pct"], 18.5)
        self.assertAlmostEqual(rr["ttft_p95_ms"], 1840.0)
        self.assertAlmostEqual(rr["blended_cost_per_1k_tasks_usd"], 142.00)
        self.assertFalse(rr["cascade_governed"])

    def test_agentic_memory_diskann_graphrag_tiering(self) -> None:
        mem = simulate_agentic_memory_diskann_graphrag_tiering(100, "diskann_graphrag_3tier_rls")
        hnsw = simulate_agentic_memory_diskann_graphrag_tiering(100, "in_memory_hnsw_untiered_no_rls")
        self.assertAlmostEqual(mem["raw_vector_storage_gb"], 614.4)
        self.assertAlmostEqual(mem["hnsw_baseline_ram_gib"], 840.0)
        self.assertAlmostEqual(mem["index_ram_gib"], 48.0)
        self.assertAlmostEqual(mem["ram_reduction_pct"], 94.3)
        self.assertAlmostEqual(mem["monthly_index_cost_usd"], 580.0)
        self.assertAlmostEqual(mem["cost_reduction_pct"], 91.5)
        self.assertAlmostEqual(mem["recall_at_10_pct"], 96.8)
        self.assertAlmostEqual(mem["vector_query_p95_ms"], 6.4)
        self.assertAlmostEqual(mem["graphrag_query_latency_ms"], 42.0)
        self.assertAlmostEqual(mem["graphrag_latency_reduction_pct"], 98.8)
        self.assertEqual(mem["graphrag_injected_tokens"], 3880)
        self.assertAlmostEqual(mem["graphrag_token_reduction_pct"], 86.4)
        self.assertAlmostEqual(mem["redundant_write_elimination_pct"], 61.5)
        self.assertEqual(mem["cross_tenant_leakage_rate_pct"], 0.0)
        self.assertTrue(mem["memory_tier_governed"])
        self.assertAlmostEqual(hnsw["index_ram_gib"], 840.0)
        self.assertAlmostEqual(hnsw["monthly_index_cost_usd"], 6840.0)
        self.assertFalse(hnsw["memory_tier_governed"])

    def test_webrtc_voice_video_media_sandbox(self) -> None:
        rtc = simulate_webrtc_voice_video_media_sandbox(5_000, "ebpf_xdp_sockmap_vad_acs_turn")
        rest = simulate_webrtc_voice_video_media_sandbox(5_000, "userspace_nat_chained_http_rest")
        self.assertAlmostEqual(rtc["rtp_forwarding_p99_ms"], 3.2)
        self.assertAlmostEqual(rtc["rtp_latency_reduction_pct"], 93.3)
        self.assertAlmostEqual(rtc["host_network_cpu_pct"], 4.8)
        self.assertAlmostEqual(rtc["mouth_to_ear_p95_ms"], 242.5)
        self.assertLessEqual(rtc["mouth_to_ear_p95_ms"], 300.0)
        self.assertAlmostEqual(rtc["mouth_to_ear_reduction_pct"], 79.4)
        self.assertAlmostEqual(rtc["barge_in_cancel_latency_ms"], 14.0)
        self.assertAlmostEqual(rtc["wasted_audio_token_savings_pct"], 38.2)
        self.assertAlmostEqual(rtc["ice_handshake_latency_ms"], 195.0)
        self.assertAlmostEqual(rtc["ice_handshake_reduction_pct"], 88.2)
        self.assertAlmostEqual(rtc["nat_traversal_success_pct"], 99.95)
        self.assertTrue(rtc["realtime_slo_met"])
        self.assertAlmostEqual(rest["rtp_forwarding_p99_ms"], 48.0)
        self.assertAlmostEqual(rest["mouth_to_ear_p95_ms"], 1180.0)
        self.assertFalse(rest["realtime_slo_met"])

    def test_autonomous_cicd_buildkit_bazel_sandbox(self) -> None:
        ci = simulate_autonomous_cicd_buildkit_bazel_sandbox(1_000, "microvm_rootless_buildkit_cas_tia")
        dind = simulate_autonomous_cicd_buildkit_bazel_sandbox(1_000, "privileged_dind_cold_compile_full_test")
        self.assertEqual(ci["host_privilege_escalation_surface_pct"], 0.0)
        self.assertAlmostEqual(ci["native_nvme_throughput_pct"], 96.4)
        self.assertAlmostEqual(ci["container_build_latency_sec"], 14.2)
        self.assertAlmostEqual(ci["container_build_reduction_pct"], 76.2)
        self.assertAlmostEqual(ci["cas_object_hit_rate_pct"], 93.6)
        self.assertAlmostEqual(ci["compile_link_latency_sec"], 18.4)
        self.assertAlmostEqual(ci["compile_link_reduction_pct"], 94.1)
        self.assertAlmostEqual(ci["vcpu_hours_saved_pct"], 78.5)
        self.assertEqual(ci["cas_poisoning_rate_pct"], 0.0)
        self.assertAlmostEqual(ci["tia_test_wallclock_reduction_pct"], 82.0)
        self.assertAlmostEqual(ci["flaky_retry_elimination_pct"], 99.1)
        self.assertTrue(ci["hermetic_cicd_governed"])
        self.assertEqual(dind["host_privilege_escalation_surface_pct"], 100.0)
        self.assertAlmostEqual(dind["compile_link_latency_sec"], 310.0)
        self.assertFalse(dind["hermetic_cicd_governed"])

    def test_lakehouse_duckdb_onelake_sandbox(self) -> None:
        lh = simulate_lakehouse_duckdb_onelake_sandbox(1_000, "ephemeral_duckdb_onelake_pushdown_ast_guard")
        sp = simulate_lakehouse_duckdb_onelake_sandbox(1_000, "cold_spark_cluster_unbounded_sql")
        self.assertAlmostEqual(lh["query_latency_p95_sec"], 1.85)
        self.assertAlmostEqual(lh["query_latency_reduction_pct"], 96.2)
        self.assertAlmostEqual(lh["cost_per_1k_sessions_usd"], 19.60)
        self.assertAlmostEqual(lh["cost_reduction_pct"], 89.3)
        self.assertAlmostEqual(lh["ast_cost_guard_overhead_ms"], 0.9)
        self.assertAlmostEqual(lh["runaway_scan_bill_reduction_pct"], 99.6)
        self.assertAlmostEqual(lh["hallucinated_column_retry_reduction_pct"], 74.0)
        self.assertEqual(lh["unauthorized_column_exposure_pct"], 0.0)
        self.assertTrue(lh["lakehouse_slo_governed"])
        self.assertAlmostEqual(sp["query_latency_p95_sec"], 48.50)
        self.assertAlmostEqual(sp["cost_per_1k_sessions_usd"], 184.00)
        self.assertFalse(sp["lakehouse_slo_governed"])

    def test_multicloud_confidential_cleanroom_federation(self) -> None:
        cr = simulate_multicloud_confidential_cleanroom_federation(1_000, "oidc_federation_wireguard_sev_snp_cleanroom")
        ak = simulate_multicloud_confidential_cleanroom_federation(1_000, "static_aksk_userspace_mtls_shared_vm")
        self.assertEqual(cr["static_secret_exposure_pct"], 0.0)
        self.assertAlmostEqual(cr["oidc_sts_exchange_p95_ms"], 3.4)
        self.assertAlmostEqual(cr["oidc_sts_latency_reduction_pct"], 98.2)
        self.assertAlmostEqual(cr["cross_cloud_throughput_gbps"], 38.4)
        self.assertAlmostEqual(cr["wireguard_crypto_overhead_ms"], 1.15)
        self.assertAlmostEqual(cr["crypto_latency_reduction_pct"], 90.3)
        self.assertEqual(cr["cross_party_ip_leakage_pct"], 0.0)
        self.assertAlmostEqual(cr["bilateral_attestation_verified_pct"], 100.0)
        self.assertTrue(cr["cleanroom_federation_governed"])
        self.assertEqual(ak["static_secret_exposure_pct"], 100.0)
        self.assertAlmostEqual(ak["oidc_sts_exchange_p95_ms"], 185.0)
        self.assertFalse(ak["cleanroom_federation_governed"])

    def test_embodied_robotics_digital_twin_sandbox(self) -> None:
        sim = simulate_embodied_robotics_digital_twin_sandbox(1_000, "iceoryx_usd_prewarm_cbf_safety_shield")
        raw = simulate_embodied_robotics_digital_twin_sandbox(1_000, "bridge_udp_cold_usd_unfiltered_vla")
        self.assertAlmostEqual(sim["ros2_dds_pubsub_p99_ms"], 0.42)
        self.assertAlmostEqual(sim["ros2_dds_latency_reduction_pct"], 97.2)
        self.assertEqual(sim["control_deadline_miss_pct"], 0.0)
        self.assertAlmostEqual(sim["usd_episode_init_sec"], 1.15)
        self.assertAlmostEqual(sim["usd_init_reduction_pct"], 97.0)
        self.assertAlmostEqual(sim["realtime_physics_speedup_x"], 420.0)
        self.assertAlmostEqual(sim["cbf_safety_filter_overhead_ms"], 0.35)
        self.assertEqual(sim["kinematic_collision_violation_pct"], 0.0)
        self.assertAlmostEqual(sim["wan_blackout_safe_stop_pct"], 100.0)
        self.assertTrue(sim["embodied_safety_governed"])
        self.assertAlmostEqual(raw["ros2_dds_pubsub_p99_ms"], 14.80)
        self.assertAlmostEqual(raw["usd_episode_init_sec"], 38.50)
        self.assertAlmostEqual(raw["kinematic_collision_violation_pct"], 6.8)
        self.assertFalse(raw["embodied_safety_governed"])

    def test_online_rft_verifier_selfplay_sandbox(self) -> None:
        rft = simulate_online_rft_verifier_selfplay_sandbox(1_000, "tree_cow_fork_hermetic_verifier_parquet_stream")
        naive = simulate_online_rft_verifier_selfplay_sandbox(1_000, "full_replay_shared_ns_jsonl_sync")
        self.assertEqual(rft["total_rollout_branches"], 16_000)
        self.assertAlmostEqual(rft["tree_fork_latency_ms"], 68.0)
        self.assertAlmostEqual(rft["group_rollout_wallclock_sec"], 9.2)
        self.assertAlmostEqual(rft["wallclock_reduction_pct"], 79.1)
        self.assertAlmostEqual(rft["vcpu_cost_savings_pct"], 74.8)
        self.assertAlmostEqual(rft["verifier_mount_overhead_ms"], 18.5)
        self.assertEqual(rft["reward_hacking_leakage_pct"], 0.0)
        self.assertAlmostEqual(rft["trajectory_storage_reduction_pct"], 83.4)
        self.assertAlmostEqual(rft["gpu_trainer_stall_pct"], 0.8)
        self.assertTrue(rft["rft_pipeline_governed"])
        self.assertAlmostEqual(naive["group_rollout_wallclock_sec"], 44.0)
        self.assertAlmostEqual(naive["reward_hacking_leakage_pct"], 4.6)
        self.assertAlmostEqual(naive["gpu_trainer_stall_pct"], 29.5)
        self.assertFalse(naive["rft_pipeline_governed"])

    def test_pqc_hybrid_mtls_agent_crypto_agility(self) -> None:
        pqc = simulate_pqc_hybrid_mtls_agent_crypto_agility(10_000, "x25519_mlkem768_mldsa65_hndl_envelope")
        legacy = simulate_pqc_hybrid_mtls_agent_crypto_agility(10_000, "classical_rsa_ecdsa_unresumed_hndl_exposed")
        self.assertAlmostEqual(pqc["mtls_handshake_p95_ms"], 1.65)
        self.assertEqual(pqc["tcp_extra_rtt_split_pct"], 0.0)
        self.assertAlmostEqual(pqc["mldsa65_verify_overhead_ms"], 0.38)
        self.assertAlmostEqual(pqc["total_mcp_admission_ms"], 4.98)
        self.assertEqual(pqc["quantum_forgery_exposure_pct"], 0.0)
        self.assertEqual(pqc["hndl_archive_exposure_pct"], 0.0)
        self.assertTrue(pqc["cnsa2_pqc_compliant"])
        self.assertAlmostEqual(legacy["mtls_handshake_p95_ms"], 26.20)
        self.assertAlmostEqual(legacy["quantum_forgery_exposure_pct"], 100.0)
        self.assertAlmostEqual(legacy["hndl_archive_exposure_pct"], 100.0)
        self.assertFalse(legacy["cnsa2_pqc_compliant"])

    def test_carbon_aware_greenops_fleet_scheduler(self) -> None:
        green = simulate_carbon_aware_greenops_fleet_scheduler(10_000, "watttime_spatiotemporal_amd_pstate_rapl_attribution")
        blind = simulate_carbon_aware_greenops_fleet_scheduler(10_000, "carbon_blind_static_region_performance_governor")
        self.assertAlmostEqual(green["gco2eq_per_1k_tasks"], 94.2)
        self.assertAlmostEqual(green["carbon_reduction_pct"], 77.5)
        self.assertAlmostEqual(green["standby_host_watts"], 148.0)
        self.assertAlmostEqual(green["idle_power_savings_pct"], 63.9)
        self.assertAlmostEqual(green["energy_cost_savings_pct"], 31.4)
        self.assertAlmostEqual(green["csrd_attribution_error_pct"], 1.9)
        self.assertEqual(green["interactive_slo_breach_pct"], 0.0)
        self.assertTrue(green["csrd_greenops_governed"])
        self.assertAlmostEqual(blind["gco2eq_per_1k_tasks"], 418.0)
        self.assertAlmostEqual(blind["standby_host_watts"], 410.0)
        self.assertAlmostEqual(blind["csrd_attribution_error_pct"], 38.0)
        self.assertFalse(blind["csrd_greenops_governed"])

    def test_hyperlight_wasm_microsandbox_dispatch(self) -> None:
        hl = simulate_hyperlight_wasm_microsandbox_dispatch(50_000, "hyperlight_wasi02_wit_zerocopy_hybrid_dispatch")
        vm_only = simulate_hyperlight_wasm_microsandbox_dispatch(50_000, "full_linux_microvm_loopback_http_json_only")
        self.assertAlmostEqual(hl["wasi_cold_start_ms"], 0.85)
        self.assertAlmostEqual(hl["per_sandbox_rss_mib"], 1.8)
        self.assertEqual(hl["sandboxes_per_d96_node"], 48_000)
        self.assertAlmostEqual(hl["wit_abi_serialization_ms"], 0.14)
        self.assertAlmostEqual(hl["serialization_reduction_pct"], 97.8)
        self.assertAlmostEqual(hl["median_mcp_tool_latency_ms"], 1.35)
        self.assertAlmostEqual(hl["fleet_compute_cost_savings_pct"], 64.8)
        self.assertEqual(hl["host_syscall_attack_surface_pct"], 0.0)
        self.assertTrue(hl["hyperlight_hybrid_governed"])
        self.assertAlmostEqual(vm_only["wasi_cold_start_ms"], 108.0)
        self.assertAlmostEqual(vm_only["per_sandbox_rss_mib"], 256.0)
        self.assertEqual(vm_only["sandboxes_per_d96_node"], 1_200)
        self.assertAlmostEqual(vm_only["median_mcp_tool_latency_ms"], 114.40)
        self.assertFalse(vm_only["hyperlight_hybrid_governed"])

    def test_chaos_byzantine_fault_injection_gameday(self) -> None:
        ch = simulate_chaos_byzantine_fault_injection_gameday(10_000, "chaos_studio_epoch_fencing_byzantine_breaker")
        unv = simulate_chaos_byzantine_fault_injection_gameday(10_000, "unverified_runbook_no_fencing_unbounded_retry")
        self.assertAlmostEqual(ch["compound_fault_mttr_sec"], 6.8)
        self.assertAlmostEqual(ch["mttr_reduction_pct"], 99.5)
        self.assertAlmostEqual(ch["task_survival_under_chaos_pct"], 99.94)
        self.assertAlmostEqual(ch["fencing_check_overhead_ms"], 0.22)
        self.assertEqual(ch["split_brain_corruption_pct"], 0.0)
        self.assertAlmostEqual(ch["byzantine_quarantine_sec"], 1.20)
        self.assertAlmostEqual(ch["retry_token_waste_pct"], 0.4)
        self.assertTrue(ch["chaos_resilience_governed"])
        self.assertAlmostEqual(unv["compound_fault_mttr_sec"], 1420.0)
        self.assertAlmostEqual(unv["split_brain_corruption_pct"], 4.8)
        self.assertAlmostEqual(unv["retry_token_waste_pct"], 42.0)
        self.assertFalse(unv["chaos_resilience_governed"])

    def test_scientific_hpc_lustre_mpi_sandbox(self) -> None:
        hpc = simulate_scientific_hpc_lustre_mpi_sandbox(1_000, "amlfs_lustre_kueue_ib_gang_veloc_async_ckpt")
        nfs = simulate_scientific_hpc_lustre_mpi_sandbox(1_000, "nfs_default_scheduler_sync_ckpt")
        self.assertAlmostEqual(hpc["parallel_fs_bandwidth_gbps"], 160.0)
        self.assertAlmostEqual(hpc["dataset_stagein_sec"], 3.1)
        self.assertAlmostEqual(hpc["stagein_reduction_pct"], 97.8)
        self.assertAlmostEqual(hpc["mpi_allreduce_latency_us"], 1.65)
        self.assertEqual(hpc["gang_deadlock_waste_pct"], 0.0)
        self.assertAlmostEqual(hpc["solver_flops_utilization_pct"], 89.6)
        self.assertAlmostEqual(hpc["checkpoint_stall_overhead_pct"], 0.9)
        self.assertTrue(hpc["scientific_hpc_governed"])
        self.assertAlmostEqual(nfs["parallel_fs_bandwidth_gbps"], 8.4)
        self.assertAlmostEqual(nfs["dataset_stagein_sec"], 142.0)
        self.assertAlmostEqual(nfs["gang_deadlock_waste_pct"], 26.4)
        self.assertFalse(nfs["scientific_hpc_governed"])

    def test_agentic_payment_confidential_ledger_guardrail(self) -> None:
        gov = simulate_agentic_payment_confidential_ledger_guardrail(2_500, "hsm_spend_mandate_horizondb_escrow_confidential_ledger")
        raw = simulate_agentic_payment_confidential_ledger_guardrail(2_500, "raw_card_vault_unidempotent_rest")
        self.assertAlmostEqual(gov["mandate_sign_latency_ms"], 1.45)
        self.assertAlmostEqual(gov["escrow_reservation_latency_ms"], 3.80)
        self.assertAlmostEqual(gov["sync_guardrail_p95_ms"], 5.25)
        self.assertEqual(gov["unauthorized_spend_exposure_pct"], 0.0)
        self.assertEqual(gov["duplicate_charge_rate_pct"], 0.0)
        self.assertEqual(gov["merkle_non_repudiation_pct"], 100.0)
        self.assertTrue(gov["payment_ledger_governed"])
        self.assertEqual(raw["unauthorized_spend_exposure_pct"], 100.0)
        self.assertAlmostEqual(raw["duplicate_charge_rate_pct"], 3.8)
        self.assertFalse(raw["payment_ledger_governed"])

    def test_a2a_verified_id_quic_federation_mesh(self) -> None:
        a2a = simulate_a2a_verified_id_quic_federation_mesh(5_000, "entra_verified_id_sdjwt_http3_quic_deadline_budget")
        leg = simulate_a2a_verified_id_quic_federation_mesh(5_000, "raw_oauth_tcp_http1_no_budget")
        self.assertAlmostEqual(a2a["did_sdjwt_verify_ms"], 1.85)
        self.assertEqual(a2a["attribute_overdisclosure_pct"], 0.0)
        self.assertAlmostEqual(a2a["wan_stream_p99_latency_ms"], 38.5)
        self.assertAlmostEqual(a2a["latency_reduction_pct"], 90.8)
        self.assertAlmostEqual(a2a["cascading_timeout_failure_pct"], 0.15)
        self.assertTrue(a2a["a2a_mesh_governed"])
        self.assertEqual(leg["attribute_overdisclosure_pct"], 100.0)
        self.assertAlmostEqual(leg["wan_stream_p99_latency_ms"], 420.0)
        self.assertFalse(leg["a2a_mesh_governed"])

    def test_cyber_defense_detonation_sentinel_sandbox(self) -> None:
        cyb = simulate_cyber_defense_detonation_sentinel_sandbox(1_000, "airgapped_vsock_microvm_krsi_ebpf_sentinel_soar")
        leg = simulate_cyber_defense_detonation_sentinel_sandbox(1_000, "vnet_container_ptrace_manual_soc")
        self.assertEqual(cyb["lateral_network_escape_surface_pct"], 0.0)
        self.assertAlmostEqual(cyb["post_detonation_wipe_ms"], 45.0)
        self.assertAlmostEqual(cyb["telemetry_cpu_overhead_pct"], 1.8)
        self.assertAlmostEqual(cyb["anti_sandbox_evasion_rate_pct"], 0.4)
        self.assertAlmostEqual(cyb["soar_quarantine_propagation_p95_ms"], 680.0)
        self.assertTrue(cyb["cyber_detonation_governed"])
        self.assertEqual(leg["lateral_network_escape_surface_pct"], 100.0)
        self.assertAlmostEqual(leg["anti_sandbox_evasion_rate_pct"], 68.0)
        self.assertFalse(leg["cyber_detonation_governed"])

    def test_edge_disconnected_iot_operations_sandbox(self) -> None:
        edg = simulate_edge_disconnected_iot_operations_sandbox(500, "azure_local_aio_mqtt_saf_onnx_slm_hlc_crdt")
        leg = simulate_edge_disconnected_iot_operations_sandbox(500, "cloud_only_inmemory_mqtt_unthrottled_resync")
        self.assertAlmostEqual(edg["disconnected_availability_pct"], 99.98)
        self.assertAlmostEqual(edg["edge_ttft_p95_ms"], 18.4)
        self.assertAlmostEqual(edg["state_compaction_reduction_pct"], 91.4)
        self.assertEqual(edg["outage_checkpoint_loss_pct"], 0.0)
        self.assertAlmostEqual(edg["twin_reconciliation_sec"], 14.2)
        self.assertTrue(edg["edge_continuity_governed"])
        self.assertEqual(leg["disconnected_availability_pct"], 0.0)
        self.assertAlmostEqual(leg["outage_checkpoint_loss_pct"], 98.7)
        self.assertFalse(leg["edge_continuity_governed"])

    def test_healthcare_fhir_dicom_cfr11_sandbox(self) -> None:
        reg = simulate_healthcare_fhir_dicom_cfr11_sandbox(500, "ahds_fhir_dicom_cast_presidio_fpe_cfr11_hsm")
        unr = simulate_healthcare_fhir_dicom_cfr11_sandbox(500, "unredacted_rest_json_unsigned_clinical_writes")
        self.assertAlmostEqual(reg["dicom_volume_load_p95_ms"], 185.0)
        self.assertAlmostEqual(reg["dicom_load_reduction_pct"], 96.2)
        self.assertAlmostEqual(reg["phi_safe_harbor_recall_pct"], 99.94)
        self.assertEqual(reg["external_llm_raw_phi_exposure_pct"], 0.0)
        self.assertEqual(reg["unsigned_clinical_mutation_rate_pct"], 0.0)
        self.assertTrue(reg["hipaa_cfr11_compliance_slo_met"])
        self.assertEqual(unr["external_llm_raw_phi_exposure_pct"], 100.0)
        self.assertFalse(unr["hipaa_cfr11_compliance_slo_met"])

    def test_quantum_classical_hybrid_qir_sandbox(self) -> None:
        qir = simulate_quantum_classical_hybrid_qir_sandbox(250, "qir_llvm_cuquantum_prefilter_floquet_qec")
        raw = simulate_quantum_classical_hybrid_qir_sandbox(250, "raw_qasm_cpu_direct_unmitigated_qpu")
        self.assertAlmostEqual(qir["cuquantum_36q_sim_ms"], 14.5)
        self.assertAlmostEqual(qir["qpu_shot_spend_reduction_pct"], 88.6)
        self.assertAlmostEqual(qir["qir_transpile_latency_ms"], 19.2)
        self.assertEqual(qir["invalid_topology_rejection_pct"], 0.0)
        self.assertAlmostEqual(qir["chemical_accuracy_attainment_pct"], 96.8)
        self.assertTrue(qir["quantum_hybrid_governed"])
        self.assertAlmostEqual(raw["invalid_topology_rejection_pct"], 24.6)
        self.assertFalse(raw["quantum_hybrid_governed"])

    def test_telco_oran_network_slicing_sandbox(self) -> None:
        oran = simulate_telco_oran_network_slicing_sandbox(5_000, "operator_nexus_sriov_dpdk_nearrt_xapp_3gpp_verifier")
        leg = simulate_telco_oran_network_slicing_sandbox(5_000, "kernel_veth_remote_llm_unverified_slice_mutation")
        self.assertAlmostEqual(oran["userplane_forwarding_p99_us"], 38.0)
        self.assertEqual(oran["microburst_packet_drop_pct"], 0.0)
        self.assertAlmostEqual(oran["nearrt_e2_loop_p99_ms"], 4.2)
        self.assertAlmostEqual(oran["e2_latency_reduction_pct"], 98.8)
        self.assertEqual(oran["urllc_sla_violation_rate_pct"], 0.0)
        self.assertAlmostEqual(oran["slice_provisioning_sec"], 11.5)
        self.assertTrue(oran["telco_oran_slo_met"])
        self.assertAlmostEqual(leg["urllc_sla_violation_rate_pct"], 16.4)
        self.assertFalse(leg["telco_oran_slo_met"])

    def test_space_orbital_satellite_edge_sandbox(self) -> None:
        orb = simulate_space_orbital_satellite_edge_sandbox(120, "orbital_isl_bpv7_rad_triage_seu_interlock")
        raw = simulate_space_orbital_satellite_edge_sandbox(120, "raw_downlink_tcp_http_unshielded_ram")
        self.assertAlmostEqual(orb["anomaly_detection_latency_sec"], 18.5)
        self.assertAlmostEqual(orb["downlink_bandwidth_reduction_pct"], 96.8)
        self.assertAlmostEqual(orb["bpv7_tool_delivery_rate_pct"], 99.98)
        self.assertEqual(orb["tcp_session_reset_failure_pct"], 0.0)
        self.assertEqual(orb["seu_unsafe_actuation_leak_pct"], 0.0)
        self.assertTrue(orb["orbital_edge_governed"])
        self.assertAlmostEqual(raw["tcp_session_reset_failure_pct"], 78.4)
        self.assertFalse(raw["orbital_edge_governed"])

    def test_smart_grid_iec61850_pmu_sandbox(self) -> None:
        grid = simulate_smart_grid_iec61850_pmu_sandbox(500, "pmu_edge_fft_acopf_barrier_goose_interlock")
        raw = simulate_smart_grid_iec61850_pmu_sandbox(500, "raw_wan_pmu_unverified_llm_scada_write")
        self.assertAlmostEqual(grid["pmu_fault_localization_ms"], 6.2)
        self.assertAlmostEqual(grid["wan_telemetry_compression_pct"], 98.4)
        self.assertAlmostEqual(grid["acopf_verify_latency_ms"], 14.8)
        self.assertEqual(grid["n1_thermal_overload_rate_pct"], 0.0)
        self.assertAlmostEqual(grid["der_curtailment_reduction_pct"], 31.5)
        self.assertEqual(grid["unsafe_breaker_sync_violation_pct"], 0.0)
        self.assertAlmostEqual(grid["goose_hardware_trip_ms"], 1.8)
        self.assertTrue(grid["smart_grid_slo_met"])
        self.assertAlmostEqual(raw["n1_thermal_overload_rate_pct"], 11.8)
        self.assertFalse(raw["smart_grid_slo_met"])

    def test_supplychain_amr_mapf_coldchain_sandbox(self) -> None:
        scm = simulate_supplychain_amr_mapf_coldchain_sandbox(2_000, "edge_rfid_fusion_mapf_cbs_arrhenius_guard")
        raw = simulate_supplychain_amr_mapf_coldchain_sandbox(2_000, "raw_cloud_video_greedy_routing_reactive_alarm")
        self.assertEqual(scm["mapf_solver_nodes"], 8)
        self.assertAlmostEqual(scm["wan_egress_reduction_pct"], 98.1)
        self.assertAlmostEqual(scm["sku_inventory_accuracy_pct"], 99.94)
        self.assertAlmostEqual(scm["mapf_cbs_solve_latency_ms"], 11.4)
        self.assertEqual(scm["amr_deadlock_collision_rate_pct"], 0.0)
        self.assertAlmostEqual(scm["picks_per_hour_gain_pct"], 34.8)
        self.assertEqual(scm["cold_chain_spoilage_rate_pct"], 0.0)
        self.assertEqual(scm["duplicate_edi_order_mutation_pct"], 0.0)
        self.assertTrue(scm["supplychain_slo_met"])
        self.assertAlmostEqual(raw["amr_deadlock_collision_rate_pct"], 8.6)
        self.assertFalse(raw["supplychain_slo_met"])

    def test_media_openusd_3dgs_c2pa_sandbox(self) -> None:
        med = simulate_media_openusd_3dgs_c2pa_sandbox(32, "nvdec_dma_openusd_verifier_c2pa_hsm")
        raw = simulate_media_openusd_3dgs_c2pa_sandbox(32, "cpu_ffmpeg_unverified_bpy_unsigned_media")
        self.assertEqual(med["render_gpu_nodes"], 4)
        self.assertAlmostEqual(med["frame_to_tensor_latency_ms"], 6.8)
        self.assertAlmostEqual(med["host_cpu_reduction_pct"], 88.5)
        self.assertAlmostEqual(med["scene_corruption_catch_rate_pct"], 99.6)
        self.assertEqual(med["gpu_render_node_crash_rate_pct"], 0.0)
        self.assertAlmostEqual(med["incremental_3dgs_rerender_saving_pct"], 74.2)
        self.assertAlmostEqual(med["c2pa_hsm_signing_latency_ms"], 4.2)
        self.assertEqual(med["unsigned_synthetic_media_egress_pct"], 0.0)
        self.assertTrue(med["media_production_slo_met"])
        self.assertAlmostEqual(raw["gpu_render_node_crash_rate_pct"], 9.4)
        self.assertFalse(raw["media_production_slo_met"])

    def test_automotive_sdv_v2x_ota_sandbox(self) -> None:
        sdv = simulate_automotive_sdv_v2x_ota_sandbox(50_000, "v2x_quic_delta_carla_rss_uptane_ota")
        raw = simulate_automotive_sdv_v2x_ota_sandbox(50_000, "raw_rosbag_tcp_unverified_ota")
        self.assertEqual(sdv["carla_sim_gpu_nodes"], 8)
        self.assertAlmostEqual(sdv["cellular_uplink_reduction_pct"], 91.8)
        self.assertAlmostEqual(sdv["v2x_ingest_p99_latency_ms"], 64.0)
        self.assertAlmostEqual(sdv["carla_1k_replay_wallclock_sec"], 18.5)
        self.assertEqual(sdv["rss_ttc_violation_escape_pct"], 0.0)
        self.assertEqual(sdv["in_motion_ecu_ota_attempt_pct"], 0.0)
        self.assertEqual(sdv["bricked_ecu_rate_pct"], 0.0)
        self.assertAlmostEqual(sdv["ab_ota_rollback_sec"], 4.5)
        self.assertTrue(sdv["automotive_sdv_slo_met"])
        self.assertAlmostEqual(raw["rss_ttc_violation_escape_pct"], 6.2)
        self.assertFalse(raw["automotive_sdv_slo_met"])

    def test_semiconductor_eda_rtl_gdsii_sandbox(self) -> None:
        eda = simulate_semiconductor_eda_rtl_gdsii_sandbox(1_000, "verilator_ast_cache_symbiyosys_lec_flexnet_lease")
        raw = simulate_semiconductor_eda_rtl_gdsii_sandbox(1_000, "cold_compile_testbench_only_unmanaged_lmgrd")
        self.assertEqual(eda["eda_compute_nodes"], 8)
        self.assertAlmostEqual(eda["regression_wallclock_sec"], 62.0)
        self.assertAlmostEqual(eda["rtl_sim_speed_khz"], 185.0)
        self.assertEqual(eda["silicon_bug_escape_pct"], 0.0)
        self.assertEqual(eda["negative_wns_drc_escape_pct"], 0.0)
        self.assertEqual(eda["flexnet_license_deadlock_pct"], 0.0)
        self.assertAlmostEqual(eda["flexnet_seat_utilization_pct"], 96.8)
        self.assertAlmostEqual(eda["zombie_seat_reclaim_sec"], 3.0)
        self.assertTrue(eda["semiconductor_eda_slo_met"])
        self.assertAlmostEqual(raw["flexnet_license_deadlock_pct"], 19.5)
        self.assertFalse(raw["semiconductor_eda_slo_met"])

    def test_biopharma_alphafold_wetlab_sila2_sandbox(self) -> None:
        bio = simulate_biopharma_alphafold_wetlab_sila2_sandbox(2_000, "mmseqs2_gpu_msa_fep_sila2_securedna_guard")
        raw = simulate_biopharma_alphafold_wetlab_sila2_sandbox(2_000, "cpu_jackhmmer_unchecked_pipette_unscreened_seq")
        self.assertEqual(bio["biopharma_gpu_nodes"], 8)
        self.assertAlmostEqual(bio["msa_alignment_latency_sec"], 4.8)
        self.assertAlmostEqual(bio["af3_fep_batch_wallclock_min"], 14.5)
        self.assertEqual(bio["wetlab_deck_collision_or_incompat_pct"], 0.0)
        self.assertAlmostEqual(bio["reagent_waste_reduction_pct"], 78.4)
        self.assertEqual(bio["regulated_toxin_synthesis_escape_pct"], 0.0)
        self.assertAlmostEqual(bio["securedna_screen_latency_ms"], 18.0)
        self.assertTrue(bio["biopharma_wetlab_slo_met"])
        self.assertAlmostEqual(raw["wetlab_deck_collision_or_incompat_pct"], 7.6)
        self.assertFalse(raw["biopharma_wetlab_slo_met"])

    def test_quant_trading_fix_afxdp_risk_sandbox(self) -> None:
        qnt = simulate_quant_trading_fix_afxdp_risk_sandbox(200, "afxdp_itch_fpga_15c35_ptp_audit")
        raw = simulate_quant_trading_fix_afxdp_risk_sandbox(200, "kernel_tcp_json_unfiltered_ntp_clock")
        self.assertEqual(qnt["quant_fx_nodes"], 8)
        self.assertAlmostEqual(qnt["tick_to_signal_latency_us"], 11.5)
        self.assertEqual(qnt["microburst_packet_drop_pct"], 0.0)
        self.assertAlmostEqual(qnt["pretrade_risk_gate_us"], 1.8)
        self.assertEqual(qnt["rogue_fat_finger_escape_pct"], 0.0)
        self.assertAlmostEqual(qnt["kill_switch_cancel_all_us"], 85.0)
        self.assertAlmostEqual(qnt["ptp_clock_drift_ns"], 180.0)
        self.assertAlmostEqual(qnt["cat_mifid_audit_completeness_pct"], 100.0)
        self.assertTrue(qnt["quant_trading_slo_met"])
        self.assertAlmostEqual(raw["rogue_fat_finger_escape_pct"], 5.4)
        self.assertFalse(raw["quant_trading_slo_met"])

    def test_retail_pos_esl_vision_edge_sandbox(self) -> None:
        ret = simulate_retail_pos_esl_vision_edge_sandbox(500, "arc_edge_trt_pawr_esl_pci_blur")
        raw = simulate_retail_pos_esl_vision_edge_sandbox(500, "cloud_rtsp_backhaul_unicast_esl_raw_video")
        self.assertEqual(ret["store_edge_appliances"], 500)
        self.assertEqual(ret["total_esl_tags"], 25_000_000)
        self.assertAlmostEqual(ret["checkout_sku_swap_latency_ms"], 28.0)
        self.assertAlmostEqual(ret["wan_bandwidth_reduction_pct"], 97.8)
        self.assertAlmostEqual(ret["esl_50k_sync_latency_sec"], 18.5)
        self.assertEqual(ret["shelf_pos_price_mismatch_pct"], 0.0)
        self.assertAlmostEqual(ret["inline_privacy_blur_latency_ms"], 1.4)
        self.assertEqual(ret["pci_gdpr_biometric_leak_pct"], 0.0)
        self.assertTrue(ret["retail_edge_slo_met"])
        self.assertAlmostEqual(raw["shelf_pos_price_mismatch_pct"], 4.8)
        self.assertFalse(raw["retail_edge_slo_met"])

    def test_aviation_irops_swim_do178c_sandbox(self) -> None:
        avn = simulate_aviation_irops_swim_do178c_sandbox(1_000, "swim_cuopt_part117_mel_do178c_rvsm")
        raw = simulate_aviation_irops_swim_do178c_sandbox(1_000, "batch_milp_unchecked_part117_raw_cpdlc")
        self.assertEqual(avn["irops_solver_nodes"], 4)
        self.assertAlmostEqual(avn["irops_recovery_solve_sec"], 14.2)
        self.assertAlmostEqual(avn["passenger_delay_reduction_pct"], 41.8)
        self.assertAlmostEqual(avn["part117_mel_legality_gate_ms"], 4.5)
        self.assertEqual(avn["illegal_crew_or_mel_dispatch_pct"], 0.0)
        self.assertAlmostEqual(avn["rvsm_separation_check_ms"], 2.1)
        self.assertEqual(avn["loss_of_separation_advisory_pct"], 0.0)
        self.assertTrue(avn["aviation_irops_slo_met"])
        self.assertAlmostEqual(raw["illegal_crew_or_mel_dispatch_pct"], 6.4)
        self.assertFalse(raw["aviation_irops_slo_met"])

    def test_datacenter_cooling_bacnet_pue_sandbox(self) -> None:
        dcc = simulate_datacenter_cooling_bacnet_pue_sandbox(100, "bacnet_pinn_mpc_dewpoint_leak_interlock")
        raw = simulate_datacenter_cooling_bacnet_pue_sandbox(100, "reactive_pid_unchecked_dewpoint_slow_bms")
        self.assertEqual(dcc["cooling_control_nodes"], 4)
        self.assertAlmostEqual(dcc["thermal_mpc_loop_sec"], 0.42)
        self.assertAlmostEqual(dcc["annualized_facility_pue"], 1.12)
        self.assertAlmostEqual(dcc["cooling_overhead_reduction_pct"], 64.7)
        self.assertAlmostEqual(dcc["dewpoint_psychrometric_gate_ms"], 1.8)
        self.assertEqual(dcc["condensation_or_tjmax_throttle_pct"], 0.0)
        self.assertAlmostEqual(dcc["coolant_leak_valve_trip_ms"], 38.0)
        self.assertEqual(dcc["server_blade_liquid_damage_pct"], 0.0)
        self.assertTrue(dcc["datacenter_cooling_slo_met"])
        self.assertAlmostEqual(raw["annualized_facility_pue"], 1.34)
        self.assertFalse(raw["datacenter_cooling_slo_met"])

    def test_maritime_port_crane_colregs_sandbox(self) -> None:
        prt = simulate_maritime_port_crane_colregs_sandbox(50_000, "ais_cuopt_stowage_imo_gm_colregs_barrier")
        raw = simulate_maritime_port_crane_colregs_sandbox(50_000, "batch_heuristic_unchecked_gm_raw_vts")
        self.assertEqual(prt["port_solver_nodes"], 4)
        self.assertAlmostEqual(prt["stowage_crane_solve_sec"], 8.6)
        self.assertAlmostEqual(prt["berth_turnaround_reduction_pct"], 28.4)
        self.assertAlmostEqual(prt["yard_rehandle_elimination_pct"], 94.5)
        self.assertAlmostEqual(prt["imo_gm_stability_gate_ms"], 3.2)
        self.assertEqual(prt["unsafe_vessel_stability_or_stack_pct"], 0.0)
        self.assertAlmostEqual(prt["colregs_cpa_barrier_ms"], 1.9)
        self.assertEqual(prt["colregs_or_crane_collision_escape_pct"], 0.0)
        self.assertTrue(prt["maritime_port_slo_met"])
        self.assertAlmostEqual(raw["unsafe_vessel_stability_or_stack_pct"], 4.6)
        self.assertFalse(raw["maritime_port_slo_met"])

    def test_rail_ertms_etcs_sil4_sandbox(self) -> None:
        rail = simulate_rail_ertms_etcs_sil4_sandbox(500, "frmcs_cuopt_reschedule_sil4_evc_wayside_edge")
        raw = simulate_rail_ertms_etcs_sil4_sandbox(500, "batch_milp_unchecked_ma_raw_wayside_stream")
        self.assertEqual(rail["rail_solver_nodes"], 4)
        self.assertAlmostEqual(rail["timetable_reschedule_solve_sec"], 6.4)
        self.assertAlmostEqual(rail["knock_on_delay_reduction_pct"], 46.2)
        self.assertAlmostEqual(rail["moving_block_headway_gain_pct"], 24.0)
        self.assertAlmostEqual(rail["sil4_braking_curve_gate_ms"], 1.5)
        self.assertEqual(rail["spad_or_conflicting_route_escape_pct"], 0.0)
        self.assertAlmostEqual(rail["wayside_defect_triage_ms"], 12.0)
        self.assertAlmostEqual(rail["frmcs_backhaul_reduction_pct"], 97.4)
        self.assertEqual(rail["unscheduled_in_tunnel_halt_pct"], 0.0)
        self.assertTrue(rail["rail_ertms_slo_met"])
        self.assertAlmostEqual(raw["spad_or_conflicting_route_escape_pct"], 3.2)
        self.assertFalse(raw["rail_ertms_slo_met"])

    def test_mining_ahs_iso21815_sandbox(self) -> None:
        gov = simulate_mining_ahs_iso21815_sandbox(120, "cuopt_dispatch_iso21815_georadar_interlock")
        raw = simulate_mining_ahs_iso21815_sandbox(120, "fixed_shift_dispatch_unchecked_collision_raw_radar")
        self.assertEqual(gov["mining_solver_nodes"], 4)
        self.assertEqual(gov["haul_dispatch_reoptimize_sec"], 4.2)
        self.assertLess(gov["haul_dispatch_reoptimize_sec"], raw["haul_dispatch_reoptimize_sec"])
        self.assertEqual(gov["truck_queue_waiting_reduction_pct"], 41.5)
        self.assertEqual(gov["crusher_feed_grade_variance_reduction_pct"], 64.0)
        self.assertEqual(gov["iso21815_collision_interlock_ms"], 2.2)
        self.assertEqual(gov["haul_road_collision_escape_pct"], 0.0)
        self.assertGreater(raw["haul_road_collision_escape_pct"], 2.0)
        self.assertEqual(gov["slope_deformation_alarm_triage_ms"], 18.0)
        self.assertEqual(gov["pit_backhaul_bandwidth_reduction_pct"], 96.8)
        self.assertEqual(gov["unevacuated_bench_rockfall_exposure_pct"], 0.0)
        self.assertTrue(gov["mining_ahs_slo_met"])
        self.assertFalse(raw["mining_ahs_slo_met"])

    def test_smart_building_ashrae_nfpa72_sandbox(self) -> None:
        gov = simulate_smart_building_ashrae_nfpa72_sandbox(500, "adt_mpc_ashrae62_elevator_nfpa72_interlock")
        raw = simulate_smart_building_ashrae_nfpa72_sandbox(500, "static_schedule_unchecked_co2_unisolated_bacnet")
        self.assertEqual(gov["campus_edge_nodes"], 4)
        self.assertEqual(gov["monitored_vav_zones"], 12_000)
        self.assertEqual(gov["hvac_lighting_energy_reduction_pct"], 31.8)
        self.assertEqual(gov["peak_demand_charge_reduction_pct"], 26.4)
        self.assertEqual(gov["elevator_lobby_wait_reduction_pct"], 38.2)
        self.assertEqual(gov["ashrae62_iaq_gate_ms"], 1.6)
        self.assertEqual(gov["indoor_co2_violation_pct"], 0.0)
        self.assertGreater(raw["indoor_co2_violation_pct"], 4.0)
        self.assertEqual(gov["nfpa72_lifesafety_interlock_ms"], 0.8)
        self.assertEqual(gov["smoke_damper_override_escape_pct"], 0.0)
        self.assertGreater(raw["smoke_damper_override_escape_pct"], 2.0)
        self.assertTrue(gov["smart_building_slo_met"])
        self.assertFalse(raw["smart_building_slo_met"])

    def test_precision_ag_isobus_ndvi_sandbox(self) -> None:
        gov = simulate_precision_ag_isobus_ndvi_sandbox(100, "fao56_vra_iso11783_epa_drift_uav_edge")
        raw = simulate_precision_ag_isobus_ndvi_sandbox(100, "uniform_blanket_spray_unchecked_drift_raw_uav_upload")
        self.assertEqual(gov["ag_solver_nodes"], 4)
        self.assertEqual(gov["autonomous_isobus_tractors"], 80)
        self.assertEqual(gov["chemical_herbicide_reduction_pct"], 42.6)
        self.assertEqual(gov["irrigation_water_reduction_pct"], 34.8)
        self.assertEqual(gov["iso11783_epa_drift_gate_ms"], 1.9)
        self.assertEqual(gov["waterway_spray_drift_escape_pct"], 0.0)
        self.assertGreater(raw["waterway_spray_drift_escape_pct"], 3.0)
        self.assertEqual(gov["uav_ndvi_edge_triage_ms"], 22.0)
        self.assertEqual(gov["rural_wan_bandwidth_reduction_pct"], 96.4)
        self.assertEqual(gov["crop_row_trampling_escape_pct"], 0.0)
        self.assertGreater(raw["crop_row_trampling_escape_pct"], 2.0)
        self.assertTrue(gov["precision_ag_slo_met"])
        self.assertFalse(raw["precision_ag_slo_met"])

    def test_water_utility_ro_scada_sdwa_sandbox(self) -> None:
        gov = simulate_water_utility_ro_scada_sdwa_sandbox(500, "ro_fouling_mpc_epa_sdwa_acoustic_edge")
        raw = simulate_water_utility_ro_scada_sdwa_sandbox(500, "fixed_flux_ro_unverified_modbus_raw_hydrophone")
        self.assertEqual(gov["water_solver_nodes"], 4)
        self.assertEqual(gov["distribution_acoustic_sensors"], 4_000)
        self.assertEqual(gov["ro_specific_energy_reduction_pct"], 16.4)
        self.assertEqual(gov["non_revenue_water_leak_reduction_pct"], 38.5)
        self.assertEqual(gov["epa_sdwa_chlorine_interlock_ms"], 1.6)
        self.assertEqual(gov["chemical_overdose_escape_pct"], 0.0)
        self.assertGreater(raw["chemical_overdose_escape_pct"], 2.0)
        self.assertEqual(gov["acoustic_leak_edge_triage_ms"], 19.0)
        self.assertEqual(gov["cellular_ami_bandwidth_reduction_pct"], 95.8)
        self.assertEqual(gov["water_hammer_pressure_transient_escape_pct"], 0.0)
        self.assertGreater(raw["water_hammer_pressure_transient_escape_pct"], 2.5)
        self.assertTrue(gov["water_utility_slo_met"])
        self.assertFalse(raw["water_utility_slo_met"])

    def test_emergency_wildfire_cad_nims_sandbox(self) -> None:
        gov = simulate_emergency_wildfire_cad_nims_sandbox(160, "wrf_sfire_cuopt_nims_ics_lwir_edge")
        raw = simulate_emergency_wildfire_cad_nims_sandbox(160, "static_isochrone_unverified_cad_raw_lwir")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["aerial_lwir_drones_and_towers"], 40)
        self.assertEqual(gov["evacuation_clearance_time_reduction_pct"], 29.4)
        self.assertEqual(gov["fireline_containment_efficiency_gain_pct"], 33.8)
        self.assertEqual(gov["nims_ics_interlock_latency_ms"], 2.1)
        self.assertEqual(gov["premature_evac_downgrade_or_burnover_escape_pct"], 0.0)
        self.assertGreater(raw["premature_evac_downgrade_or_burnover_escape_pct"], 2.0)
        self.assertEqual(gov["lwir_thermal_hotspot_edge_triage_ms"], 17.0)
        self.assertEqual(gov["firstnet_satcom_bandwidth_reduction_pct"], 96.6)
        self.assertEqual(gov["cad_multi_agency_dispatch_conflict_pct"], 0.0)
        self.assertGreater(raw["cad_multi_agency_dispatch_conflict_pct"], 3.0)
        self.assertTrue(gov["emergency_wildfire_slo_met"])
        self.assertFalse(raw["emergency_wildfire_slo_met"])

    def test_offshore_wind_subsea_rov_esd_sandbox(self) -> None:
        gov = simulate_offshore_wind_subsea_rov_esd_sandbox(240, "wake_mpc_dnv_sil3_esd_das_edge")
        raw = simulate_offshore_wind_subsea_rov_esd_sandbox(240, "greedy_yaw_unchecked_scada_raw_sonar")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["subsea_rov_and_das_interrogators"], 40)
        self.assertEqual(gov["array_wake_loss_energy_gain_pct"], 11.8)
        self.assertEqual(gov["vessel_rov_inspection_cost_reduction_pct"], 46.2)
        self.assertEqual(gov["dnv_api1173_sil3_esd_gate_ms"], 1.4)
        self.assertEqual(gov["maop_overpressure_or_esd_bypass_escape_pct"], 0.0)
        self.assertGreater(raw["maop_overpressure_or_esd_bypass_escape_pct"], 2.0)
        self.assertEqual(gov["das_anchor_drag_edge_triage_ms"], 14.0)
        self.assertEqual(gov["offshore_vsat_bandwidth_reduction_pct"], 97.2)
        self.assertEqual(gov["rov_tether_collision_escape_pct"], 0.0)
        self.assertGreater(raw["rov_tether_collision_escape_pct"], 2.5)
        self.assertTrue(gov["offshore_subsea_slo_met"])
        self.assertFalse(raw["offshore_subsea_slo_met"])

    def test_circular_recycling_battery_xrf_sandbox(self) -> None:
        gov = simulate_circular_recycling_battery_xrf_sandbox(120, "cad_torque_xrf_ul9540a_lwir_edge")
        raw = simulate_circular_recycling_battery_xrf_sandbox(120, "fixed_trajectory_unverified_cutter_raw_hsi")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["robotic_disassembly_and_xrf_cells"], 40)
        self.assertEqual(gov["critical_mineral_recovery_yield_gain_pct"], 23.6)
        self.assertEqual(gov["disassembly_cycle_time_reduction_pct"], 37.5)
        self.assertEqual(gov["ul9540a_nfpa855_thermal_gate_ms"], 0.8)
        self.assertEqual(gov["thermal_runaway_puncture_escape_pct"], 0.0)
        self.assertGreater(raw["thermal_runaway_puncture_escape_pct"], 2.0)
        self.assertEqual(gov["hsi_xrf_lwir_edge_triage_ms"], 9.0)
        self.assertEqual(gov["recycling_wan_bandwidth_reduction_pct"], 96.9)
        self.assertEqual(gov["corroded_bolt_strip_or_tool_break_pct"], 0.0)
        self.assertGreater(raw["corroded_bolt_strip_or_tool_break_pct"], 3.5)
        self.assertTrue(gov["circular_recycling_slo_met"])
        self.assertFalse(raw["circular_recycling_slo_met"])

    def test_steelmaking_eaf_casting_sil3_sandbox(self) -> None:
        gov = simulate_steelmaking_eaf_casting_sil3_sandbox(8, "eaf_foaming_mpc_mold_pinns_sil3_edge")
        raw = simulate_steelmaking_eaf_casting_sil3_sandbox(8, "static_tap_chart_unverified_lance_raw_ir")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["eaf_furnaces_and_caster_strands"], 24)
        self.assertEqual(gov["eaf_specific_power_reduction_kwh_per_ton"], 44.5)
        self.assertEqual(gov["electrode_consumption_reduction_pct"], 18.4)
        self.assertEqual(gov["nfpa86_sil3_molten_water_gate_ms"], 0.9)
        self.assertEqual(gov["wet_scrap_explosion_or_mold_breakout_escape_pct"], 0.0)
        self.assertGreater(raw["wet_scrap_explosion_or_mold_breakout_escape_pct"], 1.5)
        self.assertEqual(gov["slag_camera_libs_edge_triage_ms"], 8.0)
        self.assertEqual(gov["meltshop_wan_bandwidth_reduction_pct"], 97.1)
        self.assertEqual(gov["off_spec_ladle_chemistry_reheat_pct"], 0.0)
        self.assertGreater(raw["off_spec_ladle_chemistry_reheat_pct"], 3.0)
        self.assertTrue(gov["steelmaking_eaf_slo_met"])
        self.assertFalse(raw["steelmaking_eaf_slo_met"])

    def test_cement_kiln_ccus_pyro_sandbox(self) -> None:
        gov = simulate_cement_kiln_ccus_pyro_sandbox(20000, "pyro_mpc_amine_ccus_en746_co_edge")
        raw = simulate_cement_kiln_ccus_pyro_sandbox(20000, "manual_burner_unverified_rdf_raw_kiln_ir")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["rotary_kilns_and_amine_absorbers"], 8)
        self.assertEqual(gov["alternative_rdf_substitution_gain_pct"], 26.8)
        self.assertEqual(gov["ccus_amine_reboiler_steam_saving_pct"], 19.4)
        self.assertEqual(gov["en746_nfpa86_co_esp_gate_ms"], 1.1)
        self.assertEqual(gov["esp_co_explosion_or_red_kiln_escape_pct"], 0.0)
        self.assertGreater(raw["esp_co_explosion_or_red_kiln_escape_pct"], 1.5)
        self.assertEqual(gov["kiln_shell_ir_pgnna_edge_triage_ms"], 11.0)
        self.assertEqual(gov["cement_plant_wan_bandwidth_reduction_pct"], 96.7)
        self.assertEqual(gov["clinker_free_lime_off_spec_pct"], 0.0)
        self.assertGreater(raw["clinker_free_lime_off_spec_pct"], 4.0)
        self.assertTrue(gov["cement_kiln_ccus_slo_met"])
        self.assertFalse(raw["cement_kiln_ccus_slo_met"])

    def test_green_hydrogen_electrolyzer_ammonia_sandbox(self) -> None:
        gov = simulate_green_hydrogen_electrolyzer_ammonia_sandbox(1000, "load_following_mpc_haber_bosch_iso22734_edge")
        raw = simulate_green_hydrogen_electrolyzer_ammonia_sandbox(1000, "static_rectifier_unverified_dp_raw_eis_stream")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["electrolyzer_trains_and_nh3_reactors"], 20)
        self.assertEqual(gov["stack_specific_energy_saving_pct"], 11.8)
        self.assertEqual(gov["green_ammonia_curtailment_yield_gain_pct"], 23.6)
        self.assertEqual(gov["iso22734_sil3_h2_in_o2_gate_ms"], 0.9)
        self.assertEqual(gov["h2_in_o2_crossover_or_catalyst_poison_escape_pct"], 0.0)
        self.assertGreater(raw["h2_in_o2_crossover_or_catalyst_poison_escape_pct"], 1.4)
        self.assertEqual(gov["cell_eis_thermal_edge_triage_ms"], 9.5)
        self.assertEqual(gov["hydrogen_plant_wan_bandwidth_reduction_pct"], 96.8)
        self.assertEqual(gov["membrane_dp_pinhole_degradation_pct"], 0.0)
        self.assertGreater(raw["membrane_dp_pinhole_degradation_pct"], 3.0)
        self.assertTrue(gov["green_hydrogen_ammonia_slo_met"])
        self.assertFalse(raw["green_hydrogen_ammonia_slo_met"])

    def test_fusion_tokamak_plasma_quench_sandbox(self) -> None:
        gov = simulate_fusion_tokamak_plasma_quench_sandbox(500, "grad_shafranov_mhd_detachment_sil3_spi_edge")
        raw = simulate_fusion_tokamak_plasma_quench_sandbox(500, "open_loop_pid_unmitigated_disruption_raw_mirnov")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["pf_coils_and_ech_gyrotrons"], 40)
        self.assertEqual(gov["h_mode_pulse_duration_gain_pct"], 48.5)
        self.assertEqual(gov["divertor_peak_heat_flux_reduction_pct"], 36.4)
        self.assertEqual(gov["iec61508_sil3_spi_quench_gate_ms"], 0.4)
        self.assertEqual(gov["runaway_electron_or_hts_quench_escape_pct"], 0.0)
        self.assertGreater(raw["runaway_electron_or_hts_quench_escape_pct"], 1.5)
        self.assertEqual(gov["mirnov_thomson_edge_triage_ms"], 2.5)
        self.assertEqual(gov["fusion_diagnostics_wan_bandwidth_reduction_pct"], 97.6)
        self.assertEqual(gov["divertor_tungsten_recrystallization_pct"], 0.0)
        self.assertGreater(raw["divertor_tungsten_recrystallization_pct"], 3.5)
        self.assertTrue(gov["fusion_tokamak_slo_met"])
        self.assertFalse(raw["fusion_tokamak_slo_met"])

    def test_particle_accelerator_synchrotron_beam_sandbox(self) -> None:
        gov = simulate_particle_accelerator_synchrotron_beam_sandbox(36, "fofb_srf_microphonics_mpc_sil3_mps_edge")
        raw = simulate_particle_accelerator_synchrotron_beam_sandbox(36, "manual_orbit_correction_unverified_blm_raw_epics")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["srf_cryomodules_and_undulators"], 72)
        self.assertEqual(gov["photon_beam_emittance_stability_gain_pct"], 42.8)
        self.assertEqual(gov["srf_cavity_rf_overhead_power_saving_pct"], 34.5)
        self.assertEqual(gov["iec61508_sil3_mps_beam_dump_gate_ms"], 0.05)
        self.assertEqual(gov["undulator_demagnetization_or_vacuum_breach_escape_pct"], 0.0)
        self.assertGreater(raw["undulator_demagnetization_or_vacuum_breach_escape_pct"], 1.5)
        self.assertEqual(gov["epics_pvaccess_detector_edge_triage_ms"], 1.8)
        self.assertEqual(gov["beamline_wan_bandwidth_reduction_pct"], 97.9)
        self.assertEqual(gov["srf_lorentz_detuning_trip_pct"], 0.0)
        self.assertGreater(raw["srf_lorentz_detuning_trip_pct"], 3.0)
        self.assertTrue(gov["accelerator_beam_slo_met"])
        self.assertFalse(raw["accelerator_beam_slo_met"])

    def test_deep_space_telescope_adaptive_optics_sandbox(self) -> None:
        gov = simulate_deep_space_telescope_adaptive_optics_sandbox(64, "xao_deformable_mirror_mpc_lgs_airspace_edge")
        raw = simulate_deep_space_telescope_adaptive_optics_sandbox(64, "classic_integrator_unverified_lgs_raw_visibilities")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["deformable_mirror_actuators_k"], 16)
        self.assertEqual(gov["strehl_ratio_coronagraph_contrast_gain_pct"], 46.2)
        self.assertEqual(gov["clean_visibility_rfi_recovery_gain_pct"], 31.8)
        self.assertEqual(gov["lgs_faa_airspace_solar_shutter_gate_ms"], 0.6)
        self.assertEqual(gov["aircraft_lasing_or_focal_plane_burn_escape_pct"], 0.0)
        self.assertGreater(raw["aircraft_lasing_or_focal_plane_burn_escape_pct"], 1.3)
        self.assertEqual(gov["shack_hartmann_frb_dedispersion_edge_ms"], 0.8)
        self.assertEqual(gov["observatory_wan_bandwidth_reduction_pct"], 98.2)
        self.assertEqual(gov["segmented_mirror_piston_phase_error_pct"], 0.0)
        self.assertGreater(raw["segmented_mirror_piston_phase_error_pct"], 3.0)
        self.assertTrue(gov["observatory_ao_slo_met"])
        self.assertFalse(raw["observatory_ao_slo_met"])

    def test_subsea_cabled_observatory_tsunami_bop_sandbox(self) -> None:
        gov = simulate_subsea_cabled_observatory_tsunami_bop_sandbox(80, "bpr_tsunami_pinn_auv_acoustic_sil3_bop_edge")
        raw = simulate_subsea_cabled_observatory_tsunami_bop_sandbox(80, "static_threshold_unverified_bop_raw_hydrophone")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["cabled_science_junction_boxes"], 20)
        self.assertEqual(gov["tsunami_early_warning_lead_time_gain_pct"], 44.6)
        self.assertEqual(gov["auv_inductive_docking_energy_saving_pct"], 38.2)
        self.assertEqual(gov["api_rp53_sil3_bop_shear_ram_hvdc_gate_ms"], 1.2)
        self.assertEqual(gov["subsea_blowout_or_hvdc_ground_fault_escape_pct"], 0.0)
        self.assertGreater(raw["subsea_blowout_or_hvdc_ground_fault_escape_pct"], 1.7)
        self.assertEqual(gov["subsea_das_hydrophone_edge_triage_ms"], 6.5)
        self.assertEqual(gov["acoustic_satcom_bandwidth_reduction_pct"], 97.4)
        self.assertEqual(gov["acoustic_multipath_auv_lost_lock_pct"], 0.0)
        self.assertGreater(raw["acoustic_multipath_auv_lost_lock_pct"], 4.0)
        self.assertTrue(gov["subsea_observatory_slo_met"])
        self.assertFalse(raw["subsea_observatory_slo_met"])

    def test_geothermal_egs_induced_seismicity_turbine_sandbox(self) -> None:
        gov = simulate_geothermal_egs_induced_seismicity_turbine_sandbox(48, "egs_seismicity_tls_pinn_sco2_sil3_edge")
        raw = simulate_geothermal_egs_induced_seismicity_turbine_sandbox(48, "cloud_only_unthrottled_injection_telemetry")
        self.assertEqual(gov["gpu_nodes"], 4)
        self.assertEqual(gov["egs_multi_stage_stimulation_pads"], 16)
        self.assertEqual(gov["baseload_geothermal_mw_gain_pct"], 36.4)
        self.assertEqual(gov["parasitic_reinjection_pump_saving_pct"], 31.8)
        self.assertEqual(gov["tls_seismic_bleedoff_and_sil3_interlock_ms"], 2.1)
        self.assertEqual(gov["induced_seismicity_tls_exceedance_or_overpressure_pct"], 0.0)
        self.assertGreater(raw["induced_seismicity_tls_exceedance_or_overpressure_pct"], 1.8)
        self.assertEqual(gov["downhole_das_microseismic_edge_filter_ms"], 4.8)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 97.5)
        self.assertEqual(gov["fracture_thermal_short_circuit_breakthrough_pct"], 0.0)
        self.assertGreater(raw["fracture_thermal_short_circuit_breakthrough_pct"], 3.5)
        self.assertTrue(gov["geothermal_egs_slo_met"])
        self.assertFalse(raw["geothermal_egs_slo_met"])

    def test_smr_nuclear_neutronics_class1e_rts_sandbox(self) -> None:
        gov = simulate_smr_nuclear_neutronics_class1e_rts_sandbox(24, "smr_neutronics_pinn_xenon_damping_class1e_rts_edge")
        raw = simulate_smr_nuclear_neutronics_class1e_rts_sandbox(24, "cloud_only_unverified_rod_stepping_raw_spnd")
        self.assertEqual(gov["gpu_nodes"], 3)
        self.assertEqual(gov["smr_multi_module_power_plants"], 6)
        self.assertEqual(gov["smr_load_following_ramp_efficiency_gain_pct"], 34.2)
        self.assertEqual(gov["fuel_cycle_burnup_utilization_saving_pct"], 19.4)
        self.assertEqual(gov["class1e_rts_dnbr_interlock_latency_ms"], 1.2)
        self.assertEqual(gov["dnbr_or_reactivity_excursion_violation_rate_pct"], 0.0)
        self.assertGreater(raw["dnbr_or_reactivity_excursion_violation_rate_pct"], 1.4)
        self.assertEqual(gov["in_core_fission_chamber_edge_latency_ms"], 3.5)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 97.9)
        self.assertEqual(gov["xenon_oscillation_axial_offset_breach_pct"], 0.0)
        self.assertGreater(raw["xenon_oscillation_axial_offset_breach_pct"], 3.0)
        self.assertTrue(gov["smr_neutronics_slo_met"])
        self.assertFalse(raw["smr_neutronics_slo_met"])

    def test_tbm_tunnel_boring_geomechanics_sil3_sandbox(self) -> None:
        gov = simulate_tbm_tunnel_boring_geomechanics_sil3_sandbox(16, "tbm_gpr_fwi_epb_mpc_sil3_plc_edge")
        raw = simulate_tbm_tunnel_boring_geomechanics_sil3_sandbox(16, "cloud_only_unverified_epb_raw_gpr_telemetry")
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_tbm_shield_drives"], 4)
        self.assertEqual(gov["tbm_advance_rate_and_specific_energy_gain_pct"], 32.9)
        self.assertEqual(gov["disc_cutter_wear_life_extension_pct"], 24.6)
        self.assertEqual(gov["iso19296_sil3_cutterhead_torque_interlock_ms"], 1.7)
        self.assertEqual(gov["cutterhead_stall_or_surface_settlement_breach_pct"], 0.0)
        self.assertGreater(raw["cutterhead_stall_or_surface_settlement_breach_pct"], 1.7)
        self.assertEqual(gov["on_shield_gpr_acoustic_edge_inversion_ms"], 4.2)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 97.5)
        self.assertEqual(gov["tail_void_grout_or_face_blowout_excursion_pct"], 0.0)
        self.assertGreater(raw["tail_void_grout_or_face_blowout_excursion_pct"], 3.5)
        self.assertTrue(gov["tbm_geomechanics_slo_met"])
        self.assertFalse(raw["tbm_geomechanics_slo_met"])

    def test_petrochemical_fcc_refinery_sil3_esd_sandbox(self) -> None:
        gov = simulate_petrochemical_fcc_refinery_sil3_esd_sandbox(16, "fcc_regenerator_mpc_raman_sil3_esd_edge")
        raw = simulate_petrochemical_fcc_refinery_sil3_esd_sandbox(16, "unconstrained_pid_manual_sampling_cloud")
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_fcc_reactor_regenerator_units"], 4)
        self.assertEqual(gov["gasoline_light_olefin_yield_gain_pct"], 18.7)
        self.assertEqual(gov["regenerator_afterburn_flue_gas_reduction_pct"], 31.4)
        self.assertEqual(gov["sil3_slide_valve_catalyst_reversal_esd_ms"], 1.6)
        self.assertEqual(gov["catalyst_reversal_or_cyclone_overtemp_breach_pct"], 0.0)
        self.assertGreater(raw["catalyst_reversal_or_cyclone_overtemp_breach_pct"], 1.6)
        self.assertEqual(gov["edge_raman_octane_soft_sensor_inference_ms"], 3.8)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 97.6)
        self.assertEqual(gov["fractionator_flooding_or_wgc_surge_excursion_pct"], 0.0)
        self.assertGreater(raw["fractionator_flooding_or_wgc_surge_excursion_pct"], 3.4)
        self.assertTrue(gov["petrochemical_fcc_slo_met"])
        self.assertFalse(raw["petrochemical_fcc_slo_met"])

    def test_aerospace_composite_autoclave_ndt_sil3_sandbox(self) -> None:
        gov = simulate_aerospace_composite_autoclave_ndt_sil3_sandbox(16, "thermochemical_cure_mpc_paut_nadcap_sil3_edge")
        raw = simulate_aerospace_composite_autoclave_ndt_sil3_sandbox(16, "open_loop_dwell_recipe_unverified_paut_cloud")
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_autoclaves_and_afp_gantries"], 4)
        self.assertEqual(gov["cure_uniformity_and_porosity_reduction_gain_pct"], 23.4)
        self.assertEqual(gov["autoclave_n2_and_cure_energy_reduction_pct"], 26.8)
        self.assertEqual(gov["nadcap_sil3_exotherm_interlock_latency_ms"], 1.8)
        self.assertEqual(gov["exothermic_runaway_or_vacuum_breach_pct"], 0.0)
        self.assertGreater(raw["exothermic_runaway_or_vacuum_breach_pct"], 1.7)
        self.assertEqual(gov["edge_paut_thermography_inference_latency_ms"], 3.9)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 97.7)
        self.assertEqual(gov["afp_delamination_or_ndt_false_accept_pct"], 0.0)
        self.assertGreater(raw["afp_delamination_or_ndt_false_accept_pct"], 3.5)
        self.assertTrue(gov["aerospace_composite_slo_met"])
        self.assertFalse(raw["aerospace_composite_slo_met"])

    def test_lng_cryogenic_c3mr_bog_sil3_esd_sandbox(self) -> None:
        gov = simulate_lng_cryogenic_c3mr_bog_sil3_esd_sandbox(8, "c3mr_pinch_mpc_antisurge_nfpa59a_sil3_edge")
        raw = simulate_lng_cryogenic_c3mr_bog_sil3_esd_sandbox(8, "unconstrained_mr_valve_cloud_loop")
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_c3mr_trains_and_berths"], 4)
        self.assertEqual(gov["mche_pinch_liquefaction_yield_gain_pct"], 21.8)
        self.assertEqual(gov["specific_compressor_power_reduction_pct"], 24.2)
        self.assertEqual(gov["nfpa59a_sil3_antisurge_perc_esd_latency_ms"], 1.2)
        self.assertEqual(gov["compressor_surge_or_tank_rollover_breach_pct"], 0.0)
        self.assertGreater(raw["compressor_surge_or_tank_rollover_breach_pct"], 1.5)
        self.assertEqual(gov["edge_dts_ogi_cryogenic_leak_inference_ms"], 3.5)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 97.9)
        self.assertEqual(gov["cryogenic_cold_spot_or_ogi_false_clearance_pct"], 0.0)
        self.assertGreater(raw["cryogenic_cold_spot_or_ogi_false_clearance_pct"], 3.0)
        self.assertTrue(gov["lng_cryogenic_slo_met"])
        self.assertFalse(raw["lng_cryogenic_slo_met"])

    def test_hvdc_subsea_interconnector_mmc_dcr_sil3_dccb_sandbox(self) -> None:
        gov = simulate_hvdc_subsea_interconnector_mmc_dcr_sil3_dccb_sandbox(8, "mmc_gfm_dcr_cigre_sil3_dccb_edge")
        raw = simulate_hvdc_subsea_interconnector_mmc_dcr_sil3_dccb_sandbox(8, "static_cable_rating_unblocked_mmc_cloud_loop")
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_hvdc_subsea_corridors"], 4)
        self.assertEqual(gov["dcr_submarine_cable_ampacity_gain_pct"], 19.6)
        self.assertEqual(gov["mmc_igbt_switching_loss_reduction_pct"], 26.4)
        self.assertEqual(gov["sil3_dccb_anchor_strike_interlock_ms"], 1.1)
        self.assertEqual(gov["dc_pole_fault_xlpe_overtemp_breach_pct"], 0.0)
        self.assertGreater(raw["dc_pole_fault_xlpe_overtemp_breach_pct"], 1.4)
        self.assertEqual(gov["azure_local_das_sv_edge_latency_ms"], 3.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.3)
        self.assertEqual(gov["das_anchor_strike_false_clearance_pct"], 0.0)
        self.assertGreater(raw["das_anchor_strike_false_clearance_pct"], 2.8)
        self.assertTrue(gov["hvdc_subsea_interconnector_slo_met"])
        self.assertFalse(raw["hvdc_subsea_interconnector_slo_met"])

    def test_dac_carbon_sequestration_vtsa_sco2_class6_sil3_sandbox(self) -> None:
        gov = simulate_dac_carbon_sequestration_vtsa_sco2_class6_sil3_sandbox(16, "vtsa_mpc_sco2_class6_bhp_sil3_edge")
        raw = simulate_dac_carbon_sequestration_vtsa_sco2_class6_sil3_sandbox(16, "unmanaged_fixed_steam_unthrottled_bhp_cloud")
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_class6_injection_corridors"], 4)
        self.assertEqual(gov["vtsa_regeneration_steam_saving_pct"], 24.8)
        self.assertEqual(gov["net_co2_sequestration_yield_gain_pct"], 18.2)
        self.assertEqual(gov["sil3_wellhead_esdv_interlock_ms"], 5.4)
        self.assertEqual(gov["caprock_fracture_or_sco2_two_phase_breach_pct"], 0.0)
        self.assertGreater(raw["caprock_fracture_or_sco2_two_phase_breach_pct"], 1.5)
        self.assertEqual(gov["azure_local_downhole_das_edge_latency_ms"], 6.8)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.1)
        self.assertEqual(gov["microseismic_or_hydrate_false_clearance_pct"], 0.0)
        self.assertGreater(raw["microseismic_or_hydrate_false_clearance_pct"], 3.0)
        self.assertTrue(gov["dac_carbon_sequestration_slo_met"])
        self.assertFalse(raw["dac_carbon_sequestration_slo_met"])

    def test_bess_grid_storage_eis_thermal_ul9540a_sil3_sandbox(self) -> None:
        gov = simulate_bess_grid_storage_eis_thermal_ul9540a_sil3_sandbox(32, "eis_dqdv_mpc_ul9540a_nfpa855_sil3_edge")
        raw = simulate_bess_grid_storage_eis_thermal_ul9540a_sil3_sandbox(32, "cloud_bms_polling_naive")
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_pcs_inverter_bays"], 4)
        self.assertEqual(gov["round_trip_efficiency_and_life_gain_pct"], 16.4)
        self.assertEqual(gov["auxiliary_chiller_and_pump_energy_saving_pct"], 23.6)
        self.assertEqual(gov["ul9540a_nfpa855_sil3_contactor_interlock_ms"], 4.2)
        self.assertEqual(gov["thermal_runaway_propagation_or_lel_breach_pct"], 0.0)
        self.assertGreater(raw["thermal_runaway_propagation_or_lel_breach_pct"], 1.5)
        self.assertEqual(gov["substation_edge_eis_spectrum_inversion_ms"], 6.1)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.2)
        self.assertEqual(gov["cell_imbalance_or_soh_false_clearance_pct"], 0.0)
        self.assertGreater(raw["cell_imbalance_or_soh_false_clearance_pct"], 2.9)
        self.assertTrue(gov["bess_grid_storage_slo_met"])
        self.assertFalse(raw["bess_grid_storage_slo_met"])

    def test_additive_manufacturing_lpbf_meltpool_nfpa484_sil3_sandbox(self) -> None:
        gov = simulate_additive_manufacturing_lpbf_meltpool_nfpa484_sil3_sandbox(
            16, "marangoni_pinn_mpc_astm_f3303_nfpa484_sil3_edge"
        )
        raw = simulate_additive_manufacturing_lpbf_meltpool_nfpa484_sil3_sandbox(
            16, "open_loop_power_unverified_argon_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_multi_laser_print_cells"], 4)
        self.assertEqual(gov["keyhole_and_lack_of_fusion_porosity_reduction_pct"], 34.2)
        self.assertEqual(gov["multi_laser_build_rate_gain_pct"], 21.8)
        self.assertEqual(gov["astm_f3303_nfpa484_sil3_shutter_interlock_ms"], 0.9)
        self.assertEqual(gov["combustible_dust_ignition_or_recoater_crash_pct"], 0.0)
        self.assertGreater(raw["combustible_dust_ignition_or_recoater_crash_pct"], 1.4)
        self.assertEqual(gov["coaxial_pyrometry_oct_edge_latency_ms"], 1.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.4)
        self.assertEqual(gov["spatter_inclusion_or_delamination_false_clearance_pct"], 0.0)
        self.assertGreater(raw["spatter_inclusion_or_delamination_false_clearance_pct"], 2.5)
        self.assertTrue(gov["lpbf_additive_manufacturing_slo_met"])
        self.assertFalse(raw["lpbf_additive_manufacturing_slo_met"])

    def test_euv_lithography_scanner_lpp_overlay_semi_s2_sil3_sandbox(self) -> None:
        gov = simulate_euv_lithography_scanner_lpp_overlay_semi_s2_sil3_sandbox(
            12, "lpp_overlay_pinn_mpc_semi_s2_s22_sil3_edge"
        )
        raw = simulate_euv_lithography_scanner_lpp_overlay_semi_s2_sil3_sandbox(
            12, "open_loop_pid_cloud_scanner"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_euv_litho_bay_pods"], 3)
        self.assertEqual(gov["overlay_and_cd_error_reduction_pct"], 35.6)
        self.assertEqual(gov["wafer_throughput_wph_gain_pct"], 19.4)
        self.assertEqual(gov["semi_s2_s22_sil3_uhv_laser_interlock_ms"], 0.7)
        self.assertEqual(gov["uhv_hydrogen_excursion_or_stage_collision_pct"], 0.0)
        self.assertGreater(raw["uhv_hydrogen_excursion_or_stage_collision_pct"], 1.4)
        self.assertEqual(gov["droplet_l2d_tracking_edge_latency_ms"], 0.8)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.6)
        self.assertEqual(gov["stochastic_defect_or_dose_false_clearance_pct"], 0.0)
        self.assertGreater(raw["stochastic_defect_or_dose_false_clearance_pct"], 2.5)
        self.assertTrue(gov["euv_lithography_scanner_slo_met"])
        self.assertFalse(raw["euv_lithography_scanner_slo_met"])

    def test_saf_ptl_fischer_tropsch_rwgs_astm_d7566_sil3_sandbox(self) -> None:
        gov = simulate_saf_ptl_fischer_tropsch_rwgs_astm_d7566_sil3_sandbox(
            8, "rwgs_ft_asf_pinn_mpc_astm_d7566_sil3_edge"
        )
        raw = simulate_saf_ptl_fischer_tropsch_rwgs_astm_d7566_sil3_sandbox(
            8, "open_loop_pid_cloud_refinery"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_saf_ptl_refinery_pods"], 2)
        self.assertEqual(gov["c8_c16_jet_selectivity_gain_pct"], 21.8)
        self.assertEqual(gov["specific_syngas_energy_reduction_pct"], 18.4)
        self.assertEqual(gov["astm_d7566_sil3_depressuring_n2_purge_interlock_ms"], 2.2)
        self.assertEqual(gov["ft_thermal_runaway_or_syngas_autoignition_pct"], 0.0)
        self.assertGreater(raw["ft_thermal_runaway_or_syngas_autoignition_pct"], 1.5)
        self.assertEqual(gov["raman_gcms_dts_edge_latency_ms"], 1.6)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.4)
        self.assertEqual(gov["astm_d7566_freeze_point_or_aromatic_false_clearance_pct"], 0.0)
        self.assertGreater(raw["astm_d7566_freeze_point_or_aromatic_false_clearance_pct"], 2.5)
        self.assertTrue(gov["saf_ptl_fischer_tropsch_slo_met"])
        self.assertFalse(raw["saf_ptl_fischer_tropsch_slo_met"])

    def test_quantum_superconducting_qec_cryo_dilution_sil3_sandbox(self) -> None:
        gov = simulate_quantum_superconducting_qec_cryo_dilution_sil3_sandbox(
            8, "surface_code_neural_bp_pinn_drag_mpc_asme_sil3_edge"
        )
        raw = simulate_quantum_superconducting_qec_cryo_dilution_sil3_sandbox(
            8, "static_lookup_mwpm_cloud_cryostat"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_quantum_cryo_qec_pods"], 4)
        self.assertEqual(gov["logical_error_rate_per_round_reduction_pct"], 42.5)
        self.assertEqual(gov["two_qubit_gate_fidelity_coherence_gain_pct"], 29.4)
        self.assertEqual(gov["asme_bpvc_sil3_he3_he4_dump_interlock_ms"], 0.6)
        self.assertEqual(gov["cryostat_overpressure_or_he3_loss_quench_pct"], 0.0)
        self.assertGreater(raw["cryostat_overpressure_or_he3_loss_quench_pct"], 1.5)
        self.assertEqual(gov["rfsoc_fpga_syndrome_decoding_edge_latency_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.8)
        self.assertEqual(gov["cosmic_ray_quasiparticle_burst_or_leakage_false_clearance_pct"], 0.0)
        self.assertGreater(raw["cosmic_ray_quasiparticle_burst_or_leakage_false_clearance_pct"], 3.0)
        self.assertTrue(gov["quantum_superconducting_qec_slo_met"])
        self.assertFalse(raw["quantum_superconducting_qec_slo_met"])

    def test_leo_megaconstellation_oisl_conjunction_iso24113_sil3_sandbox(self) -> None:
        gov = simulate_leo_megaconstellation_oisl_conjunction_iso24113_sil3_sandbox(
            24, "j2j6_orbital_pinn_oisl_pat_mpc_iso24113_sil3_edge"
        )
        raw = simulate_leo_megaconstellation_oisl_conjunction_iso24113_sil3_sandbox(
            24, "static_tle_ground_schedule_cloud_loop"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_constellation_control_pods"], 4)
        self.assertEqual(gov["oisl_mesh_goodput_and_link_availability_gain_pct"], 31.6)
        self.assertEqual(gov["krypton_xenon_propellant_budget_saving_pct"], 27.8)
        self.assertEqual(gov["iso24113_sil3_conjunction_safemode_interlock_ms"], 1.1)
        self.assertEqual(gov["debris_conjunction_or_attitude_tumble_breach_pct"], 0.0)
        self.assertGreater(raw["debris_conjunction_or_attitude_tumble_breach_pct"], 1.4)
        self.assertEqual(gov["onboard_radhard_npu_pat_cdm_edge_latency_ms"], 0.9)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.7)
        self.assertEqual(gov["solar_storm_drag_or_oisl_drop_false_clearance_pct"], 0.0)
        self.assertGreater(raw["solar_storm_drag_or_oisl_drop_false_clearance_pct"], 2.9)
        self.assertTrue(gov["leo_megaconstellation_oisl_slo_met"])
        self.assertFalse(raw["leo_megaconstellation_oisl_slo_met"])

    def test_deepsea_mineral_collector_riser_isa_dnv_sil3_sandbox(self) -> None:
        gov = simulate_deepsea_mineral_collector_riser_isa_dnv_sil3_sandbox(
            6, "benthic_terramechanics_plume_pinn_riser_mpc_isa_dnv_sil3_edge"
        )
        raw = simulate_deepsea_mineral_collector_riser_isa_dnv_sil3_sandbox(
            6, "open_loop_crawler_unverified_riser_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_subsea_mining_pods"], 3)
        self.assertEqual(gov["nodule_pickup_efficiency_and_riser_throughput_gain_pct"], 24.6)
        self.assertEqual(gov["benthic_sediment_plume_dispersion_reduction_pct"], 38.2)
        self.assertEqual(gov["isa_dnv_sil3_riser_dump_umbilical_interlock_ms"], 2.4)
        self.assertEqual(gov["vertical_riser_plugging_or_crawler_liquefaction_sinkage_pct"], 0.0)
        self.assertGreater(raw["vertical_riser_plugging_or_crawler_liquefaction_sinkage_pct"], 1.5)
        self.assertEqual(gov["subsea_sonar_adcp_edge_inference_latency_ms"], 2.1)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.5)
        self.assertEqual(gov["isa_turbidity_threshold_or_dp3_umbilical_snap_false_clearance_pct"], 0.0)
        self.assertGreater(raw["isa_turbidity_threshold_or_dp3_umbilical_snap_false_clearance_pct"], 3.0)
        self.assertTrue(gov["deepsea_mineral_collector_slo_met"])
        self.assertFalse(raw["deepsea_mineral_collector_slo_met"])

    def test_biomanufacturing_perfusion_bioreactor_pat_gmp_sil3_sandbox(self) -> None:
        gov = simulate_biomanufacturing_perfusion_bioreactor_pat_gmp_sil3_sandbox(
            8, "metabolic_fba_glycosylation_pinn_tff_mpc_gmp_sil3_edge"
        )
        raw = simulate_biomanufacturing_perfusion_bioreactor_pat_gmp_sil3_sandbox(
            8, "offline_hplc_pid_unverified_sip_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_bioprocess_suite_pods"], 4)
        self.assertEqual(gov["volumetric_titer_yield_and_cqa_consistency_gain_pct"], 28.4)
        self.assertEqual(gov["tff_membrane_fouling_and_lactate_inhibition_reduction_pct"], 34.6)
        self.assertEqual(gov["gmp_bpe_sil3_sip_viral_inactivation_interlock_ms"], 1.9)
        self.assertEqual(gov["sterile_boundary_contamination_or_viral_hold_breach_pct"], 0.0)
        self.assertGreater(raw["sterile_boundary_contamination_or_viral_hold_breach_pct"], 1.4)
        self.assertEqual(gov["cleanroom_raman_capacitance_edge_latency_ms"], 1.7)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.6)
        self.assertEqual(gov["lactate_acidosis_crash_or_tff_shear_lysis_false_clearance_pct"], 0.0)
        self.assertGreater(raw["lactate_acidosis_crash_or_tff_shear_lysis_false_clearance_pct"], 2.9)
        self.assertTrue(gov["biomanufacturing_perfusion_slo_met"])
        self.assertFalse(raw["biomanufacturing_perfusion_slo_met"])

    def test_hypersonic_cmc_cvi_arcjet_tps_nfpa86_sil3_sandbox(self) -> None:
        gov = simulate_hypersonic_cmc_cvi_arcjet_tps_nfpa86_sil3_sandbox(
            6, "knudsen_cvi_ablation_pinn_mpc_nasa5001_nfpa86_sil3_edge"
        )
        raw = simulate_hypersonic_cmc_cvi_arcjet_tps_nfpa86_sil3_sandbox(
            6, "isothermal_open_loop_unverified_arcjet_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_hypersonic_tps_pods"], 3)
        self.assertEqual(gov["cmc_densification_and_ilss_strength_gain_pct"], 26.8)
        self.assertEqual(gov["surface_pore_crusting_and_void_porosity_reduction_pct"], 36.4)
        self.assertEqual(gov["nasa5001_nfpa86_sil3_mts_purge_anode_interlock_ms"], 1.3)
        self.assertEqual(gov["mts_h2_deflagration_or_copper_anode_burnout_breach_pct"], 0.0)
        self.assertGreater(raw["mts_h2_deflagration_or_copper_anode_burnout_breach_pct"], 1.5)
        self.assertEqual(gov["testcell_pyrometry_plif_edge_latency_ms"], 1.2)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.7)
        self.assertEqual(gov["pore_seal_delamination_or_stagnation_burnthrough_false_clearance_pct"], 0.0)
        self.assertGreater(raw["pore_seal_delamination_or_stagnation_burnthrough_false_clearance_pct"], 3.0)
        self.assertTrue(gov["hypersonic_cmc_cvi_arcjet_slo_met"])
        self.assertFalse(raw["hypersonic_cmc_cvi_arcjet_slo_met"])

    def test_subsea_cable_lay_plough_otdr_das_dnv_sil3_sandbox(self) -> None:
        gov = simulate_subsea_cable_lay_plough_otdr_das_dnv_sil3_sandbox(
            4, "catenary_tdp_plough_soil_pinn_cotdr_das_mpc_dnv_sil3_edge"
        )
        raw = simulate_subsea_cable_lay_plough_otdr_das_dnv_sil3_sandbox(
            4, "static_catenary_table_unverified_plough_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_cable_lay_pods"], 4)
        self.assertEqual(gov["burial_depth_compliance_and_lay_speed_gain_pct"], 26.4)
        self.assertEqual(gov["residual_bottom_tension_variance_and_microbend_attenuation_reduction_pct"], 38.2)
        self.assertEqual(gov["dnv_st_f101_imca_dp3_sil3_chute_mbr_tow_interlock_ms"], 1.6)
        self.assertEqual(gov["cable_mbr_buckling_or_armour_birdcaging_breach_pct"], 0.0)
        self.assertGreater(raw["cable_mbr_buckling_or_armour_birdcaging_breach_pct"], 1.4)
        self.assertEqual(gov["vessel_cotdr_das_usbl_edge_latency_ms"], 1.5)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.8)
        self.assertEqual(gov["plough_hanger_snag_or_tdp_loop_throw_false_clearance_pct"], 0.0)
        self.assertGreater(raw["plough_hanger_snag_or_tdp_loop_throw_false_clearance_pct"], 3.0)
        self.assertTrue(gov["subsea_cable_lay_plough_slo_met"])
        self.assertFalse(raw["subsea_cable_lay_plough_slo_met"])

    def test_psh_pumped_hydro_waterhammer_vortex_iec60308_sil3_sandbox(self) -> None:
        gov = simulate_psh_pumped_hydro_waterhammer_vortex_iec60308_sil3_sandbox(
            8, "allievi_waterhammer_sregion_pinn_dfim_mpc_iec60308_sil3_edge"
        )
        raw = simulate_psh_pumped_hydro_waterhammer_vortex_iec60308_sil3_sandbox(
            8, "fixed_linear_servo_unverified_wicket_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_psh_powerhouse_pods"], 4)
        self.assertEqual(gov["pump_to_turbine_transition_speed_and_rte_gain_pct"], 29.2)
        self.assertEqual(gov["sregion_pressure_pulsation_and_waterhammer_peak_reduction_pct"], 37.6)
        self.assertEqual(gov["ieee1020_iec60308_sil3_wicket_cushion_interlock_ms"], 1.4)
        self.assertEqual(gov["penstock_overpressure_or_draft_tube_column_separation_breach_pct"], 0.0)
        self.assertGreater(raw["penstock_overpressure_or_draft_tube_column_separation_breach_pct"], 1.3)
        self.assertEqual(gov["powerhouse_piezo_shaft_orbit_edge_latency_ms"], 1.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.6)
        self.assertEqual(gov["sregion_grid_sync_failure_or_runner_cavitation_false_clearance_pct"], 0.0)
        self.assertGreater(raw["sregion_grid_sync_failure_or_runner_cavitation_false_clearance_pct"], 2.9)
        self.assertTrue(gov["psh_pumped_hydro_waterhammer_slo_met"])
        self.assertFalse(raw["psh_pumped_hydro_waterhammer_slo_met"])

    def test_fpso_turret_mooring_riser_slugging_apirp14c_sil3_sandbox(self) -> None:
        gov = simulate_fpso_turret_mooring_riser_slugging_apirp14c_sil3_sandbox(
            6, "riser_slugging_turret_weathervane_pinn_antisurge_mpc_apirp14c_sil3_edge"
        )
        raw = simulate_fpso_turret_mooring_riser_slugging_apirp14c_sil3_sandbox(
            6, "manual_choke_unverified_antisurge_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_fpso_topside_subsea_pods"], 3)
        self.assertEqual(gov["separation_throughput_and_compressor_margin_gain_pct"], 25.6)
        self.assertEqual(gov["riser_slug_pressure_and_separator_surge_reduction_pct"], 39.1)
        self.assertEqual(gov["apirp14c_dnv_sil3_hipps_eqd_interlock_ms"], 1.2)
        self.assertEqual(gov["separator_carryover_or_mooring_line_breach_pct"], 0.0)
        self.assertGreater(raw["separator_carryover_or_mooring_line_breach_pct"], 1.2)
        self.assertEqual(gov["topside_mpfm_das_edge_latency_ms"], 1.1)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.9)
        self.assertEqual(gov["severe_slug_blowout_or_compressor_surge_false_clearance_pct"], 0.0)
        self.assertGreater(raw["severe_slug_blowout_or_compressor_surge_false_clearance_pct"], 2.8)
        self.assertTrue(gov["fpso_turret_mooring_riser_slugging_slo_met"])
        self.assertFalse(raw["fpso_turret_mooring_riser_slugging_slo_met"])

    def test_sic_pvt_boule_crystal_growth_htcvd_semis2_sil3_sandbox(self) -> None:
        gov = simulate_sic_pvt_boule_crystal_growth_htcvd_semis2_sil3_sandbox(
            16, "radiative_sublimation_bpd_pinn_coil_crucible_mpc_semis2_sil3_edge"
        )
        raw = simulate_sic_pvt_boule_crystal_growth_htcvd_semis2_sil3_sandbox(
            16, "blind_recipe_pyrometer_unverified_coil_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_sic_crystal_pods"], 8)
        self.assertEqual(gov["single_polytype_4h_boule_yield_and_usable_wafers_gain_pct"], 28.7)
        self.assertEqual(gov["bpd_dislocation_and_radial_thermal_stress_reduction_pct"], 41.2)
        self.assertEqual(gov["semis2_nfpa86_sil3_coil_leak_silane_interlock_ms"], 1.3)
        self.assertEqual(gov["coil_water_leak_steam_explosion_or_silane_breach_pct"], 0.0)
        self.assertGreater(raw["coil_water_leak_steam_explosion_or_silane_breach_pct"], 1.3)
        self.assertEqual(gov["cleanroom_xray_pyrometry_edge_latency_ms"], 1.2)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.7)
        self.assertEqual(gov["polytype_6h_inclusion_or_micropipe_false_clearance_pct"], 0.0)
        self.assertGreater(raw["polytype_6h_inclusion_or_micropipe_false_clearance_pct"], 3.1)
        self.assertTrue(gov["sic_pvt_boule_crystal_growth_slo_met"])
        self.assertFalse(raw["sic_pvt_boule_crystal_growth_slo_met"])

    def test_polar_icebreaker_ice_routing_azimuth_thruster_imopolar_sil3_sandbox(self) -> None:
        gov = simulate_polar_icebreaker_ice_routing_azimuth_thruster_imopolar_sil3_sandbox(
            16, "sar_fbg_ice_ridge_pinn_azipod_milling_mpc_imopolar_sil3_edge"
        )
        raw = simulate_polar_icebreaker_ice_routing_azimuth_thruster_imopolar_sil3_sandbox(
            16, "daily_ice_chart_manual_helm_unverified_azipod_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_polar_icebreaker_pods"], 8)
        self.assertEqual(gov["ice_transit_vmg_and_ramming_fuel_efficiency_gain_pct"], 26.8)
        self.assertEqual(gov["hull_frame_strain_and_azipod_milling_torque_reduction_pct"], 43.4)
        self.assertEqual(gov["imopolar_iacs_sil3_hull_besetting_interlock_ms"], 1.3)
        self.assertEqual(gov["hull_plastic_buckling_or_azipod_shaft_shear_breach_pct"], 0.0)
        self.assertGreater(raw["hull_plastic_buckling_or_azipod_shaft_shear_breach_pct"], 1.4)
        self.assertEqual(gov["bridge_iceradar_fbg_edge_latency_ms"], 1.1)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 98.9)
        self.assertEqual(gov["multiyear_pressure_ridge_or_bergy_bit_false_clearance_pct"], 0.0)
        self.assertGreater(raw["multiyear_pressure_ridge_or_bergy_bit_false_clearance_pct"], 3.2)
        self.assertTrue(gov["polar_icebreaker_ice_routing_slo_met"])
        self.assertFalse(raw["polar_icebreaker_ice_routing_slo_met"])

    def test_gravitational_wave_interferometer_fabry_perot_newtonian_sil3_sandbox(self) -> None:
        gov = simulate_gravitational_wave_interferometer_fabry_perot_newtonian_sil3_sandbox(
            8, "deep_rl_hierarchical_lock_newtonian_pinn_squeezed_sil3_edge"
        )
        raw = simulate_gravitational_wave_interferometer_fabry_perot_newtonian_sil3_sandbox(
            8, "linear_pid_lock_acquisition_static_seismic_filter_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_gw_interferometer_pods"], 4)
        self.assertEqual(gov["observation_duty_cycle_and_bns_inspiral_range_gain_pct"], 27.4)
        self.assertEqual(gov["sub10hz_darm_strain_noise_and_lockloss_reduction_pct"], 44.2)
        self.assertEqual(gov["iec61508_sil3_ansi_z136_laser_quad_suspension_interlock_ms"], 0.8)
        self.assertEqual(gov["intracavity_mirror_thermal_or_suspension_stop_breach_pct"], 0.0)
        self.assertGreater(raw["intracavity_mirror_thermal_or_suspension_stop_breach_pct"], 1.2)
        self.assertEqual(gov["cds_dolphin_rfm_epics_edge_latency_ms"], 0.7)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.1)
        self.assertEqual(gov["teleseismic_lockloss_or_false_gcn_alert_clearance_pct"], 0.0)
        self.assertGreater(raw["teleseismic_lockloss_or_false_gcn_alert_clearance_pct"], 3.0)
        self.assertTrue(gov["gw_interferometer_fabry_perot_slo_met"])
        self.assertFalse(raw["gw_interferometer_fabry_perot_slo_met"])

    def test_stratospheric_hale_solar_haps_aeroelastic_dala_sandbox(self) -> None:
        gov = simulate_stratospheric_hale_solar_haps_aeroelastic_dala_sandbox(
            18, "pinn_mpc_aeroelastic_gla_lis_energy_stanag4671_dala_edge"
        )
        raw = simulate_stratospheric_hale_solar_haps_aeroelastic_dala_sandbox(
            18, "rigid_body_autopilot_fixed_waypoint_cloud_satcom"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_hale_haps_flight_pods"], 12)
        self.assertEqual(gov["winter_solstice_endurance_and_stationkeeping_gain_pct"], 26.2)
        self.assertEqual(gov["wing_root_bending_moment_and_torsion_reduction_pct"], 39.8)
        self.assertEqual(gov["stanag4671_dala_flutter_envelope_interlock_ms"], 1.0)
        self.assertEqual(gov["aeroelastic_flutter_or_structural_overload_breach_pct"], 0.0)
        self.assertGreater(raw["aeroelastic_flutter_or_structural_overload_breach_pct"], 1.2)
        self.assertEqual(gov["onboard_fbg_strain_arinc825_edge_latency_ms"], 0.9)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.0)
        self.assertEqual(gov["nighttime_lis_battery_undervoltage_descent_breach_pct"], 0.0)
        self.assertGreater(raw["nighttime_lis_battery_undervoltage_descent_breach_pct"], 3.0)
        self.assertTrue(gov["stratospheric_hale_solar_haps_slo_met"])
        self.assertFalse(raw["stratospheric_hale_solar_haps_slo_met"])

    def test_gen4_liquid_metal_sfr_lbe_swr_class1e_sil3_sandbox(self) -> None:
        gov = simulate_gen4_liquid_metal_sfr_lbe_swr_class1e_sil3_sandbox(
            12, "pinn_mpc_pool_thermal_striping_emp_swr_class1e_sil3_edge"
        )
        raw = simulate_gen4_liquid_metal_sfr_lbe_swr_class1e_sil3_sandbox(
            12, "manual_cold_trap_delayed_hydrogen_meter_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_sfr_lbe_reactor_pods"], 6)
        self.assertEqual(gov["breeding_burnup_and_thermal_cycle_efficiency_gain_pct"], 25.8)
        self.assertEqual(gov["upper_plenum_thermal_striping_creep_fatigue_reduction_pct"], 42.6)
        self.assertEqual(gov["asme_div5_ieee603_class1e_swr_dump_interlock_ms"], 0.9)
        self.assertEqual(gov["sodium_water_reaction_or_cladding_eutectic_breach_pct"], 0.0)
        self.assertGreater(raw["sodium_water_reaction_or_cladding_eutectic_breach_pct"], 1.2)
        self.assertEqual(gov["under_sodium_ultrasonic_acoustic_edge_latency_ms"], 0.8)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.0)
        self.assertEqual(gov["plugging_meter_oxide_fouling_or_cover_gas_fission_escape_pct"], 0.0)
        self.assertGreater(raw["plugging_meter_oxide_fouling_or_cover_gas_fission_escape_pct"], 3.0)
        self.assertTrue(gov["gen4_liquid_metal_sfr_lbe_slo_met"])
        self.assertFalse(raw["gen4_liquid_metal_sfr_lbe_slo_met"])

    def test_subsalt_mpd_drilling_lwd_kick_apirp53_sil3_sandbox(self) -> None:
        gov = simulate_subsalt_mpd_drilling_lwd_kick_apirp53_sil3_sandbox(
            8, "pinn_mpc_ecd_wdp_coriolis_kick_apirp53_sil3_edge"
        )
        raw = simulate_subsalt_mpd_drilling_lwd_kick_apirp53_sil3_sandbox(
            8, "manual_mud_weight_pit_gain_delayed_choke_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_mpd_drilling_pods"], 8)
        self.assertEqual(gov["rop_and_productive_drilling_time_gain_pct"], 29.4)
        self.assertEqual(gov["npt_kick_lost_circulation_and_stick_slip_reduction_pct"], 46.2)
        self.assertEqual(gov["apirp53_iec61511_sil3_mpd_choke_bop_interlock_ms"], 1.0)
        self.assertEqual(gov["pore_fracture_window_or_wellbore_blowout_breach_pct"], 0.0)
        self.assertGreater(raw["pore_fracture_window_or_wellbore_blowout_breach_pct"], 1.2)
        self.assertEqual(gov["wdp_intelliserv_coriolis_witsml_edge_latency_ms"], 0.9)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.1)
        self.assertEqual(gov["uncontrolled_gas_influx_or_lost_return_fracture_pct"], 0.0)
        self.assertGreater(raw["uncontrolled_gas_influx_or_lost_return_fracture_pct"], 3.0)
        self.assertTrue(gov["subsalt_mpd_drilling_slo_met"])
        self.assertFalse(raw["subsalt_mpd_drilling_slo_met"])

    def test_hts_rebco_superconducting_cable_sfcl_quench_sil3_sandbox(self) -> None:
        gov = simulate_hts_rebco_superconducting_cable_sfcl_quench_sil3_sandbox(
            12, "pinn_mpc_ej_nzpv_quench_subcooled_ln2_sil3_edge"
        )
        raw = simulate_hts_rebco_superconducting_cable_sfcl_quench_sil3_sandbox(
            12, "static_ln2_pump_threshold_voltage_trip_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_hts_rebco_grid_pods"], 6)
        self.assertEqual(gov["critical_current_ampacity_and_sfcl_recovery_gain_pct"], 31.2)
        self.assertEqual(gov["ac_hysteresis_loss_and_reverse_brayton_cryocooler_power_reduction_pct"], 38.6)
        self.assertEqual(gov["ieee_c37_302_iec61508_sil3_fast_bypass_relief_interlock_ms"], 0.7)
        self.assertEqual(gov["rebco_tape_delamination_or_ln2_boiling_flashover_breach_pct"], 0.0)
        self.assertGreater(raw["rebco_tape_delamination_or_ln2_boiling_flashover_breach_pct"], 1.2)
        self.assertEqual(gov["substation_bofda_voltage_tap_iec61850_edge_latency_ms"], 0.6)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.1)
        self.assertEqual(gov["unmasked_normal_zone_hot_spot_or_cryostat_vacuum_loss_pct"], 0.0)
        self.assertGreater(raw["unmasked_normal_zone_hot_spot_or_cryostat_vacuum_loss_pct"], 3.0)
        self.assertTrue(gov["hts_rebco_superconducting_cable_sfcl_slo_met"])
        self.assertFalse(raw["hts_rebco_superconducting_cable_sfcl_slo_met"])

    def test_cryogenic_lh2_lch4_launch_pad_chilldown_geyser_sil3_sandbox(self) -> None:
        gov = simulate_cryogenic_lh2_lch4_launch_pad_chilldown_geyser_sil3_sandbox(
            8, "pinn_mpc_leidenfrost_geyser_zbo_densifier_nfpa2_sil3_edge"
        )
        raw = simulate_cryogenic_lh2_lch4_launch_pad_chilldown_geyser_sil3_sandbox(
            8, "open_loop_continuous_chilldown_flare_vent_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_cryo_launch_pad_pods"], 8)
        self.assertEqual(gov["subcooled_propellant_mass_fraction_and_zbo_recovery_gain_pct"], 28.9)
        self.assertEqual(gov["chilldown_lh2_boiloff_loss_and_geyser_waterhammer_reduction_pct"], 44.6)
        self.assertEqual(gov["nasa_std_5005_nfpa2_sil3_qd_deluge_detank_interlock_ms"], 0.8)
        self.assertEqual(gov["umbilical_h2_leak_detonation_or_tank_implosion_breach_pct"], 0.0)
        self.assertGreater(raw["umbilical_h2_leak_detonation_or_tank_implosion_breach_pct"], 1.3)
        self.assertEqual(gov["pad_bunker_raman_lidar_cernox_tte_edge_latency_ms"], 0.7)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.1)
        self.assertEqual(gov["undetected_geyser_void_collapse_or_ullage_stratification_pct"], 0.0)
        self.assertGreater(raw["undetected_geyser_void_collapse_or_ullage_stratification_pct"], 3.0)
        self.assertTrue(gov["cryogenic_launch_pad_propellant_slo_met"])
        self.assertFalse(raw["cryogenic_launch_pad_propellant_slo_met"])

    def test_airborne_wind_energy_crosswind_kite_tether_sil3_sandbox(self) -> None:
        gov = simulate_airborne_wind_energy_crosswind_kite_tether_sil3_sandbox(
            32, "pinn_mpc_crosswind_figure8_catenary_pumping_iec61400_sil3_edge"
        )
        raw = simulate_airborne_wind_energy_crosswind_kite_tether_sil3_sandbox(
            32, "fixed_azimuth_pid_open_loop_reel_out_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_awe_kite_pods"], 8)
        self.assertEqual(gov["net_pumping_cycle_capacity_factor_gain_pct"], 34.5)
        self.assertEqual(gov["tether_snap_load_fatigue_and_retraction_parasitic_loss_reduction_pct"], 41.8)
        self.assertEqual(gov["iec61400_30_easa_sc_awes_sil3_winch_adsb_interlock_ms"], 0.6)
        self.assertEqual(gov["uhmwpe_tether_rupture_or_ground_stall_impact_breach_pct"], 0.0)
        self.assertGreater(raw["uhmwpe_tether_rupture_or_ground_stall_impact_breach_pct"], 1.2)
        self.assertEqual(gov["ground_station_doppler_lidar_fbg_tether_edge_latency_ms"], 0.5)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.2)
        self.assertEqual(gov["uncompensated_wind_shear_stall_or_multi_kite_tether_entanglement_pct"], 0.0)
        self.assertGreater(raw["uncompensated_wind_shear_stall_or_multi_kite_tether_entanglement_pct"], 3.0)
        self.assertTrue(gov["airborne_wind_energy_kite_slo_met"])
        self.assertFalse(raw["airborne_wind_energy_kite_slo_met"])

    def test_maglev_eds_ems_lsm_levitation_airgap_en50129_sil4_sandbox(self) -> None:
        gov = simulate_maglev_eds_ems_lsm_levitation_airgap_en50129_sil4_sandbox(
            24, "pinn_mpc_airgap_girder_lsm_handover_en50129_sil4_edge"
        )
        raw = simulate_maglev_eds_ems_lsm_levitation_airgap_en50129_sil4_sandbox(
            24, "decoupled_pid_airgap_hard_thyristor_block_switch_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_maglev_lsm_pods"], 8)
        self.assertEqual(gov["airgap_margin_and_ride_comfort_sperling_gain_pct"], 32.4)
        self.assertEqual(gov["lsm_stator_handover_thrust_ripple_and_reactive_power_reduction_pct"], 39.2)
        self.assertEqual(gov["en50128_en50129_sil4_eddy_current_brake_skid_interlock_ms"], 0.4)
        self.assertEqual(gov["guideway_stator_pole_strike_or_levitation_collapse_breach_pct"], 0.0)
        self.assertGreater(raw["guideway_stator_pole_strike_or_levitation_collapse_breach_pct"], 1.2)
        self.assertEqual(gov["wayside_38ghz_mmwave_eddy_gap_tsn_edge_latency_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_girder_resonance_or_lsm_phase_desync_pct"], 0.0)
        self.assertGreater(raw["uncompensated_girder_resonance_or_lsm_phase_desync_pct"], 3.0)
        self.assertTrue(gov["maglev_lsm_levitation_slo_met"])
        self.assertFalse(raw["maglev_lsm_levitation_slo_met"])

    def test_ptes_carnot_battery_brayton_turbocompressor_sil3_sandbox(self) -> None:
        gov = simulate_ptes_carnot_battery_brayton_turbocompressor_sil3_sandbox(
            20, "pinn_mpc_brayton_thermocline_antisurge_asme_sil3_edge"
        )
        raw = simulate_ptes_carnot_battery_brayton_turbocompressor_sil3_sandbox(
            20, "static_igv_schedule_delayed_recycle_valve_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_ptes_carnot_pods"], 8)
        self.assertEqual(gov["round_trip_exergy_efficiency_gain_pct"], 31.8)
        self.assertEqual(gov["thermocline_degradation_and_surge_recycle_loss_reduction_pct"], 42.5)
        self.assertEqual(gov["asme_api670_sil3_antisurge_and_overspeed_interlock_ms"], 0.5)
        self.assertEqual(gov["compressor_surge_reversal_or_tank_creep_breach_pct"], 0.0)
        self.assertGreater(raw["compressor_surge_reversal_or_tank_creep_breach_pct"], 1.2)
        self.assertEqual(gov["turbomachinery_dynamic_pressure_dts_magnetic_bearing_edge_latency_ms"], 0.5)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.2)
        self.assertEqual(gov["uncompensated_thermocline_breakthrough_or_shaft_rub_pct"], 0.0)
        self.assertGreater(raw["uncompensated_thermocline_breakthrough_or_shaft_rub_pct"], 3.0)
        self.assertTrue(gov["ptes_carnot_battery_slo_met"])
        self.assertFalse(raw["ptes_carnot_battery_slo_met"])

    def test_vleo_abep_atmosphere_breathing_ion_thruster_sil3_sandbox(self) -> None:
        gov = simulate_vleo_abep_atmosphere_breathing_ion_thruster_sil3_sandbox(
            24, "pinn_mpc_dsmc_intake_helicon_thruster_ecss_sil3_edge"
        )
        raw = simulate_vleo_abep_atmosphere_breathing_ion_thruster_sil3_sandbox(
            24, "open_loop_nrlmsise00_lookup_table_fixed_rf_power"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_vleo_abep_pods"], 8)
        self.assertEqual(gov["thrust_to_drag_margin_and_isp_efficiency_gain_pct"], 35.2)
        self.assertEqual(gov["orbital_altitude_dip_and_xenon_supplement_burn_reduction_pct"], 46.4)
        self.assertEqual(gov["ecss_st10c_nasa8719_sil3_feathering_and_cathode_quench_interlock_ms"], 0.4)
        self.assertEqual(gov["uncontrolled_perigee_reentry_or_grid_erosion_short_breach_pct"], 0.0)
        self.assertGreater(raw["uncontrolled_perigee_reentry_or_grid_erosion_short_breach_pct"], 1.2)
        self.assertEqual(gov["onboard_rpa_ionization_gauge_startracker_orbital_edge_latency_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_geomagnetic_storm_density_spike_or_plume_backflow_pct"], 0.0)
        self.assertGreater(raw["uncompensated_geomagnetic_storm_density_spike_or_plume_backflow_pct"], 3.0)
        self.assertTrue(gov["vleo_abep_propulsion_slo_met"])
        self.assertFalse(raw["vleo_abep_propulsion_slo_met"])

    def test_offshore_ccus_co2_pipeline_caprock_sequestration_sil3_sandbox(self) -> None:
        gov = simulate_offshore_ccus_co2_pipeline_caprock_sequestration_sil3_sandbox(
            18, "pinn_mpc_span_wagner_co2_fracture_arrest_biot_caprock_iso27914_sil3_edge"
        )
        raw = simulate_offshore_ccus_co2_pipeline_caprock_sequestration_sil3_sandbox(
            18, "steady_state_darcy_flow_fixed_wellhead_choke_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_ccus_sequestration_pods"], 8)
        self.assertEqual(gov["co2_storage_capacity_and_mineral_trapping_efficiency_gain_pct"], 33.6)
        self.assertEqual(gov["joule_thomson_hydrate_freeze_and_compression_loss_reduction_pct"], 44.2)
        self.assertEqual(gov["iso27913_iso27914_dnv_sil3_ssiv_and_lot_relief_interlock_ms"], 0.5)
        self.assertEqual(gov["running_ductile_pipeline_fracture_or_caprock_fault_breach_pct"], 0.0)
        self.assertGreater(raw["running_ductile_pipeline_fracture_or_caprock_fault_breach_pct"], 1.2)
        self.assertEqual(gov["subsea_4d_das_dts_downhole_quartz_gauge_edge_latency_ms"], 0.5)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_jt_dry_ice_plug_or_induced_microseismic_slip_pct"], 0.0)
        self.assertGreater(raw["uncompensated_jt_dry_ice_plug_or_induced_microseismic_slip_pct"], 3.0)
        self.assertTrue(gov["offshore_ccus_sequestration_slo_met"])
        self.assertFalse(raw["offshore_ccus_sequestration_slo_met"])

    def test_fsw_friction_stir_welding_cryo_tank_paut_awsd17_sil3_sandbox(self) -> None:
        gov = simulate_fsw_friction_stir_welding_cryo_tank_paut_awsd17_sil3_sandbox(
            16, "pinn_mpc_sheppard_wright_fsw_viscoplastic_paut_awsd17_sil3_edge"
        )
        raw = simulate_fsw_friction_stir_welding_cryo_tank_paut_awsd17_sil3_sandbox(
            16, "constant_rpm_plunge_depth_pid_postweld_xray_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_fsw_cryotank_pods"], 8)
        self.assertEqual(gov["weld_uts_cryo_fracture_toughness_and_speed_gain_pct"], 32.8)
        self.assertEqual(gov["wormhole_void_kissbond_and_tool_wear_scrap_reduction_pct"], 45.6)
        self.assertEqual(gov["awsd17_3_nasa5009_iso25239_sil3_pin_shear_retract_interlock_ms"], 0.4)
        self.assertEqual(gov["stir_pin_fracture_in_tank_or_burnthrough_breach_pct"], 0.0)
        self.assertGreater(raw["stir_pin_fracture_in_tank_or_burnthrough_breach_pct"], 1.2)
        self.assertEqual(gov["spindle_piezo_dynamometer_roller_paut_ethercat_edge_latency_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_kissing_bond_oxide_or_solidus_hot_cracking_pct"], 0.0)
        self.assertGreater(raw["uncompensated_kissing_bond_oxide_or_solidus_hot_cracking_pct"], 3.0)
        self.assertTrue(gov["fsw_cryotank_welding_slo_met"])
        self.assertFalse(raw["fsw_cryotank_welding_slo_met"])

    def test_perovskite_silicon_tandem_pv_slot_die_laser_scribing_sil3_sandbox(self) -> None:
        gov = simulate_perovskite_silicon_tandem_pv_slot_die_laser_scribing_sil3_sandbox(
            16, "pinn_mpc_landau_levich_perovskite_meniscus_femtosecond_p2_iec61215_sil3_edge"
        )
        raw = simulate_perovskite_silicon_tandem_pv_slot_die_laser_scribing_sil3_sandbox(
            16, "open_loop_fixed_web_speed_empirical_oven_cloud_polling"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_pv_tandem_pods"], 8)
        self.assertEqual(gov["tandem_cell_pce_yield_and_web_throughput_gain_pct"], 33.2)
        self.assertEqual(gov["pinhole_shunt_and_p2_tco_damage_scrap_reduction_pct"], 45.4)
        self.assertEqual(gov["iec61215_sil3_laser_and_pb_solvent_interlock_latency_ms"], 0.4)
        self.assertEqual(gov["unmitigated_p2_subcell_shunt_or_solvent_lel_breach_pct"], 0.0)
        self.assertGreater(raw["unmitigated_p2_subcell_shunt_or_solvent_lel_breach_pct"], 1.2)
        self.assertEqual(gov["line_edge_hyperspectral_pl_and_oct_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["unmitigated_perovskite_yellow_phase_or_delamination_pct"], 0.0)
        self.assertGreater(raw["unmitigated_perovskite_yellow_phase_or_delamination_pct"], 3.0)
        self.assertTrue(gov["perovskite_tandem_pv_slo_met"])
        self.assertFalse(raw["perovskite_tandem_pv_slo_met"])

    def test_solid_state_sulfide_battery_dry_electrode_isobaric_h2s_sil3_sandbox(self) -> None:
        gov = simulate_solid_state_sulfide_battery_dry_electrode_isobaric_h2s_sil3_sandbox(
            16, "pinn_mpc_newman_monroe_viscoplastic_isobaric_tof_ul9540a_h2s_sil3_edge"
        )
        raw = simulate_solid_state_sulfide_battery_dry_electrode_isobaric_h2s_sil3_sandbox(
            16, "constant_roll_gap_uniaxial_press_offline_eis_cloud_polling"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_assb_sulfide_pods"], 8)
        self.assertEqual(gov["energy_density_yield_and_critical_current_ccd_gain_pct"], 34.6)
        self.assertEqual(gov["interfacial_void_delamination_and_ptfe_over_shear_scrap_reduction_pct"], 46.2)
        self.assertEqual(gov["ul9540a_iec62619_sil3_h2s_purge_and_isobaric_relief_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_h2s_dry_room_excursion_or_lithium_dendrite_short_pct"], 0.0)
        self.assertGreater(raw["unmitigated_h2s_dry_room_excursion_or_lithium_dendrite_short_pct"], 1.2)
        self.assertEqual(gov["dry_room_edge_ultrasonic_tof_and_ftir_h2s_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_argyrodite_grain_boundary_crack_or_void_pct"], 0.0)
        self.assertGreater(raw["uncompensated_argyrodite_grain_boundary_crack_or_void_pct"], 3.0)
        self.assertTrue(gov["assb_sulfide_battery_slo_met"])
        self.assertFalse(raw["assb_sulfide_battery_slo_met"])

    def test_pem_fuel_cell_ccm_ultrasonic_spray_bipolar_plate_saej2579_sil3_sandbox(self) -> None:
        gov = simulate_pem_fuel_cell_ccm_ultrasonic_spray_bipolar_plate_saej2579_sil3_sandbox(
            16, "pinn_mpc_butler_volmer_tpb_ionomer_decal_hydroforming_saej2579_sil3_edge"
        )
        raw = simulate_pem_fuel_cell_ccm_ultrasonic_spray_bipolar_plate_saej2579_sil3_sandbox(
            16, "constant_spray_flow_fixed_hot_press_offline_polarization_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_pem_ccm_pods"], 8)
        self.assertEqual(gov["stack_power_density_and_pt_mass_activity_yield_gain_pct"], 33.8)
        self.assertEqual(gov["membrane_pinhole_catalyst_mudcrack_and_bpp_thinning_scrap_reduction_pct"], 45.7)
        self.assertEqual(gov["saej2579_iec62282_sil3_h2_crossover_and_ignition_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_h2_crossover_or_catalytic_pt_solvent_ignition_pct"], 0.0)
        self.assertGreater(raw["unmitigated_h2_crossover_or_catalytic_pt_solvent_ignition_pct"], 1.2)
        self.assertEqual(gov["line_edge_xrf_pt_and_lockin_ir_pinhole_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_ionomer_skin_poisoning_or_micro_pinhole_pct"], 0.0)
        self.assertGreater(raw["uncompensated_ionomer_skin_poisoning_or_micro_pinhole_pct"], 3.0)
        self.assertTrue(gov["pem_fuel_cell_ccm_slo_met"])
        self.assertFalse(raw["pem_fuel_cell_ccm_slo_met"])

    def test_soec_high_temp_steam_co2_coelectrolysis_ceramic_sil3_sandbox(self) -> None:
        gov = simulate_soec_high_temp_steam_co2_coelectrolysis_ceramic_sil3_sandbox(
            16, "pinn_mpc_nernst_tpb_ceramic_thermoelastic_drt_iso22734_sil3_edge"
        )
        raw = simulate_soec_high_temp_steam_co2_coelectrolysis_ceramic_sil3_sandbox(
            16, "constant_voltage_fixed_steam_ratio_open_loop_furnace_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_soec_ceramic_pods"], 8)
        self.assertEqual(gov["faradaic_syngas_efficiency_and_thermoneutral_yield_gain_pct"], 34.2)
        self.assertEqual(gov["ceramic_cell_microcrack_oxygen_electrode_delamination_and_coking_reduction_pct"], 46.5)
        self.assertEqual(gov["iso22734_asme_nfpa2_sil3_hot_h2_co_seal_and_thermal_shock_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_hot_syngas_autoignition_or_ceramic_stack_fracture_pct"], 0.0)
        self.assertGreater(raw["unmitigated_hot_syngas_autoignition_or_ceramic_stack_fracture_pct"], 1.2)
        self.assertEqual(gov["skid_edge_multifreq_drt_eis_and_tdlas_steam_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_ni_cermet_oxidation_or_boudouard_carbon_coking_pct"], 0.0)
        self.assertGreater(raw["uncompensated_ni_cermet_oxidation_or_boudouard_carbon_coking_pct"], 3.0)
        self.assertTrue(gov["soec_coelectrolysis_slo_met"])
        self.assertFalse(raw["soec_coelectrolysis_slo_met"])

    def test_h2_dri_shaft_furnace_hydrogen_reduction_clustering_sil3_sandbox(self) -> None:
        gov = simulate_h2_dri_shaft_furnace_hydrogen_reduction_clustering_sil3_sandbox(
            8, "pinn_mpc_shrinking_core_metallization_clustering_tdlas_nfpa86_sil3_edge"
        )
        raw = simulate_h2_dri_shaft_furnace_hydrogen_reduction_clustering_sil3_sandbox(
            8, "fixed_bustle_gas_temp_manual_burden_feeder_offline_titration_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_h2_dri_pods"], 8)
        self.assertEqual(gov["metallization_degree_consistency_and_specific_h2_yield_gain_pct"], 33.4)
        self.assertEqual(gov["pellet_sintering_clustering_hanging_and_endothermic_freeze_reduction_pct"], 47.2)
        self.assertEqual(gov["nfpa86_iso13577_sil3_hot_pyrophoric_fe_passivation_and_h2_seal_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_hot_sponge_iron_autoignition_or_bustle_h2_jet_fire_pct"], 0.0)
        self.assertGreater(raw["unmitigated_hot_sponge_iron_autoignition_or_bustle_h2_jet_fire_pct"], 1.3)
        self.assertEqual(gov["furnace_edge_topgas_tdlas_mass_spec_and_burden_radar_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_wustite_unreduced_core_or_shaft_channeling_pct"], 0.0)
        self.assertGreater(raw["uncompensated_wustite_unreduced_core_or_shaft_channeling_pct"], 3.0)
        self.assertTrue(gov["h2_dri_shaft_furnace_slo_met"])
        self.assertFalse(raw["h2_dri_shaft_furnace_slo_met"])

    def test_cryo_har_plasma_etch_3dnand_esc_oes_semis2_sil3_sandbox(self) -> None:
        gov = simulate_cryo_har_plasma_etch_3dnand_esc_oes_semis2_sil3_sandbox(
            16, "pinn_mpc_iead_sheath_bowing_oes_interferometry_semis2_sil3_edge"
        )
        raw = simulate_cryo_har_plasma_etch_3dnand_esc_oes_semis2_sil3_sandbox(
            16, "fixed_rf_cw_bias_open_loop_he_chuck_timed_etch_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_cryo_etch_pods"], 8)
        self.assertEqual(gov["har_channel_verticality_cd_yield_and_etch_selectivity_gain_pct"], 35.4)
        self.assertEqual(gov["channel_bowing_twisting_and_arde_notching_scrap_reduction_pct"], 47.8)
        self.assertEqual(gov["semis2_nfpa318_sil3_esc_dechuck_and_hf_abatement_interlock_ms"], 0.3)
        self.assertEqual(gov["unmitigated_esc_wafer_pop_arcing_or_toxic_hf_exhaust_breach_pct"], 0.0)
        self.assertGreater(raw["unmitigated_esc_wafer_pop_arcing_or_toxic_hf_exhaust_breach_pct"], 1.2)
        self.assertEqual(gov["chamber_edge_oes_iead_vip_sensor_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_sidewall_charge_bowing_or_punchthrough_pct"], 0.0)
        self.assertGreater(raw["uncompensated_sidewall_charge_bowing_or_punchthrough_pct"], 3.0)
        self.assertTrue(gov["cryo_har_plasma_etch_slo_met"])
        self.assertFalse(raw["cryo_har_plasma_etch_slo_met"])

    def test_mrna_lnp_microfluidic_mixing_tff_dls_gmp_sil3_sandbox(self) -> None:
        gov = simulate_mrna_lnp_microfluidic_mixing_tff_dls_gmp_sil3_sandbox(
            16, "pinn_mpc_chaotic_advection_smoluchowski_tff_srdls_gmp_sil3_edge"
        )
        raw = simulate_mrna_lnp_microfluidic_mixing_tff_dls_gmp_sil3_sandbox(
            16, "fixed_frr_syringe_pump_offline_batch_dls_unmonitored_ethanol_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_mrna_lnp_pods"], 8)
        self.assertEqual(gov["mrna_encapsulation_efficiency_and_monodisperse_lnp_yield_gain_pct"], 34.8)
        self.assertEqual(gov["polydispersity_pdi_excursion_tff_shear_lysis_and_batch_rejection_reduction_pct"], 47.5)
        self.assertEqual(gov["gmp_annex1_nfpa30_sil3_manifold_overpressure_and_ethanol_lel_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_single_use_bag_rupture_or_ethanol_vapor_ignition_pct"], 0.0)
        self.assertGreater(raw["unmitigated_single_use_bag_rupture_or_ethanol_vapor_ignition_pct"], 1.1)
        self.assertEqual(gov["skid_edge_srdls_raman_and_coriolis_frr_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_lipid_aggregation_or_empty_capsid_fraction_pct"], 0.0)
        self.assertGreater(raw["uncompensated_lipid_aggregation_or_empty_capsid_fraction_pct"], 3.0)
        self.assertTrue(gov["mrna_lnp_microfluidic_slo_met"])
        self.assertFalse(raw["mrna_lnp_microfluidic_slo_met"])

    def test_ultradeep_10km_superhot_rock_drilling_fwi_iso15156_sil3_sandbox(self) -> None:
        gov = simulate_ultradeep_10km_superhot_rock_drilling_fwi_iso15156_sil3_sandbox(
            16, "pinn_mpc_thermoelastic_breakout_hthp_rheology_swd_fwi_iso15156_sil3_edge"
        )
        raw = simulate_ultradeep_10km_superhot_rock_drilling_fwi_iso15156_sil3_sandbox(
            16, "constant_wob_rpm_mud_pulse_telemetry_manual_pit_gain_bop_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_ultradeep_drilling_pods"], 8)
        self.assertEqual(gov["crystalline_basement_rop_and_bit_life_gain_pct"], 35.2)
        self.assertEqual(gov["borehole_breakout_stuck_pipe_and_mud_sag_npt_reduction_pct"], 47.6)
        self.assertEqual(gov["apirp53_iso15156_sil3_sour_gas_h2s_scavenger_and_140mpa_bop_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_h2s_sulfide_stress_cracking_or_hthp_blowout_pct"], 0.0)
        self.assertGreater(raw["unmitigated_h2s_sulfide_stress_cracking_or_hthp_blowout_pct"], 1.2)
        self.assertEqual(gov["rig_edge_swd_fwi_wired_pipe_and_coriolis_kick_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.3)
        self.assertEqual(gov["uncompensated_bha_whirl_or_mwd_260c_thermal_failure_pct"], 0.0)
        self.assertGreater(raw["uncompensated_bha_whirl_or_mwd_260c_thermal_failure_pct"], 3.0)
        self.assertTrue(gov["ultradeep_10km_drilling_slo_met"])
        self.assertFalse(raw["ultradeep_10km_drilling_slo_met"])

    def test_cmp_planarization_hybrid_w2w_bonding_epd_semis2_sil3_sandbox(self) -> None:
        gov = simulate_cmp_planarization_hybrid_w2w_bonding_epd_semis2_sil3_sandbox(
            16, "pinn_mpc_preston_reynolds_cmp_w2w_wavefront_epd_ir_semis2_sil3_edge"
        )
        raw = simulate_cmp_planarization_hybrid_w2w_bonding_epd_semis2_sil3_sandbox(
            16, "fixed_membrane_pressure_timed_polish_open_loop_w2w_pin_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_cmp_w2w_pods"], 8)
        self.assertEqual(gov["submicron_cu_hybrid_bonding_yield_and_overlay_alignment_gain_pct"], 35.6)
        self.assertEqual(gov["cu_dishing_sio2_erosion_and_interfacial_void_scrap_reduction_pct"], 48.2)
        self.assertEqual(gov["semis2_s8_sil3_retaining_ring_wafer_slip_and_chuck_vacuum_interlock_ms"], 0.3)
        self.assertEqual(gov["unmitigated_wafer_breakage_slurry_leak_or_chuck_drop_pct"], 0.0)
        self.assertGreater(raw["unmitigated_wafer_breakage_slurry_leak_or_chuck_drop_pct"], 1.1)
        self.assertEqual(gov["bay_edge_eddy_current_epd_and_ir_void_interferometry_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_pad_glazing_drift_or_bonding_wave_asymmetry_pct"], 0.0)
        self.assertGreater(raw["uncompensated_pad_glazing_drift_or_bonding_wave_asymmetry_pct"], 3.0)
        self.assertTrue(gov["cmp_w2w_hybrid_bonding_slo_met"])
        self.assertFalse(raw["cmp_w2w_hybrid_bonding_slo_met"])

    def test_single_crystal_superalloy_bridgman_lmc_casting_ams2280_sil3_sandbox(self) -> None:
        gov = simulate_single_crystal_superalloy_bridgman_lmc_casting_ams2280_sil3_sandbox(
            16, "pinn_mpc_mushy_zone_gr_pdas_rayleigh_freckle_xray_ams2280_sil3_edge"
        )
        raw = simulate_single_crystal_superalloy_bridgman_lmc_casting_ams2280_sil3_sandbox(
            16, "fixed_withdrawal_speed_open_loop_baffle_post_cast_laue_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_sx_casting_pods"], 8)
        self.assertEqual(gov["single_crystal_001_yield_and_creep_rupture_life_gain_pct"], 36.1)
        self.assertEqual(gov["freckle_chain_stray_grain_and_hab_scrap_reduction_pct"], 48.6)
        self.assertEqual(gov["ams2280_nfpa86_sil3_ceramic_shell_breach_and_lmc_tin_quench_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_molten_superalloy_runout_or_lmc_vapor_explosion_pct"], 0.0)
        self.assertGreater(raw["unmitigated_molten_superalloy_runout_or_lmc_vapor_explosion_pct"], 1.1)
        self.assertEqual(gov["furnace_edge_xray_radioscopy_and_pyrometer_baffle_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_spiral_selector_misorientation_or_sliver_defect_pct"], 0.0)
        self.assertGreater(raw["uncompensated_spiral_selector_misorientation_or_sliver_defect_pct"], 3.0)
        self.assertTrue(gov["sx_superalloy_bridgman_slo_met"])
        self.assertFalse(raw["sx_superalloy_bridgman_slo_met"])

    def test_subsea_methane_hydrate_depressurization_sand_control_dts_sil3_sandbox(self) -> None:
        gov = simulate_subsea_methane_hydrate_depressurization_sand_control_dts_sil3_sandbox(
            16, "pinn_mpc_kim_bishnoi_dissociation_jt_plug_sand_subsidence_dts_apirp14c_sil3_edge"
        )
        raw = simulate_subsea_methane_hydrate_depressurization_sand_control_dts_sil3_sandbox(
            16, "aggressive_step_drawdown_esp_open_loop_choke_unmonitored_sand_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_hydrate_well_pods"], 8)
        self.assertEqual(gov["ch4_hydrate_gas_recovery_and_sand_free_uptime_gain_pct"], 35.4)
        self.assertEqual(gov["wellbore_secondary_hydrate_plug_and_screen_erosion_reduction_pct"], 47.8)
        self.assertEqual(gov["apirp14c_iso13628_sil3_meg_injection_and_seafloor_subsidence_shutin_ms"], 0.5)
        self.assertEqual(gov["unmitigated_seafloor_methane_seepage_or_wellhead_tilt_collapse_pct"], 0.0)
        self.assertGreater(raw["unmitigated_seafloor_methane_seepage_or_wellhead_tilt_collapse_pct"], 1.1)
        self.assertEqual(gov["vessel_edge_downhole_das_dts_and_acoustic_sand_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_gravel_pack_plugging_or_endothermic_ice_blockage_pct"], 0.0)
        self.assertGreater(raw["uncompensated_gravel_pack_plugging_or_endothermic_ice_blockage_pct"], 3.0)
        self.assertTrue(gov["subsea_methane_hydrate_slo_met"])
        self.assertFalse(raw["subsea_methane_hydrate_slo_met"])

    def test_uhv_mbe_quantum_epitaxy_rheed_bet_semis2_sil3_sandbox(self) -> None:
        gov = simulate_uhv_mbe_quantum_epitaxy_rheed_bet_semis2_sil3_sandbox(
            16, "pinn_mpc_bcf_step_flow_knudsen_flux_rheed_bet_semis2_sil3_edge"
        )
        raw = simulate_uhv_mbe_quantum_epitaxy_rheed_bet_semis2_sil3_sandbox(
            16, "timed_shutter_fixed_cell_temp_thermocouple_offset_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_uhv_mbe_pods"], 8)
        self.assertEqual(gov["two_deg_mobility_and_monolayer_thickness_uniformity_gain_pct"], 36.4)
        self.assertEqual(gov["oval_defect_threading_dislocation_and_flux_transient_scrap_reduction_pct"], 48.8)
        self.assertEqual(gov["semis2_nfpa318_sil3_arsenic_phosphorus_cracker_and_uhv_gate_interlock_ms"], 0.3)
        self.assertEqual(gov["unmitigated_white_phosphorus_ignition_toxic_ash3_leak_or_uhv_vent_pct"], 0.0)
        self.assertGreater(raw["unmitigated_white_phosphorus_ignition_toxic_ash3_leak_or_uhv_vent_pct"], 1.1)
        self.assertEqual(gov["chamber_edge_rheed_oscillation_and_band_edge_thermometry_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_shutter_flux_overshoot_or_surface_reconstruction_drift_pct"], 0.0)
        self.assertGreater(raw["uncompensated_shutter_flux_overshoot_or_surface_reconstruction_drift_pct"], 3.0)
        self.assertTrue(gov["uhv_mbe_quantum_epitaxy_slo_met"])
        self.assertFalse(raw["uhv_mbe_quantum_epitaxy_slo_met"])

    def test_ldpe_hypercompressor_tubular_reactor_ftnir_api618_sil3_sandbox(self) -> None:
        gov = simulate_ldpe_hypercompressor_tubular_reactor_ftnir_api618_sil3_sandbox(
            16, "pinn_mpc_free_radical_runaway_plunger_rodload_ftnir_api618_sil3_edge"
        )
        raw = simulate_ldpe_hypercompressor_tubular_reactor_ftnir_api618_sil3_sandbox(
            16, "fixed_peroxide_initiator_dosing_offline_rheometer_delayed_dump_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_ldpe_reactor_pods"], 8)
        self.assertEqual(gov["single_pass_ethylene_conversion_and_mfi_grade_transition_gain_pct"], 35.8)
        self.assertEqual(gov["ethylene_runaway_decomposition_and_plunger_packing_failure_reduction_pct"], 49.2)
        self.assertEqual(gov["api618_asmediv3_sil3_rapid_dump_valve_and_peroxide_cutoff_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_tubular_autodecomposition_blast_or_wc_plunger_shatter_pct"], 0.0)
        self.assertGreater(raw["unmitigated_tubular_autodecomposition_blast_or_wc_plunger_shatter_pct"], 1.1)
        self.assertEqual(gov["train_edge_ftnir_melt_index_and_hypercompressor_ae_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_fouling_wall_film_hot_spot_or_off_spec_gel_pct"], 0.0)
        self.assertGreater(raw["uncompensated_fouling_wall_film_hot_spot_or_off_spec_gel_pct"], 3.0)
        self.assertTrue(gov["ldpe_hypercompressor_reactor_slo_met"])
        self.assertFalse(raw["ldpe_hypercompressor_reactor_slo_met"])

    def test_medical_cyclotron_radiopharma_hotcell_usp823_sil3_sandbox(self) -> None:
        gov = simulate_medical_cyclotron_radiopharma_hotcell_usp823_sil3_sandbox(
            16, "pinn_mpc_bethe_bloch_target_boiling_decay_corrected_synthesis_usp823_sil3_edge"
        )
        raw = simulate_medical_cyclotron_radiopharma_hotcell_usp823_sil3_sandbox(
            16, "static_beam_collimator_fixed_timer_cassette_manual_qc_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_cyclotron_pods"], 8)
        self.assertEqual(gov["decay_corrected_radiochemical_yield_and_molar_activity_gain_pct"], 36.2)
        self.assertEqual(gov["havar_foil_burnout_and_radiolysis_impurity_batch_scrap_reduction_pct"], 48.5)
        self.assertEqual(gov["iaea_ssg30_usp823_sil3_rf_crowbar_and_hotcell_delay_tank_interlock_ms"], 0.3)
        self.assertEqual(gov["unmitigated_airborne_18f_release_or_havar_window_rupture_pct"], 0.0)
        self.assertGreater(raw["unmitigated_airborne_18f_release_or_havar_window_rupture_pct"], 1.1)
        self.assertEqual(gov["vault_edge_prompt_gamma_and_radio_hplc_qc_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_target_voiding_beam_walk_or_kryptofix_exceedance_pct"], 0.0)
        self.assertGreater(raw["uncompensated_target_voiding_beam_walk_or_kryptofix_exceedance_pct"], 3.0)
        self.assertTrue(gov["medical_cyclotron_radiopharma_slo_met"])
        self.assertFalse(raw["medical_cyclotron_radiopharma_slo_met"])

    def test_hollowcore_optical_fiber_draw_tower_meniscus_itu_sil3_sandbox(self) -> None:
        gov = simulate_hollowcore_optical_fiber_draw_tower_meniscus_itu_sil3_sandbox(
            16, "pinn_mpc_neckdown_meniscus_nanf_capillary_pressure_itu_sil3_edge"
        )
        raw = simulate_hollowcore_optical_fiber_draw_tower_meniscus_itu_sil3_sandbox(
            16, "pid_capstan_speed_fixed_manifold_pressure_offline_otdr_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_draw_tower_pods"], 8)
        self.assertEqual(gov["nanf_sub_01db_km_attenuation_and_draw_speed_yield_gain_pct"], 35.9)
        self.assertEqual(gov["capillary_collapse_and_diameter_rayleigh_wave_scrap_reduction_pct"], 48.7)
        self.assertEqual(gov["itu_nfpa86_sil3_bare_fiber_whip_catcher_and_argon_seal_interlock_ms"], 0.3)
        self.assertEqual(gov["unmitigated_high_speed_bare_fiber_shatter_or_graphite_oxidation_pct"], 0.0)
        self.assertGreater(raw["unmitigated_high_speed_bare_fiber_shatter_or_graphite_oxidation_pct"], 1.2)
        self.assertEqual(gov["tower_edge_10khz_laser_micrometer_and_concentricity_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_microtube_asymmetry_or_uv_coating_delamination_pct"], 0.0)
        self.assertGreater(raw["uncompensated_microtube_asymmetry_or_uv_coating_delamination_pct"], 3.0)
        self.assertTrue(gov["hollowcore_optical_fiber_draw_slo_met"])
        self.assertFalse(raw["hollowcore_optical_fiber_draw_slo_met"])

    def test_polysilicon_siemens_cvd_fbr_trichlorosilane_semis2_sil3_sandbox(self) -> None:
        gov = simulate_polysilicon_siemens_cvd_fbr_trichlorosilane_semis2_sil3_sandbox(
            16, "pinn_mpc_tcs_cvd_fbr_boundary_layer_popcorn_crds_semis2_sil3_edge"
        )
        raw = simulate_polysilicon_siemens_cvd_fbr_trichlorosilane_semis2_sil3_sandbox(
            16, "fixed_current_ramp_constant_tcs_h2_ratio_offline_ftir_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_polysilicon_pods"], 8)
        self.assertEqual(gov["specific_power_consumption_cut_and_11n_12n_yield_gain_pct"], 36.3)
        self.assertEqual(gov["popcorn_crystal_homogeneous_dust_and_rod_collapse_reduction_pct"], 49.0)
        self.assertEqual(gov["nfpa69_semis2_sil3_chlorosilane_isolation_and_water_jacket_depressurization_ms"], 0.4)
        self.assertEqual(gov["unmitigated_chlorosilane_h2_autoignition_or_water_jacket_steam_explosion_pct"], 0.0)
        self.assertGreater(raw["unmitigated_chlorosilane_h2_autoignition_or_water_jacket_steam_explosion_pct"], 1.1)
        self.assertEqual(gov["reactor_bay_edge_crds_subppt_dopant_and_two_color_pyrometer_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_boron_phosphorus_donor_contamination_or_core_melt_pct"], 0.0)
        self.assertGreater(raw["uncompensated_boron_phosphorus_donor_contamination_or_core_melt_pct"], 3.0)
        self.assertTrue(gov["polysilicon_siemens_cvd_fbr_slo_met"])
        self.assertFalse(raw["polysilicon_siemens_cvd_fbr_slo_met"])

    def test_cryogenic_asu_air_separation_lox_reboiler_eiga65_sil3_sandbox(self) -> None:
        gov = simulate_cryogenic_asu_air_separation_lox_reboiler_eiga65_sil3_sandbox(
            16, "pinn_mpc_cryo_distillation_argon_front_laes_eiga65_sil3_edge"
        )
        raw = simulate_cryogenic_asu_air_separation_lox_reboiler_eiga65_sil3_sandbox(
            16, "manual_load_ramp_fixed_reflux_ratio_periodic_lox_gc_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_asu_pods"], 8)
        self.assertEqual(gov["argon_krypton_recovery_and_renewable_load_following_ramp_gain_pct"], 35.6)
        self.assertEqual(gov["argon_column_nitrogen_plugging_and_packing_flooding_vent_reduction_pct"], 48.3)
        self.assertEqual(gov["eiga65_cgap8_sil3_lox_reboiler_purge_and_turboexpander_trip_ms"], 0.3)
        self.assertEqual(gov["unmitigated_lox_reboiler_acetylene_detonation_or_oxygen_compressor_fire_pct"], 0.0)
        self.assertGreater(raw["unmitigated_lox_reboiler_acetylene_detonation_or_oxygen_compressor_fire_pct"], 1.0)
        self.assertEqual(gov["coldbox_edge_lox_ftir_gcdid_hydrocarbon_and_bearing_orbit_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_tsa_co2_breakthrough_freezing_or_9n_purity_excursion_pct"], 0.0)
        self.assertGreater(raw["uncompensated_tsa_co2_breakthrough_freezing_or_9n_purity_excursion_pct"], 3.0)
        self.assertTrue(gov["cryogenic_asu_air_separation_slo_met"])
        self.assertFalse(raw["cryogenic_asu_air_separation_slo_met"])

    def test_chlor_alkali_membrane_electrolyzer_cl2_h2_eurochlor_sil3_sandbox(self) -> None:
        gov = simulate_chlor_alkali_membrane_electrolyzer_cl2_h2_eurochlor_sil3_sandbox(
            16, "pinn_mpc_zero_gap_bilayer_membrane_tdlas_h2_in_cl2_eurochlor_sil3_edge"
        )
        raw = simulate_chlor_alkali_membrane_electrolyzer_cl2_h2_eurochlor_sil3_sandbox(
            16, "manual_dp_valve_fixed_rectifier_ramp_periodic_brine_icp_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_electrolyzer_pods"], 8)
        self.assertEqual(gov["specific_dc_power_saving_and_current_efficiency_gain_pct"], 34.8)
        self.assertEqual(gov["membrane_blistering_voltage_creep_and_ca_mg_scaling_reduction_pct"], 48.6)
        self.assertEqual(gov["eurochlor_gest_sil3_n2_inerting_and_polarization_rectifier_interlock_ms"], 0.3)
        self.assertEqual(gov["unmitigated_h2_in_cl2_photochemical_detonation_or_dsa_reverse_current_pct"], 0.0)
        self.assertGreater(raw["unmitigated_h2_in_cl2_photochemical_detonation_or_dsa_reverse_current_pct"], 1.0)
        self.assertEqual(gov["cellroom_edge_tdlas_h2_in_cl2_and_dp_hydrostatic_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_brine_hardness_breakthrough_or_chlorate_excursion_pct"], 0.0)
        self.assertGreater(raw["uncompensated_brine_hardness_breakthrough_or_chlorate_excursion_pct"], 3.0)
        self.assertTrue(gov["chlor_alkali_membrane_electrolyzer_slo_met"])
        self.assertFalse(raw["chlor_alkali_membrane_electrolyzer_slo_met"])

    def test_carbon_fiber_pan_oxidation_carbonization_hcn_nfpa86_sil3_sandbox(self) -> None:
        gov = simulate_carbon_fiber_pan_oxidation_carbonization_hcn_nfpa86_sil3_sandbox(
            16, "pinn_mpc_pan_exotherm_waxs_orientation_godet_tension_nfpa86_sil3_edge"
        )
        raw = simulate_carbon_fiber_pan_oxidation_carbonization_hcn_nfpa86_sil3_sandbox(
            16, "static_zone_temp_fixed_stretch_ratio_offline_tensile_coupon_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_carbon_fiber_pods"], 8)
        self.assertEqual(gov["tensile_strength_weibull_modulus_and_tow_yield_gain_pct"], 37.8)
        self.assertEqual(gov["oxidation_core_skin_heterogeneity_and_fuzz_break_reduction_pct"], 51.6)
        self.assertEqual(gov["nfpa86_sil3_n2_quench_and_hcn_labyrinth_curtain_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_oxidation_exothermic_runaway_or_hcn_leak_pct"], 0.0)
        self.assertGreater(raw["unmitigated_oxidation_exothermic_runaway_or_hcn_leak_pct"], 1.0)
        self.assertEqual(gov["furnace_edge_waxs_raman_orientation_and_godet_tension_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_tar_condensation_or_muffle_oxygen_ingress_pct"], 0.0)
        self.assertGreater(raw["uncompensated_tar_condensation_or_muffle_oxygen_ingress_pct"], 3.0)
        self.assertTrue(gov["carbon_fiber_pan_oxidation_carbonization_slo_met"])
        self.assertFalse(raw["carbon_fiber_pan_oxidation_carbonization_slo_met"])

    def test_dle_lithium_brine_sorption_libs_epauic_sil3_sandbox(self) -> None:
        gov = simulate_dle_lithium_brine_sorption_libs_epauic_sil3_sandbox(
            16, "pinn_mpc_spinel_sieve_breakthrough_mcdi_libs_epauic_sil3_edge"
        )
        raw = simulate_dle_lithium_brine_sorption_libs_epauic_sil3_sandbox(
            16, "fixed_bed_volume_timer_manual_acid_elution_offline_icp_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_dle_pods"], 8)
        self.assertEqual(gov["lithium_recovery_yield_and_eluate_purity_gain_pct"], 38.4)
        self.assertEqual(gov["freshwater_acid_consumption_and_sorbent_dissolution_reduction_pct"], 52.4)
        self.assertEqual(gov["epauic_sil3_reinjection_hipps_and_h2s_scrubber_interlock_ms"], 0.4)
        self.assertEqual(gov["unmitigated_caprock_fracturing_overpressure_or_h2s_flash_pct"], 0.0)
        self.assertGreater(raw["unmitigated_caprock_fracturing_overpressure_or_h2s_flash_pct"], 1.0)
        self.assertEqual(gov["carousel_edge_libs_breakthrough_and_mcdi_voltage_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_mg_ca_coelution_or_silica_scaling_pct"], 0.0)
        self.assertGreater(raw["uncompensated_mg_ca_coelution_or_silica_scaling_pct"], 3.0)
        self.assertTrue(gov["dle_lithium_brine_sorption_slo_met"])
        self.assertFalse(raw["dle_lithium_brine_sorption_slo_met"])

    def test_vrfb_flow_battery_ldes_uvvis_nfpa855_sil3_sandbox(self) -> None:
        gov = simulate_vrfb_flow_battery_ldes_uvvis_nfpa855_sil3_sandbox(
            16, "pinn_mpc_donnan_crossover_valence_rebalancing_uvvis_nfpa855_sil3_edge"
        )
        raw = simulate_vrfb_flow_battery_ldes_uvvis_nfpa855_sil3_sandbox(
            16, "constant_flow_rate_coulomb_counting_manual_remix_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_vrfb_pods"], 8)
        self.assertEqual(gov["usable_discharge_capacity_retention_and_roundtrip_efficiency_gain_pct"], 37.8)
        self.assertEqual(gov["pump_parasitic_loss_and_shunt_current_reduction_pct"], 48.6)
        self.assertEqual(gov["nfpa855_sil3_h2_headspace_purge_and_dc_breaker_trip_ms"], 0.4)
        self.assertEqual(gov["unmitigated_h2_evolution_lel_or_v2o5_thermal_precipitation_pct"], 0.0)
        self.assertGreater(raw["unmitigated_h2_evolution_lel_or_v2o5_thermal_precipitation_pct"], 1.0)
        self.assertEqual(gov["stack_edge_uvvis_valence_and_stoichiometric_flow_loop_ms"], 0.4)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.4)
        self.assertEqual(gov["uncompensated_valence_imbalance_or_bipolar_plate_corrosion_pct"], 0.0)
        self.assertGreater(raw["uncompensated_valence_imbalance_or_bipolar_plate_corrosion_pct"], 3.0)
        self.assertTrue(gov["vrfb_flow_battery_ldes_slo_met"])
        self.assertFalse(raw["vrfb_flow_battery_ldes_slo_met"])

    def test_ebam_electron_beam_titanium_elo_ams4999_sil3_sandbox(self) -> None:
        gov = simulate_ebam_electron_beam_titanium_elo_ams4999_sil3_sandbox(
            16, "pinn_mpc_elo_keyhole_al_vaporization_ams4999_nfpa484_sil3_edge"
        )
        raw = simulate_ebam_electron_beam_titanium_elo_ams4999_sil3_sandbox(
            16, "open_loop_beam_current_fixed_wire_feed_post_build_hip_cloud"
        )
        self.assertEqual(gov["gpu_nodes"], 2)
        self.assertEqual(gov["active_ebam_pods"], 8)
        self.assertEqual(gov["fatigue_life_and_as_built_density_qualification_gain_pct"], 39.2)
        self.assertEqual(gov["al_evaporation_scrap_and_machining_allowance_reduction_pct"], 53.6)
        self.assertEqual(gov["ams4999_sil3_hv_crowbar_and_argon_passivation_interlock_ms"], 0.2)
        self.assertEqual(gov["unmitigated_hv_arc_flashover_or_pyrophoric_soot_ignition_pct"], 0.0)
        self.assertGreater(raw["unmitigated_hv_arc_flashover_or_pyrophoric_soot_ignition_pct"], 1.0)
        self.assertEqual(gov["gun_edge_elo_tomography_and_magnetic_deflection_loop_ms"], 0.3)
        self.assertEqual(gov["wan_bandwidth_reduction_pct"], 99.6)
        self.assertEqual(gov["uncompensated_keyhole_lack_of_fusion_or_alpha_case_embrittlement_pct"], 0.0)
        self.assertGreater(raw["uncompensated_keyhole_lack_of_fusion_or_alpha_case_embrittlement_pct"], 3.0)
        self.assertTrue(gov["ebam_electron_beam_titanium_slo_met"])
        self.assertFalse(raw["ebam_electron_beam_titanium_slo_met"])


if __name__ == "__main__":
    unittest.main()
