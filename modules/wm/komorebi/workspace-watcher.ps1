# komorebiのワークスペース切り替えイベントを検知し、auto_hide中のYASBバーを
# チラ見せする常駐スクリプト。komorebiのNamed Pipe購読機能(`subscribe-pipe`)
# でイベントをストリーミング受信し、ワークスペース変更系イベント
# (FocusWorkspaceNumber / FocusMonitorWorkspaceNumber / CycleFocusWorkspace)
# を検知したら `yasbc show-bar` を呼ぶ。
#
# 表示時間をこちらで制御する(hide-barを遅延実行する、マウスホバー中は
# 隠さない等)実装も試したが、YASB本体のAutoHideManager
# (src/core/bar_helper.py)がマウスがバー上にない限り表示完了から
# 600ms固定でhide_bar()を呼んでしまう仕様のため、こちら側のタイマーは
# 常に空振りになり無意味だった。設定で変更できる項目でもないため、
# 「ワークスペース切替時に一瞬だけ表示される」以上の制御は諦めている。
#
# komorebi再起動時にパイプが切れるため、切断を検知したら再接続するループにしている。

$komorebic = "C:\Program Files\komorebi\bin\komorebic.exe"
$yasbc = "C:\Program Files\YASB\yasbc.exe"
$pipeName = "yasb-workspace-watcher"

$workspaceChangeEvents = @(
    "FocusWorkspaceNumber",
    "FocusWorkspaceNumbers",
    "FocusMonitorWorkspaceNumber",
    "FocusNamedWorkspace",
    "CycleFocusWorkspace",
    "FocusLastWorkspace"
)

while ($true) {
    try {
        $pipe = New-Object System.IO.Pipes.NamedPipeServerStream($pipeName, [System.IO.Pipes.PipeDirection]::In)
        $subscribeJob = Start-Job -ScriptBlock {
            param($komorebicPath, $pipe)
            & $komorebicPath subscribe-pipe $pipe
        } -ArgumentList $komorebic, $pipeName

        $pipe.WaitForConnection()
        $reader = New-Object System.IO.StreamReader($pipe)

        while ($pipe.IsConnected) {
            $line = $reader.ReadLine()
            if ($null -eq $line) { break }
            try {
                $notification = $line | ConvertFrom-Json
                if ($workspaceChangeEvents -contains $notification.event.type) {
                    & $yasbc show-bar
                }
            } catch {
                # JSONパース失敗は無視して次のイベントを待つ
            }
        }
    } catch {
        Start-Sleep -Seconds 2
    } finally {
        if ($reader) { $reader.Dispose() }
        if ($pipe) { $pipe.Dispose() }
        if ($subscribeJob) { Remove-Job -Job $subscribeJob -Force -ErrorAction SilentlyContinue }
    }
    # komorebi再起動待ちなどで切断された場合、少し待って再購読する
    Start-Sleep -Seconds 2
}
