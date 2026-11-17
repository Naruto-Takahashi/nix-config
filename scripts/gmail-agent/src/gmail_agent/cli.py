from __future__ import annotations

import argparse

from . import filters, organize
from .gmail import get_service
from .notify import cmd_run
from .triage import LEVEL_JA, classify, is_sensitive


def cmd_auth(_a) -> None:
    prof = get_service().users().getProfile(userId="me").execute()
    print(f"認可OK: {prof['emailAddress']}")


def cmd_triage(a) -> None:
    """判定結果を一覧表示するだけ (メールは変更しない。通知もしない)。"""
    from .gmail import fetch_recent

    mails = fetch_recent(get_service(), a.hours, a.limit)
    res = classify(mails, a.model)
    order = {k: i for i, k in enumerate(LEVEL_JA)}
    for m in sorted(mails, key=lambda m: order.get(res.get(m["id"], {}).get("level", "info"), 9)):
        r = res.get(m["id"])
        subj = "(認証コードの通知。件名は非表示)" if is_sensitive(m["subject"]) else m["subject"][:50]
        print(f"[{LEVEL_JA[r['level']] if r else '未判定'}] {m['from'][:30]:<30} | {subj}")
        if r:
            print(f"        └ {r['summary']} ／ {r['reason']}")


def main() -> int:
    p = argparse.ArgumentParser(prog="gmail-agent")
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("auth", help="初回認可").set_defaults(fn=cmd_auth)
    sub.add_parser("dump", help="既存フィルタの一覧").set_defaults(fn=filters.cmd_dump)

    fp = sub.add_parser("filters", help="フィルタ同期 (config/filters.toml)")
    fs = fp.add_subparsers(dest="sub", required=True)
    fs.add_parser("plan", help="差分の表示").set_defaults(fn=filters.cmd_plan)
    fa = fs.add_parser("apply", help="差分の適用")
    fa.add_argument("--yes", action="store_true")
    fa.set_defaults(fn=filters.cmd_apply)

    rp = sub.add_parser("restore-inbox", help="重要な GitHub 通知を受信トレイに戻す")
    rp.add_argument("--days", type=int, default=14)
    rp.add_argument("--include-read", action="store_true")
    rp.add_argument("--yes", action="store_true")
    rp.set_defaults(fn=filters.cmd_restore_inbox)

    mp = sub.add_parser("migrate-labels", help="旧ラベル (AI/…) の移行")
    mp.add_argument("--yes", action="store_true")
    mp.set_defaults(fn=organize.cmd_migrate_labels)

    tp = sub.add_parser("triage", help="直近のメールを判定して表示するだけ")
    tp.add_argument("--hours", type=int, default=48)
    tp.add_argument("--limit", type=int, default=30)
    tp.add_argument("--model", default=None)
    tp.set_defaults(fn=cmd_triage)

    up = sub.add_parser("run", help="定期実行の本体 (判定・整理・通知)。--apply なしは dry-run")
    up.add_argument("--apply", action="store_true", help="実際に Gmail を変更し、Discord に投稿し、状態を保存する")
    up.add_argument("--hours", type=int, default=None, help="遡る時間 (既定: config/notify.toml)")
    up.add_argument("--ignore-seen", action="store_true", help="処理済みのメールも対象にする")
    up.add_argument("--digest-now", action="store_true", help="時刻に関係なく要対応のまとめを今送る")
    up.set_defaults(fn=cmd_run)

    args = p.parse_args()
    args.fn(args)
    return 0
