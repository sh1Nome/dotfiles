/**
 * ユーザーの操作が必要な時にプラットフォーム固有の通知を送信するプラグイン
 * @param {Object} params
 * @param {Object} params.project - プロジェクト情報
 * @param {Object} params.client - OpenCode SDK クライアント
 * @param {Function} params.$ - Bun shell API
 * @param {string} params.directory - 現在の作業ディレクトリ
 * @param {string} params.worktree - Git ワークツリーパス
 * @returns {Promise<Object>} プラグインハンドラーオブジェクト
 */
export const NotificationPlugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  /**
   * プラットフォーム固有の通知を送信
   * @param {string} title - 通知のタイトル
   * @param {string} message - 通知のメッセージ
   * @returns {Promise<void>}
   */
  const sendNotification = async (title, message) => {
    await $`printf "\e]777;notify;%s;%s\e\\" ${title} ${message}`;
    if (process.platform === "linux") {
      await $`paplay /usr/share/sounds/freedesktop/stereo/complete.oga`;
    }
  };

  return {
    /**
     * イベント発生時のハンドラー
     * @param {Object} params
     * @param {Object} params.event - イベントオブジェクト
     * @param {string} params.event.type - イベントの種類
     * @returns {Promise<void>}
     */
    event: async ({ event }) => {
      if (event.type === "permission.asked") {
        await sendNotification("OpenCode", "Approval needed");
      } else if (event.type === "session.idle") {
        await sendNotification("OpenCode", "Reply completed");
      }
    },
  };
};
