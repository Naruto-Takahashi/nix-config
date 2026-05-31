# =========================================================================
# Starship プロンプト設定モジュール
# =========================================================================
{ config, ... }:

{
  # Starship プロンプトの有効化
  programs.starship = {
    enable = true;
  };

  # アップロードされた starship.toml の設定をここに完全内包して自動生成
  xdg.configFile."starship.toml".text = ''
    # Starship performance optimizations for WSL
    scan_timeout = 20
    command_timeout = 500

    format = """
    $directory\
    [ ](fg:#ffc20d bg:#333333)\
    $git_branch\
    $git_status\
    [ ](fg:#333333)\
    \n$character\
    """

    right_format = """$cmd_duration$username $time"""

    add_newline = true

    [username]
    style_user = "white bold"
    style_root = "black bold"
    format = "user: [$user]($style) "
    disabled = false

    [fill]
    symbol = ' '

    [directory]
    style = "fg:#000000 bg:#ffc20d bold"
    truncation_length = 10
    truncate_to_repo = false
    truncation_symbol = "…/"
    read_only = ' 󰌾 '
    read_only_style = 'fg:#000000 bg:#ffc20d'
    format = '[ $path ]($style)[$read_only]($read_only_style)'

    [directory.substitutions]
    "Documents" = "󰈙 "
    "Downloads" = " "
    "Music" = " "
    "Pictures" = " "

    [aws]
    disabled = true
    [gcloud]
    disabled = true

    [git_branch]
    symbol = ""
    style = "bg:#333333"
    format = '[[ $symbol $branch ](fg:#ffc20d bg:#333333)]($style)'

    [git_status]
    style = "bg:#333333"
    format = '[[($all_status$ahead_behind )](fg:#ffc20d bg:#333333)]($style)'

    [cmd_duration]
    min_time = 1
    style = 'fg:#b48ead'
    format = "[[  ](fg:#a0a9cb) $duration]($style)"

    [time]
    disabled = false
    time_format = "%R"
    format = '[[   $time ](fg:#a0a9cb)]($style)'

    [character]
    success_symbol = "[❯](bold #ffc20d)"
    error_symbol = "[❯](bold #ffc20d)"
    vicmd_symbol = "[❯](bold #8e8e8e)"
  '';
}
