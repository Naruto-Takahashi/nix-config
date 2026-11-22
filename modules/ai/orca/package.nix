# =========================================================================
# Orca IDE (デスクトップアプリ) パッケージ定義
# =========================================================================
{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "orca-ide";
  version = "1.4.241";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-yDsa+OP8b4+tg8DE0P2XucI16S46HWPpDJhrAY9gnUo=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/orca-ide.desktop $out/share/applications/orca-ide.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/orca-ide.png \
      $out/share/icons/hicolor/512x512/apps/orca-ide.png
    substituteInPlace $out/share/applications/orca-ide.desktop \
      --replace-fail 'Exec=AppRun' "Exec=$out/bin/orca-ide"
  '';

  meta = with lib; {
    description = "Next-gen IDE for parallel agentic development";
    homepage = "https://github.com/stablyai/orca";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "orca-ide";
  };
}
