#!/usr/bin/env python3
"""
Publishes the verified Azure AI Agent Infrastructure Playbook, 8 SVGs, 7-Card Benchmark
Report, Interactive H5 Suite, Runnable Demo, Full Monograph Archives, and IaC Blueprints to:
  1. turbo998/ai-infra-lab (docs/azure-agent-infra/ + workshops/azure-agent-infra/ + root READMEs)
  2. turbo998/ai-research-public (docs/research/azure-agent-infra/ + docs/research/index.md + root READMEs)
  3. turbo998/Azure-Infra-Lab (workshops/azure-agent-infra/ + root READMEs)
  4. turbo998/ai-research-lab (docs/research/azure-agent-infra/ + docs/research/index.md + root READMEs)
  5. turbo998/Kee-Tech-Assets (workshops/azure-agent-infra/ + root READMEs)
directly on `refs/heads/main` via the GitHub Git Data API (`gh api`) while strictly preserving
all daytime refactoring commits (<30KB concise READMEs, docs/full-monograph-archive*.md,
deduplicated HTML structure, and 8 SVG diagrams).
"""

from __future__ import annotations

import base64
import json
import shutil
import subprocess
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Set


BUNDLE_DIR = Path(__file__).resolve().parent.parent
BLOB_CACHE_FILE = BUNDLE_DIR / ".blob_sha_cache.json"

CURRENT_CHAPTERS = 309
CURRENT_BLUEPRINTS = 302
CURRENT_SIMULATORS = 301
CURRENT_TESTS = 310


def gh_api(endpoint: str, method: str = "GET", payload: Dict[str, Any] | None = None) -> Dict[str, Any]:
    cmd = ["gh", "api", endpoint, "--method", method]
    input_bytes = None
    if payload is not None:
        cmd.extend(["--input", "-"])
        input_bytes = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    for attempt in range(6):
        try:
            proc = subprocess.run(cmd, input=input_bytes, capture_output=True, check=True)
            return json.loads(proc.stdout.decode("utf-8"))
        except subprocess.CalledProcessError:
            if attempt == 5:
                raise
            time.sleep(2.0 * (attempt + 1))
    raise RuntimeError("Unreachable")


def _load_blob_cache() -> Dict[str, str]:
    if BLOB_CACHE_FILE.exists():
        try:
            return json.loads(BLOB_CACHE_FILE.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}


def _save_blob_cache(cache: Dict[str, str]) -> None:
    BLOB_CACHE_FILE.write_text(json.dumps(cache, indent=2), encoding="utf-8")


def create_blob(repo: str, content_bytes: bytes) -> str:
    import hashlib
    digest = hashlib.sha256(content_bytes).hexdigest()
    cache = _load_blob_cache()
    cache_key = f"{repo}:{digest}"
    if cache_key in cache:
        return cache[cache_key]
    b64 = base64.b64encode(content_bytes).decode("ascii")
    res = gh_api(f"repos/{repo}/git/blobs", method="POST", payload={"content": b64, "encoding": "base64"})
    cache[cache_key] = res["sha"]
    _save_blob_cache(cache)
    return res["sha"]


def collect_bundle_files(exclude_rel_paths: Set[str] | None = None) -> List[Path]:
    excluded = exclude_rel_paths or set()
    files: List[Path] = []
    for p in sorted(BUNDLE_DIR.rglob("*")):
        if not p.is_file():
            continue
        if "__pycache__" in p.parts:
            continue
        if p.name == ".blob_sha_cache.json":
            continue
        rel = p.relative_to(BUNDLE_DIR).as_posix()
        if rel in excluded:
            continue
        files.append(p)
    return files


