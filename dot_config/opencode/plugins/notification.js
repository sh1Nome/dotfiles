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
    await $`printf "\e]777;notify;%s;%s\e\\" "${title}" "${message}"`;
    if (process.platform === "linux") {
      await $`paplay /usr/share/sounds/freedesktop/stereo/complete.oga`;
    }
  };

  /**
   * セッションの最新メッセージを取得し、最初の行を返す
   * メッセージが200文字を超える場合は省略され、見つからない場合または エラー時はデフォルトメッセージを返す
   * @param {string} sessionID - セッションID
   * @returns {Promise<string>} メッセージの最初の行（最大200文字）、見つからない場合は "No message"、取得失敗時は "Failed to get message"
   */
  const getLatestMessage = async (sessionID) => {
    try {
      const messages = await client.session.messages({
        path: { id: sessionID },
      });

      if (messages.data?.length > 0) {
        // 最後のメッセージを取得
        const lastMessage = messages.data[messages.data.length - 1];

        if (lastMessage.info?.role === "assistant") {
          const textPart = lastMessage.parts?.find((p) => p.type === "text");
          const text = textPart?.text;
          if (text) {
            const result =
              text.length > 200 ? text.substring(0, 200) + "..." : text;

            const firstLine = result.split("\n")[0];

            return firstLine;
          }
        }
      }

      return "No message";
    } catch (error) {
      return "Failed to get message";
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
      if (event.type === "permission.asked" || event.type === "session.idle") {
        const message = await getLatestMessage(event.properties.sessionID);

        await sendNotification("OpenCode", message);
      }
    },
  };
};
