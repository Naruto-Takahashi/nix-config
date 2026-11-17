# =========================================================================
# Mac mini (常時稼働機) 用 Home Manager 設定
# =========================================================================
# 通常の Mac 構成 (hosts/mac) に、メール秘書の定期実行 (launchd) を加えたもの。
# 二重通知を避けるため、メール秘書の `run --apply` はこのマシンだけで動かす。
# 秘書のコードは公開リポジトリ (mail-secretary)。個人の基準・ラベル名はここで上書きする。
{ config, mail-secretary, ... }:

{
  imports = [
    ../mac
    mail-secretary.homeManagerModules.default
  ];

  services.mailSecretary = {
    enable = true;
    interval = 600; # 10 分おき

    # 秘密情報 (gmail/ と discord/ を含む) は Git 管理外の Vault に置く
    dataDir = "${config.home.homeDirectory}/ghq/github.com/Naruto-Takahashi/obsidian-vault/90-local/91-private";

    # 個人用の設定 (リポジトリ同梱の既定値への上書き)
    settings = {
      triage = {
        hints = [
          "ユーザーは大学院生で、就職活動・研究・開発をしている。"
          "iCloud / Apple の「ストレージ容量が上限」系の通知は頻繁に届くため、重要度は ignore にする。"
          "クレジットカード会社(楽天カード・PayPayカード・オリコ等)の「不正利用の確認」「緊急のご連絡」は、利用が多いときに実際に届く。urgent にする。"
          "イベント(connpass 等)の参加募集の締切通知は、締切が近くても action 止まりにする。"
          "Discord のメールアドレス確認・認証コード・アカウント変更通知は、本人操作の確認用なので info にする。"
        ];

        # 旧ラベル (送信元で付いていたもの) を、新しい名前に改名する
        legacy = {
          rename = {
            "重要度/1_緊急" = "P0";
            "重要度/2_要対応" = "P1";
            "重要度/3_参考" = "P2";
            "01_重要/決済・明細" = "決済";
            "02_就活・大学" = "大学";
            "03_開発/GitHub" = "開発";
            "04_プロモ/ショッピング" = "広告";
            "05_SNS・娯楽" = "SNS";
          };
          old_kind_labels = [
            "01_重要/決済・明細"
            "02_就活・大学"
            "03_開発/GitHub"
            "04_プロモ/ショッピング"
            "05_SNS・娯楽"
          ];
        };

        # 既存メールへのラベル付け (backfill) で、AI を呼ばずに広告・SNS 扱いにするラベル
        backfill.rule_ignore_labels = [
          "広告"
          "SNS"
        ];
      };

      filters = {
        github.label = "開発";
        # 送信元だけで付けていたフィルタ (同じ送信元の広告まで、同じラベルで受信トレイに残っていた) を削除する
        remove.labels = [
          "決済"
          "大学"
        ];
      };
    };
  };
}