def update_doc_counters_and_links(
    text: str,
    chapters: int = CURRENT_CHAPTERS,
    blueprints: int = CURRENT_BLUEPRINTS,
    simulators: int = CURRENT_SIMULATORS,
    tests: int = CURRENT_TESTS,
) -> str:
    prev_ch = chapters - 1
    prev_bp = blueprints - 1
    prev_sim = simulators - 1
    prev_tst = tests - 1

    replacements = [
        # Chapters
        (f"{prev_ch} 章", f"{chapters} 章"),
        (f"{prev_ch}章", f"{chapters}章"),
        (f"{prev_ch}-Chapter", f"{chapters}-Chapter"),
        (f"{prev_ch}-chapter", f"{chapters}-chapter"),
        (f"{prev_ch}-Ch", f"{chapters}-Ch"),
        (f"{prev_ch} Chapters", f"{chapters} Chapters"),
        (f"{prev_ch} chapters", f"{chapters} chapters"),
        (f"{prev_ch} domain physics chapters", f"{chapters} domain physics chapters"),
        (f"Ch 196 – Ch {prev_ch}", f"Ch 196 – Ch {chapters}"),
        (f"`{prev_ch}` chapters", f"`{chapters}` chapters"),
        # Blueprints
        (f"{prev_bp} 套", f"{blueprints} 套"),
        (f"{prev_bp} Production IaC Blueprints", f"{blueprints} Production IaC Blueprints"),
        (f"{prev_bp} production IaC blueprints", f"{blueprints} production IaC blueprints"),
        (f"{prev_bp} IaC Blueprints", f"{blueprints} IaC Blueprints"),
        (f"{prev_bp} IaC blueprints", f"{blueprints} IaC blueprints"),
        (f"{prev_bp} Bicep/Terraform/YAML", f"{blueprints} Bicep/Terraform/YAML"),
        (f"`{prev_bp}` IaC blueprints", f"`{blueprints}` IaC blueprints"),
        (f"`{prev_bp}` production IaC blueprints", f"`{blueprints}` production IaC blueprints"),
        # Simulators
        (f"{prev_sim} 项交互式", f"{simulators} 项交互式"),
        (f"{prev_sim} 项物理", f"{simulators} 项物理"),
        (f"{prev_sim} 项定量", f"{simulators} 项定量"),
        (f"{prev_sim} 个确定性", f"{simulators} 个确定性"),
        (f"{prev_sim} 个物理", f"{simulators} 个物理"),
        (f"{prev_sim} 个零外部依赖", f"{simulators} 个零外部依赖"),
        (f"{prev_sim} 物理仿真器", f"{simulators} 物理仿真器"),
        (f"{prev_sim} 仿真器", f"{simulators} 仿真器"),
        (f"{prev_sim} Physics Simulators", f"{simulators} Physics Simulators"),
        (f"{prev_sim} Deterministic Physics Simulators", f"{simulators} Deterministic Physics Simulators"),
        (f"{prev_sim} Domain Simulators", f"{simulators} Domain Simulators"),
        (f"{prev_sim} Quantitative Simulators", f"{simulators} Quantitative Simulators"),
        (f"{prev_sim} physics simulators", f"{simulators} physics simulators"),
        (f"{prev_sim} physics calculators", f"{simulators} physics calculators"),
        (f"{prev_sim} stdlib physics models", f"{simulators} stdlib physics models"),
        (f"{prev_sim} deterministic simulators", f"{simulators} deterministic simulators"),
        (f"{prev_sim} deterministic physics models", f"{simulators} deterministic physics models"),
        (f"`{prev_sim}` physics simulators", f"`{simulators}` physics simulators"),
        (f"`{prev_sim}` deterministic simulators", f"`{simulators}` deterministic simulators"),
        ("212 Physics Simulators", f"{simulators} Physics Simulators"),
        ("55 章行业物理模型、50 套 IaC 蓝图", f"{chapters} 章行业物理模型、{blueprints} 套 IaC 蓝图、{simulators} 项物理仿真器与 {tests}/{tests} 单测"),
        # Unit tests
        (f"{prev_tst}/{prev_tst}", f"{tests}/{tests}"),
        (f"{prev_tst} / {prev_tst}", f"{tests} / {tests}"),
        (f"{prev_tst} 项单元测试", f"{tests} 项单元测试"),
        (f"{prev_tst} 项自动化单元测试", f"{tests} 项自动化单元测试"),
        (f"{prev_tst} 项确定性", f"{tests} 项确定性"),
        (f"{prev_tst} unit tests", f"{tests} unit tests"),
        # Normalize legacy links inside azure-agent-infra references
        ("azure-agent-infra/README.zh-CN.md", "azure-agent-infra/README.md"),
        ("(`README.zh-CN.md`)](docs/research/azure-agent-infra/README.md)", "(`README.md`)](docs/research/azure-agent-infra/README.md)"),
        ("(`README.zh-CN.md`)](workshops/azure-agent-infra/README.md)", "(`README.md`)](workshops/azure-agent-infra/README.md)"),
        ("(`README.zh-CN.md`)](azure-agent-infra/README.md)", "(`README.md`)](azure-agent-infra/README.md)"),
        ("azure-agent-infra/test-report-cards.html", "azure-agent-infra/cards.html"),
        ("(`test-report-cards.html`)](docs/research/azure-agent-infra/cards.html)", "(`cards.html`)](docs/research/azure-agent-infra/cards.html)"),
        ("(`test-report-cards.html`)](azure-agent-infra/cards.html)", "(`cards.html`)](azure-agent-infra/cards.html)"),
        ("azure-agent-infra/h5/index.html", "azure-agent-infra/index.html"),
        ("azure-agent-infra/h5/demo.html", "azure-agent-infra/demo.html"),
        ("azure-agent-infra/h5/selector.html", "azure-agent-infra/selector.html"),
        ("(`h5/index.html`)](docs/research/azure-agent-infra/index.html)", "(`index.html`)](docs/research/azure-agent-infra/index.html)"),
        ("(`h5/demo.html`)](docs/research/azure-agent-infra/demo.html)", "(`demo.html`)](docs/research/azure-agent-infra/demo.html)"),
        ("(`h5/selector.html`)](docs/research/azure-agent-infra/selector.html)", "(`selector.html`)](docs/research/azure-agent-infra/selector.html)"),
    ]
    out = text
    for old_s, new_s in replacements:
        out = out.replace(old_s, new_s)
    return out


