"""Data Lab — Microsoft Fabric x 4-Cloud Competitive Benchmark & Ontology Simulator."""

from .benchmark_suite import (
    PLATFORMS,
    COMPETITIVE_DIMENSIONS,
    evaluate_scenario_matrix,
    calculate_five_cloud_tco,
    simulate_ontology_incident,
    evaluate_perturbation_robustness,
    evaluate_scaling_latency,
    build_sealed_report,
)

__all__ = [
    "PLATFORMS",
    "COMPETITIVE_DIMENSIONS",
    "evaluate_scenario_matrix",
    "calculate_five_cloud_tco",
    "simulate_ontology_incident",
    "evaluate_perturbation_robustness",
    "evaluate_scaling_latency",
    "build_sealed_report",
]
