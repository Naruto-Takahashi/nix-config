import { Grid, ActionPanel, Action, showToast, Toast, closeMainWindow, Icon, open } from "@raycast/api";
import { useEffect, useState } from "react";
import fs from "fs";
import path from "path";
import os from "os";
import { exec } from "child_process";

const WALLPAPER_DIR =
  process.env.MATUGEN_WALLPAPER_DIR || path.join(os.homedir(), "Pictures", "Wallpapers");
const EXTS = new Set([".png", ".jpg", ".jpeg", ".webp", ".heic", ".bmp"]);

interface Wallpaper {
  name: string;
  path: string;
}

export default function Command() {
  const [wallpapers, setWallpapers] = useState<Wallpaper[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    try {
      if (fs.existsSync(WALLPAPER_DIR)) {
        const files = fs.readdirSync(WALLPAPER_DIR);
        const list = files
          .filter((f) => EXTS.has(path.extname(f).toLowerCase()))
          .map((f) => ({
            name: f,
            path: path.join(WALLPAPER_DIR, f),
          }))
          .sort((a, b) => a.name.localeCompare(b.name));
        setWallpapers(list);
      }
    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  }, []);

  async function applyWallpaper(wp: Wallpaper) {
    try {
      await showToast({ style: Toast.Style.Animated, title: "壁紙と配色を反映中..." });
      await closeMainWindow();

      const osa = `tell application "System Events" to tell every desktop to set picture to (POSIX file "${wp.path.replace(/"/g, '\\"')}")`;
      const applyScript = path.join(os.homedir(), ".local/bin/matugen-apply");

      exec(`osascript -e '${osa}' && "${applyScript}" "${wp.path}"`, (err, stdout, stderr) => {
        if (err) {
          showToast({
            style: Toast.Style.Failure,
            title: "反映に失敗しました",
            message: stderr || err.message,
          });
        } else {
          showToast({
            style: Toast.Style.Success,
            title: "壁紙と配色を適用しました",
            message: wp.name,
          });
        }
      });
    } catch (e) {
      console.error(e);
    }
  }

  return (
    <Grid
      isLoading={isLoading}
      columns={3}
      fit={Grid.Fit.Fill}
      aspectRatio="16/9"
      searchBarPlaceholder="壁紙を検索..."
    >
      <Grid.EmptyView
        icon={Icon.Image}
        title="壁紙が見つかりません"
        description={`${WALLPAPER_DIR} に画像（jpg/png/webp）を配置してください`}
        actions={
          <ActionPanel>
            <Action title="壁紙フォルダを開く" icon={Icon.Finder} onAction={() => open(WALLPAPER_DIR)} />
          </ActionPanel>
        }
      />
      {wallpapers.map((wp) => (
        <Grid.Item
          key={wp.path}
          content={{ source: wp.path }}
          title={wp.name}
          actions={
            <ActionPanel>
              <Action title="壁紙と配色を適用" icon={Icon.CheckCircle} onAction={() => applyWallpaper(wp)} />
              <Action.ShowInFinder path={wp.path} />
              <Action title="壁紙フォルダを開く" icon={Icon.Finder} onAction={() => open(WALLPAPER_DIR)} />
            </ActionPanel>
          }
        />
      ))}
    </Grid>
  );
}