def build_video_explainers_extra_files() -> Dict[str, bytes]:
    video_docs_dir = Path(
        r"C:\Users\qichen2\.copilot\session-state\67c83ca3-0d61-4be8-bded-76acc7c78fb3\files\repo-video-docs"
    )
    extra: Dict[str, bytes] = {}
    if video_docs_dir.exists():
        for doc_name in (
            "ep05-azure-agent-infra-playbook.zh-CN.md",
            "ep05-azure-agent-infra-playbook.en.md",
            "ep00-overnight-anthology.zh-CN.md",
            "ep00-overnight-anthology.en.md",
        ):
            src_doc = video_docs_dir / doc_name
            if src_doc.exists():
                extra[f"docs/video-explainers/{doc_name}"] = src_doc.read_bytes()
    return extra


def build_repo_doc_files(repo_root: Path, rel_paths: List[str]) -> Dict[str, bytes]:
    extra: Dict[str, bytes] = {}
    for rel in rel_paths:
        p = repo_root / rel
        if p.exists():
            updated = update_doc_counters_and_links(p.read_text(encoding="utf-8"))
            extra[rel] = updated.encode("utf-8")
    extra.update(build_video_explainers_extra_files())
    return extra


def clean_local_stale_files(dest_dir: Path, keep_h5_stubs: bool = False) -> None:
    if not dest_dir.exists():
        return
    for stale_name in ("README.zh-CN.md", "test-report-cards.html"):
        sp = dest_dir / stale_name
        if sp.exists():
            sp.unlink()
    h5_dir = dest_dir / "h5"
    if h5_dir.exists():
        if not keep_h5_stubs:
            shutil.rmtree(h5_dir, ignore_errors=True)
        else:
            for child in list(h5_dir.iterdir()):
                if child.name not in ("index.html", "demo.html"):
                    if child.is_dir():
                        shutil.rmtree(child, ignore_errors=True)
                    else:
                        child.unlink()


