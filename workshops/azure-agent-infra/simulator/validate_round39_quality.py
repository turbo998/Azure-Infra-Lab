#!/usr/bin/env python3
"""Targeted structural quality checks for Round39 remediation package."""

from __future__ import annotations

import json
import math
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = Path(
    r"C:\Users\qichen2\.copilot\session-state\587de17e-18a2-4ad2-a03e-5539fad5dab5\files\nightly-deliverables-2026-11-08.json"
)


def _title_from_md(path: Path) -> str:
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    raise AssertionError(f"Missing title line in {path}")


def _extract_contract_path(md_text: str) -> tuple[int, str]:
    m = re.search(r"cycle-(\d+)-benchmark\.json", md_text)
    if not m:
        raise AssertionError("Missing cycle-xxx-benchmark.json reference in FAQ")
    return int(m.group(1)), m.group(0)


def _check_faq_shape(path: Path) -> int:
    text = path.read_text(encoding="utf-8")
    assert "## 2) Q1 / Q2 / Q3" in text, f"{path} missing Q1/Q2/Q3 section"
    assert "## 6)" in text, f"{path} missing section #6"
    assert "percentage_contract." in text, f"{path} missing percentage_contract key references"
    cycle_id, _ = _extract_contract_path(text)
    return cycle_id


def _check_percentage_contract(cycle_id: int, required_keys: list[str]) -> None:
    p = ROOT / "evidence" / f"cycle-{cycle_id}-benchmark.json"
    payload = json.loads(p.read_text(encoding="utf-8"))
    contract = payload.get("percentage_contract")
    assert isinstance(contract, dict), f"{p} missing percentage_contract"
    for key in required_keys:
        row = contract.get(key)
        assert isinstance(row, dict), f"{p} missing contract row {key}"
        num = row.get("numerator")
        den = row.get("denominator")
        pct = row.get("percentage")
        assert isinstance(num, (int, float)) and isinstance(den, (int, float)) and den > 0, f"{p}:{key} bad n/denominator"
        assert isinstance(pct, (int, float)), f"{p}:{key} missing percentage"
        recomputed = round(num / den * 100, 1)
        assert math.isclose(recomputed, float(pct), rel_tol=0, abs_tol=0.11), (
            f"{p}:{key} recompute mismatch expected {recomputed}, got {pct}"
        )
        assert row.get("source_path"), f"{p}:{key} missing source_path"
        assert row.get("source_label"), f"{p}:{key} missing source_label"
        assert row.get("production_validation") == "not_measured", f"{p}:{key} production_validation must be not_measured"
        if cycle_id == 418:
            assert row.get("source_label") == "synthetic_assumed", (
                f"{p}:{key} must be synthetic_assumed after attribution correction"
            )
            if key == "attested_gain_vs_log_only":
                assert row.get("unit") == "percentage_points", f"{p}:{key} must use percentage_points unit"


def _check_source_timestamp_quality(cycle_id: int) -> None:
    for suffix in ("benchmark", "sources"):
        p = ROOT / "evidence" / f"cycle-{cycle_id}-{suffix}.json"
        obj = json.loads(p.read_text(encoding="utf-8"))
        sources = obj["sources"] if isinstance(obj, dict) else obj
        for src in sources:
            pod = src.get("published_or_doc_date", "")
            assert "fetched 2026-11-14" not in pod, f"{p} still contains future fetched-date claim"
            if "timestamp_unverified" in pod:
                assert src.get("verification_label") == "legacy_timestamp_unverified", (
                    f"{p} timestamp_unverified entry missing verification label"
                )


def _check_manifest_semantics() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    rounds = {r["round"]: r for r in manifest["rounds"]}

    r35 = rounds[35]
    r36 = rounds[36]
    r37 = rounds[37]

    assert r35["semantic_dedup_guard"]["classification"] == "remediation_extension"
    assert r36["semantic_dedup_guard"]["classification"] == "remediation_extension"
    assert r37["semantic_related_rounds"]["status"] == "related_not_duplicate_pending_verification"

    path35 = Path(r35["faq"]["zh"]["path"])
    path36 = Path(r36["faq"]["zh"]["path"])
    path37 = Path(r37["faq"]["zh"]["path"])
    assert r35["faq"]["zh"]["title"] == _title_from_md(ROOT.parents[1] / path35)
    assert r36["faq"]["zh"]["title"] == _title_from_md(ROOT.parents[1] / path36)
    assert r37["faq"]["zh"]["title"] == _title_from_md(ROOT.parents[1] / path37)


def main() -> None:
    faq_contracts: dict[int, list[str]] = {}
    faq_files = [
        ROOT / "agent-policy-canary-rollout-selection-faq.md",
        ROOT / "agent-policy-canary-rollout-selection-faq.en.md",
        ROOT / "agent-tool-timeout-budget-selection-faq.md",
        ROOT / "agent-tool-timeout-budget-selection-faq.en.md",
        ROOT / "agent-tool-output-hash-attestation-selection-faq.md",
        ROOT / "agent-tool-output-hash-attestation-selection-faq.en.md",
    ]
    for f in faq_files:
        cycle_id = _check_faq_shape(f)
        faq_contracts.setdefault(cycle_id, [])

    _check_percentage_contract(
        416,
        [
            "policy_gate_false_positive_trigger_rate",
            "fixed_rollout_blast_spread_rate",
            "slo_gate_blast_spread_rate",
        ],
    )
    _check_percentage_contract(
        417,
        [
            "static_allocation_timeout_rate",
            "dynamic_allocation_timeout_rate",
            "dynamic_vs_static_success_gain",
        ],
    )
    _check_percentage_contract(
        418,
        [
            "log_only_first_pass_attribution_rate",
            "attested_first_pass_attribution_rate",
            "attested_gain_vs_log_only",
        ],
    )

    _check_source_timestamp_quality(416)
    _check_source_timestamp_quality(417)
    _check_source_timestamp_quality(418)
    _check_manifest_semantics()
    print("round39_quality: PASS (faq shape + contract math + semantic classification + source chronology)")


if __name__ == "__main__":
    main()
