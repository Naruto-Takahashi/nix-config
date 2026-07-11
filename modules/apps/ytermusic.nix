# =========================================================================
# ytermusic (TUI YouTube Music プレイヤー) 設定モジュール
# =========================================================================
# - 認証: ~/.config/ytermusic/headers.txt に music.youtube.com の Cookie を
#   手動で配置する (docs/ytermusic.md 参照)。リポジトリには含めない。
# - テーマ: config-template.toml の @@プレースホルダ@@ を yasb-theme が
#   matugen パレットで置換して config.toml を生成する (yazi と同じ方式)。
{ config, pkgs, ... }:

{
  # yt-dlp は ytermusic のダウンローダ (config の downloader = "ytdlp") が呼ぶ
  home.packages = [ pkgs.ytermusic pkgs.yt-dlp ];

  # WSL には ALSA デバイスが無いため、既定 PCM を WSLg の PulseAudio
  # (PULSE_SERVER=unix:/mnt/wslg/PulseServer) へブリッジする。
  # ytermusic (rodio/cpal) など ALSA 直叩きのアプリの音を Windows 側へ出す。
  home.file.".asoundrc".text = ''
    pcm_type.pulse {
      lib "${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_pulse.so"
    }
    ctl_type.pulse {
      lib "${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_ctl_pulse.so"
    }
    pcm.!default {
      type plug
      slave.pcm {
        type pulse
      }
    }
    ctl.!default {
      type pulse
    }
  '';

  xdg.configFile."ytermusic/config-template.toml".text = ''
    [global]
    parallel_downloads = 4
    downloader = "ytdlp"

    [player]
    initial_volume = 50
    dbus = true
    hide_channels_on_homepage = true
    hide_albums_on_homepage = false
    volume_slider = true
    shuffle = false

    # --- matugen パレット (yasb-theme が生成) ---
    # 再生中 = accent / 一時停止 = tertiary / 待機・次曲 = muted /
    # ダウンロード中 = secondary / 検索中 = complement / エラー = 赤系
    [player.gauge_playing_style]
    fg = "@@ACCENT@@"

    [player.gauge_paused_style]
    fg = "@@TERTIARY@@"

    [player.gauge_nomusic_style]
    fg = "@@MUTED@@"

    [player.text_playing_style]
    fg = "@@ACCENT@@"

    [player.text_paused_style]
    fg = "@@TERTIARY@@"

    [player.text_next_style]
    fg = "@@MUTED@@"

    [player.text_waiting_style]
    fg = "@@MUTED@@"

    [player.text_downloading_style]
    fg = "@@SECONDARY@@"

    [player.text_searching_style]
    fg = "@@COMPLEMENT@@"

    [player.text_error_style]
    fg = "#c4746e"
  '';
}