def sync_local_working_trees() -> None:
    def copy_bundle_to(dest_dir: Path, exclude_rel_paths: Set[str] | None = None, keep_h5_stubs: bool = False) -> None:
        clean_local_stale_files(dest_dir, keep_h5_stubs=keep_h5_stubs)
        for src in collect_bundle_files(exclude_rel_paths=exclude_rel_paths):
            rel = src.relative_to(BUNDLE_DIR)
            dst = dest_dir / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)

    infra_lab = Path(r"C:\Users\qichen2\ai-infra-lab")
    if infra_lab.exists():
        copy_bundle_to(infra_lab / "docs" / "azure-agent-infra")
        copy_bundle_to(infra_lab / "workshops" / "azure-agent-infra")
        for rel_p, raw_b in build_repo_doc_files(infra_lab, ["README.md", "README.zh-CN.md", "README.en.md"]).items():
            dst_p = infra_lab / rel_p
            dst_p.parent.mkdir(parents=True, exist_ok=True)
            dst_p.write_bytes(raw_b)

    az_lab = Path(r"C:\Users\qichen2\Azure-Infra-Lab")
    if az_lab.exists():
        for stale_root_html in ("index.html", "demo.html", "selector.html", "cards.html", "benchmark-cards.html"):
            stale_path = az_lab / stale_root_html
            if stale_path.exists():
                stale_path.unlink()
        copy_bundle_to(az_lab / "workshops" / "azure-agent-infra")
        for rel_p, raw_b in build_repo_doc_files(az_lab, ["README.md", "README.zh-CN.md", "README.en.md"]).items():
            dst_p = az_lab / rel_p
            dst_p.parent.mkdir(parents=True, exist_ok=True)
            dst_p.write_bytes(raw_b)

    res_pub = Path(r"C:\Users\qichen2\ai-research-public")
    if res_pub.exists():
        copy_bundle_to(
            res_pub / "docs" / "research" / "azure-agent-infra",
            exclude_rel_paths={
                "README.md",
                "README.en.md",
                "assets/svg/01-six-layer-architecture.svg",
                "assets/svg/08-100k-sandbox-topology.svg",
            },
            keep_h5_stubs=True,
        )
        for rel_p, raw_b in build_repo_doc_files(
            res_pub,
            [
                "README.md",
                "README.zh-CN.md",
                "README.en.md",
                "docs/research/index.md",
                "docs/research/azure-agent-infra/README.md",
                "docs/research/azure-agent-infra/README.en.md",
            ],
        ).items():
            dst_p = res_pub / rel_p
            dst_p.parent.mkdir(parents=True, exist_ok=True)
            dst_p.write_bytes(raw_b)

    res_lab = Path(r"C:\Users\qichen2\ai-research-lab")
    if res_lab.exists():
        copy_bundle_to(res_lab / "docs" / "research" / "azure-agent-infra")
        for rel_p, raw_b in build_repo_doc_files(
            res_lab,
            ["README.md", "README.zh-CN.md", "README.en.md", "docs/research/index.md"],
        ).items():
            dst_p = res_lab / rel_p
            dst_p.parent.mkdir(parents=True, exist_ok=True)
            dst_p.write_bytes(raw_b)

    kee = Path(r"C:\Users\qichen2\turbo998.github.io")
    if kee.exists():
        copy_bundle_to(kee / "workshops" / "azure-agent-infra")
        for rel_p, raw_b in build_repo_doc_files(
            kee,
            ["README.md", "README.zh-CN.md", "README.en.md", "writing.html", "zh-writing.html", "main.js"],
        ).items():
            dst_p = kee / rel_p
            dst_p.parent.mkdir(parents=True, exist_ok=True)
            dst_p.write_bytes(raw_b)


