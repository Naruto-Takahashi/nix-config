"""Gmail フィルタの同期 (config/filters.toml)。"""

from __future__ import annotations

import json
import sys

from .config import load
from .gmail import batch_modify, get_service, label_ids, label_names, list_ids


def github_rule() -> tuple[str, str, str]:
    cfg = load("filters")["github"]
    group = "{" + " ".join(f"cc:{n}@noreply.github.com" for n in cfg["important_cc"]) + "}"
    return cfg["label"], cfg["from"], group


def desired(label_id: str, sender: str, important: str) -> list[dict]:
    """(重要: INBOX に残す) と (その他: アーカイブ) の 2 本。"""
    return [
        {"criteria": {"from": sender, "query": important}, "action": {"addLabelIds": [label_id]}},
        {
            "criteria": {"from": sender, "query": "-" + important},
            "action": {"addLabelIds": [label_id], "removeLabelIds": ["INBOX"]},
        },
    ]


def norm(f: dict) -> str:
    action = {k: sorted(v) for k, v in f.get("action", {}).items()}
    return json.dumps({"criteria": f.get("criteria", {}), "action": action}, sort_keys=True, ensure_ascii=False)


def compute_plan(svc):
    label, sender, important = github_rule()
    label_id = label_ids(svc)[label]
    want = desired(label_id, sender, important)
    existing = svc.users().settings().filters().list(userId="me").execute().get("filter", [])
    managed = [f for f in existing if label_id in f.get("action", {}).get("addLabelIds", [])]
    have = {norm(f): f for f in managed}
    want_keys = {norm(f) for f in want}
    return label, [f for k, f in have.items() if k not in want_keys], [f for f in want if norm(f) not in have]


def cmd_dump(_args) -> None:
    svc = get_service()
    names = label_names(svc)
    filters = svc.users().settings().filters().list(userId="me").execute().get("filter", [])
    print(f"フィルタ {len(filters)} 件")
    for f in filters:
        act = f.get("action", {})
        add = [names.get(i, i) for i in act.get("addLabelIds", [])]
        rem = [names.get(i, i) for i in act.get("removeLabelIds", [])]
        print(f"- id={f['id']}\n    条件: {f.get('criteria', {})}\n    追加: {add} / 削除: {rem}")


def cmd_plan(_args) -> None:
    label, to_delete, to_create = compute_plan(get_service())
    print(f"対象ラベル: {label}")
    for f in to_delete:
        print(f"- 削除: {f['id']}  {f['criteria']}  action={f['action']}")
    for f in to_create:
        print(f"+ 作成: {f['criteria']}  action={f['action']}")
    if not to_delete and not to_create:
        print("差分なし")


def cmd_apply(args) -> None:
    if not args.yes:
        sys.exit("--yes が必要です (まず plan で差分を確認)")
    svc = get_service()
    _label, to_delete, to_create = compute_plan(svc)
    api = svc.users().settings().filters()
    for f in to_create:  # 作成を先に行い、途中で失敗しても通知が止まる期間を作らない
        api.create(userId="me", body=f).execute()
        print(f"作成: {f['criteria']}")
    for f in to_delete:
        api.delete(userId="me", id=f["id"]).execute()
        print(f"削除: {f['id']}")


def cmd_restore_inbox(args) -> None:
    """重要な GitHub 通知で受信トレイから外れたものを戻す。"""
    svc = get_service()
    label, sender, important = github_rule()
    unread = "" if args.include_read else "is:unread "
    q = f'label:"{label}" -in:inbox -in:trash -in:spam {unread}newer_than:{args.days}d from:{sender} {important}'
    ids = list_ids(svc, q, 100000)
    print(f"対象 {len(ids)} 件")
    if ids and args.yes:
        batch_modify(svc, ids, ["INBOX"], [])
        print("受信トレイに戻しました")
    elif ids:
        print("(dry-run: --yes で実行)")
