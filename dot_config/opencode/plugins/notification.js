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
    await $`printf "\e]777;notify;%s;%s\e\\" ${title} ${message}`;
    if (process.platform === "linux") {
      // Linux: notify-send で通知してから paplay で音を鳴らす
      await $`paplay /usr/share/sounds/freedesktop/stereo/complete.oga`;
    }
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