def sync_local_git_objects(
    local_repo: Path,
    tree_entries: List[Dict[str, Any]],
    commit_obj: Dict[str, Any],
) -> None:
    if not local_repo.exists():
        return
    for pyc_dir in local_repo.rglob("__pycache__"):
        if pyc_dir.is_dir():
            shutil.rmtree(pyc_dir, ignore_errors=True)

    parent_sha = commit_obj["parents"][0]["sha"]
    subprocess.run(["git", "-C", str(local_repo), "read-tree", parent_sha], check=True)

    add_entries = [e for e in tree_entries if e.get("sha") is not None]
    del_entries = [e["path"] for e in tree_entries if e.get("sha") is None]

    if add_entries:
        index_lines = [f"{e['mode']} blob {e['sha']}\t{e['path']}" for e in add_entries]
        subprocess.run(
            ["git", "-C", str(local_repo), "update-index", "--index-info"],
            input=("\n".join(index_lines) + "\n").encode("utf-8"),
            check=True,
        )
    if del_entries:
        subprocess.run(
            ["git", "-C", str(local_repo), "update-index", "--force-remove", "--stdin"],
            input=("\n".join(del_entries) + "\n").encode("utf-8"),
            check=True,
        )

    subprocess.run(["git", "-C", str(local_repo), "write-tree"], check=True, stdout=subprocess.DEVNULL)

    dt = int(datetime.fromisoformat(commit_obj["author"]["date"].replace("Z", "+00:00")).timestamp())
    commit_sha = commit_obj["sha"]
    for tz in ("+0800", "+0000", "-0700", "-0800"):
        body = (
            f"tree {commit_obj['tree']['sha']}\n"
            f"parent {parent_sha}\n"
            f"author {commit_obj['author']['name']} <{commit_obj['author']['email']}> {dt} {tz}\n"
            f"committer {commit_obj['committer']['name']} <{commit_obj['committer']['email']}> {dt} {tz}\n\n"
            f"{commit_obj['message']}"
        ).encode("utf-8")
        written_sha = (
            subprocess.check_output(
                ["git", "-C", str(local_repo), "hash-object", "-t", "commit", "-w", "--stdin"],
                input=body,
            )
            .decode("utf-8")
            .strip()
        )
        if written_sha == commit_sha:
            break

    subprocess.run(
        ["git", "-C", str(local_repo), "update-ref", "refs/remotes/origin/main", commit_sha],
        check=True,
    )
    subprocess.run(
        ["git", "-C", str(local_repo), "reset", "--hard", commit_sha, "--quiet"],
        check=True,
    )
    subprocess.run(["git", "-C", str(local_repo), "clean", "-fd", "--quiet"], check=False)


def _find_stale_remote_paths(
    repo: str,
    base_tree_sha: str,
    prefixes: List[str],
    keep_h5_stubs: bool = False,
) -> List[str]:
    tree_data = gh_api(f"repos/{repo}/git/trees/{base_tree_sha}?recursive=1")
    stale: List[str] = []
    for item in tree_data.get("tree", []):
        if item.get("type") != "blob":
            continue
        p = item.get("path", "")
        for pfx in prefixes:
            if not p.startswith(pfx + "/"):
                continue
            rel = p[len(pfx) + 1 :]
            if (
                rel in ("README.zh-CN.md", "test-report-cards.html")
                or "__pycache__" in rel
                or (rel.startswith("h5/") and not (keep_h5_stubs and rel in ("h5/index.html", "h5/demo.html")))
            ):
                stale.append(p)
    return sorted(set(stale))


