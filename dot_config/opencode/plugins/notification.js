// OpenCode通知プラグイン
// ユーザーの操作が必要な時に、プラットフォーム固有の通知を送信
export const NotificationPlugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  // プラットフォーム固有の通知を送信
  const sendNotification = async (title, message) => {
    if (process.platform === "linux") {
      // Linux: notify-send で通知してから paplay で音を鳴らす
      await $`notify-send ${title} ${message}`;
      await $`paplay /usr/share/sounds/freedesktop/stereo/complete.oga`;
    } else if (process.platform === "win32") {
      // Windows: システムサウンドで音を鳴らす
      // Windowsのトースト通知は実装が複雑そうなので未対応
      await $`powershell -NoProfile -Command "(New-Object Media.SoundPlayer 'C:\\Windows\\Media\\notify.wav').PlaySync()"`;
    }
    // その他のプラットフォームは何もしない
  };

  // プラグインのハンドラーオブジェクトを返す
  return {
    // イベントハンドラー: エージェントが許可を求めたとき、返信が終わったとき
    event: async ({ event }) => {
      if (event.type === "permission.asked") {
        await sendNotification("OpenCode", "Approval needed");
      } else if (event.type === "session.idle") {
        await sendNotification("OpenCode", "Reply completed");
      }
    },
    // ツール実行前のハンドラー: questionツールを実行したとき
    "tool.execute.before": async (input, output) => {
      if (input.tool === "question") {
        await sendNotification("OpenCode", "Please answer");
      }
    },
  };
};
