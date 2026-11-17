"""Discord への投稿 (ボットトークンは Vault の bot.env)。"""

from __future__ import annotations

import json
import re
import urllib.request

from .config import DISCORD_ENV, load_env


def md_escape(t: str) -> str:
    return re.sub(r"([*_`~|>\[\]])", r"\\\1", t)


def post(content: str, ping: bool = False) -> None:
    """ping=True のときだけ、本人(DISCORD_USER_ID)へのメンションを許可する。それ以外のメンションは常に無効。"""
    env = load_env(DISCORD_ENV)
    mentions: dict = {"parse": []}
    if ping:
        content = f"<@{env['DISCORD_USER_ID']}> {content}"
        mentions["users"] = [env["DISCORD_USER_ID"]]
    req = urllib.request.Request(
        f"https://discord.com/api/v10/channels/{env['DISCORD_CHANNEL_ID']}/messages",
        data=json.dumps({"content": content, "allowed_mentions": mentions, "flags": 4}).encode(),  # flags 4: リンク埋め込みを抑止
        headers={
            "Authorization": f"Bot {env['DISCORD_BOT_TOKEN']}",
            "Content-Type": "application/json",
            "User-Agent": "gmail-agent (nix-config, 0.2)",
        },
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        r.read()
