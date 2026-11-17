"""判定結果の Gmail への反映 (重要度ラベルの付与と、受信トレイからの整理)。"""

from __future__ import annotations

import json
import time

from .config import ORGANIZE_LOG, load
from .gmail import batch_modify, ensure_label, get_service, label_ids, label_names, list_ids


def plan(mails: list[dict], res: dict[str, dict]) -> list[dict]:
    cfg = load("triage")
    protected = set(cfg["organize"]["protected_labels"])
    archive_levels = set(cfg["organize"]["archive_levels"])
    out = []
    for m in mails:
        r = res.get(m["id"])
        if not r:
            continue
        lv = r["level"]
        is_protected = bool(protected & set(m["labels"])) or "STARRED" in m["labels"]
        out.append(
            {
                "id": m["id"],
                "level": lv,
                "label": cfg["labels"].get(lv, ""),
                "archive": lv in archive_levels and not is_protected and "INBOX" in m["labels"],
                "protected": is_protected and lv in archive_levels,
            }
        )
    return out


def apply(svc, items: list[dict]) -> None:
    ids = label_ids(svc)
    groups: dict[tuple[str, bool], list[str]] = {}
    for p in items:
        groups.setdefault((p["label"], p["archive"]), []).append(p["id"])
    for (label, archive), mids in groups.items():
        add = [ensure_label(svc, label, ids)] if label else []
        batch_modify(svc, mids, add, ["INBOX"] if archive else [])
        with ORGANIZE_LOG.open("a") as f:
            for mid in mids:
                f.write(json.dumps({"t": int(time.time()), "id": mid, "label": label, "archived": archive}) + "\n")
    if ORGANIZE_LOG.exists():
        ORGANIZE_LOG.chmod(0o600)


def cmd_migrate_labels(args) -> None:
    """旧ラベル (AI/…) を新しい名前に移行する。"""
    svc = get_service()
    legacy = load("triage")["legacy"]
    ids = label_ids(svc)
    for old, new in legacy["rename"].items():
        if old not in ids:
            print(f"スキップ: {old} は存在しません")
        elif new in ids:
            print(f"要確認: {new} が既にあるため {old} を改名できません")
        else:
            print(f"改名: {old} -> {new}" + ("" if args.yes else " (dry-run)"))
            if args.yes:
                svc.users().labels().patch(userId="me", id=ids[old], body={"name": new}).execute()
    for old in legacy["delete"]:
        if old not in ids:
            print(f"スキップ: {old} は存在しません")
            continue
        mids = list_ids(svc, f'label:"{old}"', 100000)
        print(f"削除: {old} (メール {len(mids)} 通からラベルを外してからラベルを削除。メールは消えません)" + ("" if args.yes else " (dry-run)"))
        if args.yes:
            batch_modify(svc, mids, [], [ids[old]])
            svc.users().labels().delete(userId="me", id=ids[old]).execute()
    names = label_names(svc)
    print("現在の重要度ラベル:", sorted(n for n in names.values() if n.startswith(("重要度/", "AI/"))))
