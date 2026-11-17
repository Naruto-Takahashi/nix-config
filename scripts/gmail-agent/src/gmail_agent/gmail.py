"""Gmail API の薄いラッパー。"""

from __future__ import annotations

import time

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

from .config import CREDENTIALS, TOKEN

SCOPES = [
    "https://www.googleapis.com/auth/gmail.settings.basic",  # フィルタ
    "https://www.googleapis.com/auth/gmail.modify",  # ラベル・メッセージ
]


def get_service():
    creds = None
    if TOKEN.exists():
        creds = Credentials.from_authorized_user_file(TOKEN, SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            creds = InstalledAppFlow.from_client_secrets_file(CREDENTIALS, SCOPES).run_local_server(port=0)
        TOKEN.write_text(creds.to_json())
        TOKEN.chmod(0o600)
    return build("gmail", "v1", credentials=creds, cache_discovery=False)


def label_names(svc) -> dict[str, str]:
    """labelId -> 名前"""
    labels = svc.users().labels().list(userId="me").execute().get("labels", [])
    return {label["id"]: label["name"] for label in labels}


def label_ids(svc) -> dict[str, str]:
    """名前 -> labelId"""
    return {n: i for i, n in label_names(svc).items()}


def ensure_label(svc, name: str, ids: dict[str, str]) -> str:
    if name not in ids:
        ids[name] = svc.users().labels().create(userId="me", body={"name": name}).execute()["id"]
    return ids[name]


def header(msg: dict, name: str) -> str:
    for h in msg.get("payload", {}).get("headers", []):
        if h["name"].lower() == name.lower():
            return h["value"]
    return ""


def list_ids(svc, q: str, limit: int) -> list[str]:
    ids: list[str] = []
    token = None
    while len(ids) < limit:
        r = svc.users().messages().list(userId="me", q=q, maxResults=min(100, limit), pageToken=token).execute()
        ids += [m["id"] for m in r.get("messages", [])]
        token = r.get("nextPageToken")
        if not token:
            break
    return ids[:limit]


def fetch_recent(svc, hours: int, limit: int) -> list[dict]:
    """直近 hours 時間のメール(新しい順)。本文は取らず、件名・差出人・スニペットだけ。"""
    names = label_names(svc)
    days = max(1, -(-hours // 24))
    q = f"newer_than:{days}d -in:trash -in:spam -in:sent -in:drafts"
    cutoff_ms = (time.time() - hours * 3600) * 1000
    out = []
    for mid in list_ids(svc, q, limit):
        m = svc.users().messages().get(
            userId="me", id=mid, format="metadata", metadataHeaders=["From", "Subject", "Date"]
        ).execute()
        if int(m["internalDate"]) < cutoff_ms:
            continue
        out.append(
            {
                "id": mid,
                "threadId": m.get("threadId", mid),
                "from": header(m, "From"),
                "subject": header(m, "Subject"),
                "date": header(m, "Date"),
                "snippet": (m.get("snippet") or "")[:200],
                "labels": [
                    names.get(i, i) for i in m.get("labelIds", []) if not i.startswith(("CATEGORY_", "UNREAD", "IMPORTANT"))
                ],
            }
        )
    return out


def batch_modify(svc, ids: list[str], add: list[str], remove: list[str]) -> None:
    body: dict = {}
    if add:
        body["addLabelIds"] = add
    if remove:
        body["removeLabelIds"] = remove
    if not body:
        return
    for i in range(0, len(ids), 1000):
        svc.users().messages().batchModify(userId="me", body={**body, "ids": ids[i : i + 1000]}).execute()
