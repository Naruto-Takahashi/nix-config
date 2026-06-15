// =========================================================================
// Zebar Status Bar Utilities
// =========================================================================

/**
 * OSから取得した生のウィンドウ情報を元に、ステータスバーに表示する
 * スッキリとした短いウィンドウ名（タイトル）を抽出して返します。
 *
 * @param {Object} win - Zebarのプロバイダーから渡されるウィンドウオブジェクト
 * @returns {string} 整形されたウィンドウ名
 */
export const formatWindowTitle = (win) => {
  if (!win.title) {
    if (!win.processName) return "Window";
    const p = win.processName.toLowerCase();
    if (p === "wezterm-gui") return "WezTerm";
    if (p === "code") return "VS Code";
    return win.processName.charAt(0).toUpperCase() + win.processName.slice(1);
  }

  let t = win.title;

  // 1. 未読バッジの除去 (例: "(1) ", "[99+] ")
  t = t.replace(/^[\(\[]\d+[\+\*\!]?[\)\]]\s*/, '');

  // 2. 特殊なPWAやウェブアプリの「決め打ち」判定（これだけは残す）
  if (t.match(/gemini/i)) return "Google Gemini";

  // 3. 【汎用処理】セパレーターによる分割と抽出
  // 一般的な区切り文字（- , |, —, :）で分割する
  const parts = t.split(/\s+[-|—:]\s+/);
  
  if (parts.length > 1) {
    // パターンA: 最初の要素がアプリ名の場合（例: "Notion - ページ名", "Slack | チャンネル"）
    if (parts[0].length <= 20 && parts[0].match(/^[A-Za-z0-9\s]+$/)) {
      return parts[0];
    }
    
    // パターンB: 最後の要素がアプリ名・ブラウザ名の場合（例: "記事 - Wikipedia - Google Chrome"）
    // ユーザーが見たいのは「最初のコンテンツ名」なので、最後の要素（ブラウザ名等）を切り捨てる
    // 3つ以上区切られている場合でも、一番左の要素を優先する
    t = parts[0];
  }

  // 4. CLIツール等のプロセス名に基づくクリーンアップ
  const proc = win.processName ? win.processName.toLowerCase() : "";
  const cliTools = ['yazi', 'nvim', 'zsh', 'bash', 'fish', 'tmux', 'btop', 'htop', 'vim', 'lazygit'];
  
  for (const tool of cliTools) {
    if (proc.includes(tool) || t.toLowerCase().includes(tool)) {
      return tool.charAt(0).toUpperCase() + tool.slice(1);
    }
  }

  // 5. 最終的な文字数制限（長すぎる場合は末尾をカット）
  if (t.length > 25) {
    t = t.slice(0, 24) + '…';
  }

  return t;
};