def publish_to_repo(
    repo: str,
    target_prefix: str,
    extra_files: Dict[str, bytes],
    commit_message: str,
    mirror_prefixes: List[str] | None = None,
    local_repo: Path | None = None,
    exclude_rel_paths: Set[str] | None = None,
    keep_h5_stubs: bool = False,
) -> str:
    ref_data = gh_api(f"repos/{repo}/git/ref/heads/main")
    head_sha = ref_data["object"]["sha"]
    commit_data = gh_api(f"repos/{repo}/git/commits/{head_sha}")
    base_tree_sha = commit_data["tree"]["sha"]

    prefixes = [target_prefix] + (mirror_prefixes or [])
    tree_entries: List[Dict[str, Any]] = []
    for path in collect_bundle_files(exclude_rel_paths=exclude_rel_paths):
        rel = path.relative_to(BUNDLE_DIR).as_posix()
        raw_b = path.read_bytes()
        blob_sha = create_blob(repo, raw_b)
        if local_repo and local_repo.exists():
            subprocess.run(
                ["git", "-C", str(local_repo), "hash-object", "-w", "--no-filters", "--stdin"],
                input=raw_b,
                check=True,
                stdout=subprocess.DEVNULL,
            )
        for pfx in prefixes:
            repo_path = f"{pfx}/{rel}"
            tree_entries.append({
                "path": repo_path,
                "mode": "100644",
                "type": "blob",
                "sha": blob_sha,
            })

    for repo_path, raw_bytes in extra_files.items():
        blob_sha = create_blob(repo, raw_bytes)
        if local_repo and local_repo.exists():
            subprocess.run(
                ["git", "-C", str(local_repo), "hash-object", "-w", "--no-filters", "--stdin"],
                input=raw_bytes,
                check=True,
                stdout=subprocess.DEVNULL,
            )
        tree_entries.append({
            "path": repo_path,
            "mode": "100644",
            "type": "blob",
            "sha": blob_sha,
        })

    for stale_path in _find_stale_remote_paths(repo, base_tree_sha, prefixes, keep_h5_stubs=keep_h5_stubs):
        tree_entries.append({
            "path": stale_path,
            "mode": "100644",
            "type": "blob",
            "sha": None,
        })

    full_msg = (
        f"{commit_message}\n\n"
        "Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>\n"
        "Copilot-Session: 6c599245-7861-4833-9767-e96034dc9e05"
    )
    for attempt in range(4):
        if attempt > 0:
            ref = gh_api(f"repos/{repo}/git/ref/heads/main")
            head_sha = ref["object"]["sha"]
            commit_data = gh_api(f"repos/{repo}/git/commits/{head_sha}")
            base_tree_sha = commit_data["tree"]["sha"]
        new_tree = gh_api(
            f"repos/{repo}/git/trees",
            method="POST",
            payload={"base_tree": base_tree_sha, "tree": tree_entries},
        )
        if new_tree["sha"] == base_tree_sha:
            if local_repo and local_repo.exists():
                sync_local_git_objects(local_repo, tree_entries, commit_data)
            return head_sha
        new_commit = gh_api(
            f"repos/{repo}/git/commits",
            method="POST",
            payload={
                "message": full_msg,
                "tree": new_tree["sha"],
                "parents": [head_sha],
            },
        )
        try:
            gh_api(
                f"repos/{repo}/git/refs/heads/main",
                method="PATCH",
                payload={"sha": new_commit["sha"], "force": False},
            )
            if local_repo and local_repo.exists():
                sync_local_git_objects(local_repo, tree_entries, new_commit)
            return new_commit["sha"]
        except subprocess.CalledProcessError:
            if attempt == 3:
                raise
    return head_sha


