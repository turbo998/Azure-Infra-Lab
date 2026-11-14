#!/usr/bin/env python3
"""Targeted structural quality checks for Round39 remediation package."""

from __future__ import annotations

import json
import re
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = ROOT.parents[1]
MANIFEST = Path(
    r"C:\Users\qichen2\.copilot\session-state\587de17e-18a2-4ad2-a03e-5539fad5dab5\files\nightly-deliverables-2026-11-08.json"
)

FAQ_CONTRACTS = {
    "agent-policy-canary-rollout-selection-faq.md": {
        "cycle": 416,
        "title": "Agent 策略灰度门禁阈值选型 FAQ（固定比例放量 vs SLO 触发自动回滚）",
        "keys": {
            "policy_gate_false_positive_trigger_rate",
            "fixed_rollout_blast_spread_rate",
            "slo_gate_blast_spread_rate",
        },
    },
    "agent-policy-canary-rollout-selection-faq.en.md": {
        "cycle": 416,
        "title": "Agent Policy Canary Gate FAQ (Fixed Ramp Ratio vs SLO-Triggered Auto-Rollback)",
        "keys": {
            "policy_gate_false_positive_trigger_rate",
            "fixed_rollout_blast_spread_rate",
            "slo_gate_blast_spread_rate",
        },
    },
    "agent-tool-timeout-budget-selection-faq.md": {
        "cycle": 417,
        "title": "Agent 工具超时预算分配选型 FAQ（静态配比 vs 队列年龄动态配比）",
        "keys": {
            "static_allocation_timeout_rate",
            "dynamic_allocation_timeout_rate",
            "dynamic_vs_static_success_gain",
        },
    },
    "agent-tool-timeout-budget-selection-faq.en.md": {
        "cycle": 417,
        "title": "Agent Tool Timeout Budget Allocation FAQ (Static Split vs Queue-Age Dynamic Split)",
        "keys": {
            "static_allocation_timeout_rate",
            "dynamic_allocation_timeout_rate",
            "dynamic_vs_static_success_gain",
        },
    },
    "agent-tool-output-hash-attestation-selection-faq.md": {
        "cycle": 418,
        "title": "Agent 工具输出哈希证明选型 FAQ（仅日志留痕 vs 哈希签名可验证链）",
        "keys": {
            "log_only_first_pass_attribution_rate",
            "attested_first_pass_attribution_rate",
            "attested_gain_vs_log_only",
        },
    },
    "agent-tool-output-hash-attestation-selection-faq.en.md": {
        "cycle": 418,
        "title": "Agent Tool Output Hash Attestation FAQ (Log-Only Trace vs Verifiable Hash+Signature Chain)",
        "keys": {
            "log_only_first_pass_attribution_rate",
            "attested_first_pass_attribution_rate",
            "attested_gain_vs_log_only",
        },
    },
}


def _round_one_decimal(value: Decimal) -> Decimal:
    return value.quantize(Decimal("0.1"), rounding=ROUND_HALF_UP)


def _title_from_md_text(text: str) -> str:
    for line in text.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    raise AssertionError("Missing markdown title line")


def _extract_cycle_from_faq(text: str) -> int:
    m = re.search(r"cycle-(\d+)-benchmark\.json", text)
    if not m:
        raise AssertionError("Missing cycle-xxx-benchmark.json reference in FAQ")
    return int(m.group(1))


def _extract_contract_keys_from_faq(text: str) -> set[str]:
    keys = set(re.findall(r"percentage_contract\.([a-zA-Z0-9_]+)", text))
    if not keys:
        raise AssertionError("Missing percentage_contract key references in FAQ")
    return keys


def _assert_six_part_shape(text: str) -> None:
    sections = set(re.findall(r"^##\s+([1-6])\)", text, flags=re.MULTILINE))
    assert sections == {"1", "2", "3", "4", "5", "6"}, "FAQ must contain complete section 1..6 headings"
    assert "## 2) Q1 / Q2 / Q3" in text, "FAQ missing explicit Q1/Q2/Q3 section marker"


def _validate_contract_row(cycle_id: int, key: str, row: dict) -> None:
    num = Decimal(str(row["numerator"]))
    den = Decimal(str(row["denominator"]))
    pct = Decimal(str(row["percentage"]))
    recomputed = _round_one_decimal((num / den) * Decimal("100"))
    assert pct == recomputed, f"cycle-{cycle_id} {key} percentage mismatch: expected {recomputed}, got {pct}"
    assert row.get("source_path"), f"cycle-{cycle_id} {key} missing source_path"
    assert row.get("source_label"), f"cycle-{cycle_id} {key} missing source_label"
    assert row.get("production_validation") == "not_measured", f"cycle-{cycle_id} {key} must be not_measured"


