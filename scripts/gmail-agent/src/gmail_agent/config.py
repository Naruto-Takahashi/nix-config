"""設定の読み込み。設定は config/*.toml、秘密情報は Git 管理外の Vault に置く。"""

from __future__ import annotations

import os
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONFIG_DIR = ROOT / "config"

_VAULT_PRIVATE = "~/ghq/github.com/Naruto-Takahashi/obsidian-vault/90-local/91-private"
SECRET_DIR = Path(os.environ.get("GMAIL_AGENT_DIR", f"{_VAULT_PRIVATE}/gmail")).expanduser()
DISCORD_ENV = Path(os.environ.get("DISCORD_ENV", f"{_VAULT_PRIVATE}/discord/bot.env")).expanduser()

CREDENTIALS = SECRET_DIR / "credentials.json"
TOKEN = SECRET_DIR / "token.json"
STATE = SECRET_DIR / "state.json"
ORGANIZE_LOG = SECRET_DIR / "organize-log.jsonl"

ACCOUNT = "broken.copycat@gmail.com"  # Gmail へのリンクで使う


def load(name: str) -> dict:
    return tomllib.loads((CONFIG_DIR / f"{name}.toml").read_text())


def load_env(path: Path) -> dict[str, str]:
    env: dict[str, str] = {}
    for line in path.read_text().splitlines():
        if "=" in line and not line.lstrip().startswith("#"):
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip()
    return env
