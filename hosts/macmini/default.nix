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
        rubric = ''
          あなたは大学院生(就活・研究・開発をしている個人)のメール秘書です。
          各メールの重要度を次の4段階で判定してください。
          - urgent: 期限が近い連絡(24〜48時間以内)、決済・セキュリティの異常、人から個人宛で返事待ちのもの
          - action: 対応が要るが急ぎではないもの(GitHub のレビュー依頼・アサイン、大学や就活の提出物・案内、研究室連絡)
          - info: 読めばよいだけの通知(決済完了・配送連絡・CI 結果など)
          - ignore: プロモーション・メルマガ・SNS 通知・自動配信
        '';
        hints = [
          "iCloud / Apple の「ストレージ容量が上限」系の通知は頻繁に届くため、重要度は ignore にする。"
          "クレジットカード会社(楽天カード・PayPayカード・オリコ等)の「不正利用の確認」「緊急のご連絡」は、利用が多いときに実際に届く。urgent にする。"
          "イベント(connpass 等)の参加募集の締切通知は、締切が近くても action 止まりにする。"
          "Discord のメールアドレス確認・認証コード・アカウント変更通知は、本人操作の確認用なので info にする。"
        ];
        # 既存フィルタが「受信トレイに残す」と決めているラベルは、AI 判定でも外さない
        organize.protected_labels = [
          "01_重要/決済・明細"
          "02_就活・大学"
        ];
        # 既存メールへのラベル付け (backfill) で、AI を呼ばずに「無視」にするラベル
        backfill.rule_ignore_labels = [
          "04_プロモ/ショッピング"
          "05_SNS・娯楽"
        ];
      };
      filters.github.label = "03_開発/GitHub";
    };
  };
}