def _validate_single_faq(path: Path, expected: dict) -> None:
    text = path.read_text(encoding="utf-8")
    _assert_six_part_shape(text)
    assert _title_from_md_text(text) == expected["title"], f"{path.name} title mismatch"
    cycle = _extract_cycle_from_faq(text)
    assert cycle == expected["cycle"], f"{path.name} cycle reference mismatch: expected {expected['cycle']}, got {cycle}"
    keys = _extract_contract_keys_from_faq(text)
    assert keys == expected["keys"], f"{path.name} contract-key set mismatch"

    benchmark = json.loads((ROOT / "evidence" / f"cycle-{cycle}-benchmark.json").read_text(encoding="utf-8"))
    contract = benchmark.get("percentage_contract")
    assert isinstance(contract, dict), f"cycle-{cycle}-benchmark missing percentage_contract"

    for key in sorted(expected["keys"]):
        assert key in contract, f"cycle-{cycle} missing key {key}"
        row = contract[key]
        _validate_contract_row(cycle, key, row)
        source_path = str(row.get("source_path", ""))
        assert path.name.replace(".en.md", ".md") in source_path, f"{path.name} key {key} source_path mismatch"

    # extra strictness for cycle 418 correction
    if cycle == 418:
        for key in expected["keys"]:
            row = contract[key]
            assert row.get("source_label") == "synthetic_assumed", "cycle-418 attribution must be synthetic_assumed"
        assert contract["attested_gain_vs_log_only"]["unit"] == "percentage_points"


def _check_source_timestamp_quality(cycle_id: int) -> None:
    for suffix in ("benchmark", "sources"):
        p = ROOT / "evidence" / f"cycle-{cycle_id}-{suffix}.json"
        obj = json.loads(p.read_text(encoding="utf-8"))
        sources = obj["sources"] if isinstance(obj, dict) else obj
        for src in sources:
            pod = src.get("published_or_doc_date", "")
            assert "fetched 2026-11-14" not in pod, f"{p.name} still contains future fetched-date claim"
            if "timestamp_unverified" in pod:
                assert src.get("verification_label") == "legacy_timestamp_unverified", (
                    f"{p.name} timestamp_unverified entry missing verification_label"
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
    assert r37["data_contract_assertions"]["assumption_labeling"] == "synthetic_assumed (hypothetical examples)"

    for round_id in (35, 36, 37):
        faq_zh = rounds[round_id]["faq"]["zh"]
        faq_en = rounds[round_id]["faq"]["en"]

        zh_file_title = _title_from_md_text((REPO_ROOT / faq_zh["path"]).read_text(encoding="utf-8"))
        en_file_title = _title_from_md_text((REPO_ROOT / faq_en["path"]).read_text(encoding="utf-8"))

        assert faq_zh["title"] == zh_file_title, f"round {round_id} zh manifest title mismatch artifact title"
        assert faq_en["title"] == en_file_title, f"round {round_id} en manifest title mismatch artifact title"


def _assert_raises(fn, expected_substring: str) -> None:
    try:
        fn()
    except AssertionError as ex:
        assert expected_substring in str(ex), f"Expected error containing '{expected_substring}', got '{ex}'"
        return
    raise AssertionError(f"Expected AssertionError containing '{expected_substring}', but no error was raised")


def _negative_selftests() -> None:
    base_path = ROOT / "agent-policy-canary-rollout-selection-faq.md"
    base_text = base_path.read_text(encoding="utf-8")
    expected = FAQ_CONTRACTS[base_path.name]

    # 1) wrong cycle reference should fail
    bad_cycle = base_text.replace("cycle-416-benchmark.json", "cycle-415-benchmark.json", 1)
    _assert_raises(
        lambda: _validate_single_faq_text(bad_cycle, base_path.name, expected),
        "cycle reference mismatch",
    )

    # 2) missing key reference should fail
    bad_key = base_text.replace("percentage_contract.slo_gate_blast_spread_rate", "percentage_contract.missing_key", 1)
    _assert_raises(
        lambda: _validate_single_faq_text(bad_key, base_path.name, expected),
        "contract-key set mismatch",
    )

    # 3) missing section heading should fail
    bad_section = base_text.replace("## 6) 生产 Checklist（是否可上线）", "## 7) 生产 Checklist（是否可上线）", 1)
    _assert_raises(
        lambda: _validate_single_faq_text(bad_section, base_path.name, expected),
        "complete section 1..6 headings",
    )

    # 4) wrong decimal should fail
    benchmark = json.loads((ROOT / "evidence" / "cycle-416-benchmark.json").read_text(encoding="utf-8"))
    row = dict(benchmark["percentage_contract"]["policy_gate_false_positive_trigger_rate"])
    row["percentage"] = 7.6  # should be 7.5
    _assert_raises(
        lambda: _validate_contract_row(416, "policy_gate_false_positive_trigger_rate", row),
        "percentage mismatch",
    )


def _validate_single_faq_text(text: str, name: str, expected: dict) -> None:
    _assert_six_part_shape(text)
    assert _title_from_md_text(text) == expected["title"], f"{name} title mismatch"
    cycle = _extract_cycle_from_faq(text)
    assert cycle == expected["cycle"], f"{name} cycle reference mismatch: expected {expected['cycle']}, got {cycle}"
    keys = _extract_contract_keys_from_faq(text)
    assert keys == expected["keys"], f"{name} contract-key set mismatch"


def main() -> None:
    for fname, expected in FAQ_CONTRACTS.items():
        _validate_single_faq(ROOT / fname, expected)

    for cycle in (416, 417, 418):
        _check_source_timestamp_quality(cycle)
    _check_manifest_semantics()
    _negative_selftests()
    print("round39_quality: PASS (faq->cycle/key binding + exact math + semantic classification + source chronology + negative selftests)")


if __name__ == "__main__":
    main()