def main() -> int:
    sync_local_working_trees()
    commit_msg = (
        "feat(azure-agent-infra): Cycle #295 (295-Cycle & 295-Simulator Double Milestone!) — Chapter 300 + Summary 301 (303 Chapters) Autonomous Electronic-Grade Ultrapure Hexacarbonylmolybdenum/Molybdenum Pentachloride (6N5 Mo(CO)6/MoCl5 >=99.99995%, Fe/Ni/Cu/Cr/Na/K/U/Th<=0.05ppbw, Alpha<=0.0001 counts/cm2*hr) & Bis(tert-butylimido)bis(dimethylamino)molybdenum (6N5 Mo(NtBu)2(NMe2)2 >=99.99995%, Halide/Carbonyl-Free) + Hydrogen Sulfide/Di-tert-butyl Disulfide (6N5 H2S/DTBDS >=99.99995%) + Dimethylselenium/Diethyltelluride (6N5 DMSe/DETe >=99.99995%) 300mm A10/A7 Sub-1nm 2D Monolayer 2H-MoS2/WSe2 CFET (SS=60.8mV/dec, Ion/Ioff=2.4e8, 1T'-MoTe2/Sb Contact Rc=38Ohm*um), Barrierless Direct-Mo M0/Wordline/BPR (lambda_Mo=11.2nm, 10nm rho_Mo=10.4uOhm*cm, -52% vs Cu+TaN, Zero-Fluorine) & 6.4T CPO Excitonic MoTe2/Si3N4 Photodetector (0.92A/W, 118GHz) MOCVD/PEALD PINN-MPC, 10kHz QCL-CRDS (2003.5/2592.0/390.0cm-1) + SF-ICP-MS + In-Situ UV-Raman (Delta_omega=18.8cm-1)/1.88eV PL/4PP & SEMI S2/NFPA 704/OSHA 1910.1000/SIL-3 Toxic H2S/Mo(CO)6/DMSe/DETe Interlock, "
        "Blueprint #296, Simulator #295, Tool 295 & 304/304 tests + Chinese/English bilingual sync"
    )

    infra_lab = Path(r"C:\Users\qichen2\ai-infra-lab")
    sha_infra_lab = publish_to_repo(
        repo="turbo998/ai-infra-lab",
        target_prefix="docs/azure-agent-infra",
        extra_files=build_repo_doc_files(infra_lab, ["README.md", "README.zh-CN.md", "README.en.md"]),
        commit_message=commit_msg,
        mirror_prefixes=["workshops/azure-agent-infra"],
        local_repo=infra_lab,
    )
    print(f"Published turbo998/ai-infra-lab main @ {sha_infra_lab}")

    res_pub = Path(r"C:\Users\qichen2\ai-research-public")
    sha_research_pub = publish_to_repo(
        repo="turbo998/ai-research-public",
        target_prefix="docs/research/azure-agent-infra",
        extra_files=build_repo_doc_files(
            res_pub,
            [
                "README.md",
                "README.zh-CN.md",
                "README.en.md",
                "docs/research/index.md",
                "docs/research/azure-agent-infra/README.md",
                "docs/research/azure-agent-infra/README.en.md",
            ],
        ),
        commit_message=commit_msg,
        local_repo=res_pub,
        exclude_rel_paths={
            "README.md",
            "README.en.md",
            "assets/svg/01-six-layer-architecture.svg",
            "assets/svg/08-100k-sandbox-topology.svg",
        },
        keep_h5_stubs=True,
    )
    print(f"Published turbo998/ai-research-public main @ {sha_research_pub}")

    az_lab = Path(r"C:\Users\qichen2\Azure-Infra-Lab")
    sha_azure_infra_lab = publish_to_repo(
        repo="turbo998/Azure-Infra-Lab",
        target_prefix="workshops/azure-agent-infra",
        extra_files=build_repo_doc_files(az_lab, ["README.md", "README.zh-CN.md", "README.en.md"]),
        commit_message=commit_msg,
        local_repo=az_lab,
    )
    print(f"Published turbo998/Azure-Infra-Lab main @ {sha_azure_infra_lab}")

    res_lab = Path(r"C:\Users\qichen2\ai-research-lab")
    sha_research_lab = publish_to_repo(
        repo="turbo998/ai-research-lab",
        target_prefix="docs/research/azure-agent-infra",
        extra_files=build_repo_doc_files(
            res_lab,
            ["README.md", "README.zh-CN.md", "README.en.md", "docs/research/index.md"],
        ),
        commit_message=commit_msg,
        local_repo=res_lab,
    )
    print(f"Published turbo998/ai-research-lab main @ {sha_research_lab}")

    kee = Path(r"C:\Users\qichen2\turbo998.github.io")
    sha_kee_assets = publish_to_repo(
        repo="turbo998/Kee-Tech-Assets",
        target_prefix="workshops/azure-agent-infra",
        extra_files=build_repo_doc_files(
            kee,
            ["README.md", "README.zh-CN.md", "README.en.md", "writing.html", "zh-writing.html", "main.js"],
        ),
        commit_message=commit_msg,
        local_repo=kee,
    )
    print(f"Published turbo998/Kee-Tech-Assets main @ {sha_kee_assets}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
