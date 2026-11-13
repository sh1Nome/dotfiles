import { execFile } from "node:child_process";
import { promisify } from "node:util";

const run = promisify(execFile);

/**
 * 指定したコメントとその子孫の ID を、子孫から先に返す。
 * @param {object[]} notes レビュー内のコメント
 * @param {string} rootId 親コメントの ID
 * @returns {string[]} 削除順に並べたコメントの ID
 */
function descendants(notes, rootId) {
  const children = new Map();
  for (const note of notes) {
    if (!note.parentId) continue;
    const siblings = children.get(note.parentId) ?? [];
    siblings.push(note.id);
    children.set(note.parentId, siblings);
  }
  const result = [];
  /**
   * 子コメントを再帰的にたどり、訪問した ID を追加する。
   * @param {string} id 訪問するコメントの ID
   * @returns {void}
   */
  const visit = (id) => {
    for (const child of children.get(id) ?? []) visit(child);
    result.push(id);
  };
  visit(rootId);
  return result;
}

/**
 * スレッドの親コメントから一覧の選択肢を作る。
 * @param {object} snapshot レビューの状態
 * @returns {object[]} スレッドの ID と表示文を持つ選択肢
 */
function threadChoices(snapshot) {
  return snapshot.notes
    .filter((note) => !note.parentId)
    .map((note, index) => {
      const replies = descendants(snapshot.notes, note.id).length - 1;
      const file = snapshot.files.find((entry) => entry.fileKey === note.fileKey);
      if (!file || !note.anchor.preferred) throw new Error("Thread has no file or line");
      const line = note.anchor.preferred.line;
      const summary = note.summary.replace(/\s+/g, " ").trim();
      return {
        id: note.id,
        label: `${index + 1}. ${file.path}:${line} — ${summary} (${replies} replies)`,
      };
    });
}

/**
 * 現在のプロセスに対応する Hunk セッションの ID を返す。
 * @returns {Promise<string>} セッションの ID
 */
async function sessionId() {
  const { stdout } = await run("hunk", ["session", "list", "--json"]);
  const sessions = JSON.parse(stdout).sessions.filter((session) => session.pid === process.pid);
  if (sessions.length !== 1) throw new Error("Cannot identify the current Hunk session");
  return sessions[0].sessionId;
}

/**
 * レビューの世代とコメントが想定どおりか確認する。
 * @param {object} ctx 拡張機能の実行コンテキスト
 * @param {object} snapshot 比較するレビューの状態
 * @param {object[]} expectedNotes 想定するコメント
 * @returns {boolean} 世代とコメントが一致すれば true
 */
function currentSnapshot(ctx, snapshot, expectedNotes) {
  const current = ctx.review.snapshot();
  return current?.generation === snapshot.generation &&
    JSON.stringify(current.notes) === JSON.stringify(expectedNotes);
}

/**
 * 指定したコメントのコード上の位置へ移動する。
 * @param {object} ctx 拡張機能の実行コンテキスト
 * @param {object} snapshot 選択時のレビューの状態
 * @param {string} noteId 移動先のコメントの ID
 * @returns {void}
 */
function navigate(ctx, snapshot, noteId) {
  const current = ctx.review.snapshot();
  if (!current || current.generation !== snapshot.generation) {
    ctx.notify("Review changed; open the thread list again", "warning");
    return;
  }
  const note = current.notes.find((entry) => entry.id === noteId);
  const file = note && current.files.find((entry) => entry.fileKey === note.fileKey);
  if (!note || note.resolution === "orphaned" || !file || !note.anchor.preferred) {
    ctx.notify("This thread has no current location", "warning");
    return;
  }
  ctx.navigation.revealLine(file.runtimeId, note.anchor.preferred.side, note.anchor.preferred.line);
}

/**
 * 確認後、スレッド内のコメントを子孫から順に削除する。
 * @param {object} ctx 拡張機能の実行コンテキスト
 * @param {object} snapshot 選択時のレビューの状態
 * @param {string} noteId 削除するスレッドの親コメントの ID
 * @returns {Promise<void>} 削除操作の完了
 */
async function removeThread(ctx, snapshot, noteId) {
  const ids = descendants(snapshot.notes, noteId);
  const confirmed = await ctx.dialogs.confirm({
    title: "Delete thread?",
    body: `Delete ${ids.length} comments, including all replies.`,
    confirmLabel: "Delete",
  });
  if (!confirmed) return;

  let removed = 0;
  try {
    const session = await sessionId();
    let remaining = snapshot.notes;
    for (const id of ids) {
      if (!currentSnapshot(ctx, snapshot, remaining)) {
        throw new Error("Review changed during deletion");
      }
      await run("hunk", ["session", "comment", "rm", session, id, "--json"]);
      remaining = remaining.filter((note) => note.id !== id);
      removed += 1;
    }
    ctx.notify(`Deleted ${removed} comments`);
  } catch (error) {
    ctx.notify(`Deleted ${removed} of ${ids.length} comments: ${error.message}`, "warning");
  }
}

/**
 * コメントスレッドの一覧を開くコマンドを登録する。
 * @param {object} hunk Hunk の拡張機能 API
 * @returns {void}
 */
export default function registerThreads(hunk) {
  hunk.registerCommand({ id: "list", title: "Comment threads", key: "C" }, async (ctx) => {
    const snapshot = ctx.review.snapshot();
    if (!snapshot) return;
    const choices = threadChoices(snapshot);
    if (choices.length === 0) {
      ctx.notify("No comment threads");
      return;
    }
    const selected = await ctx.dialogs.select({
      title: "Comment threads",
      options: choices.map((choice) => choice.label),
    });
    if (selected === null) return;
    const index = Number(/^(\d+)\./.exec(selected)?.[1]) - 1;
    const choice = choices[index];
    if (!choice) return;
    const action = await ctx.dialogs.select({ title: choice.label, options: ["Go to comment", "Delete thread"] });
    if (action === "Go to comment") navigate(ctx, snapshot, choice.id);
    if (action === "Delete thread") await removeThread(ctx, snapshot, choice.id);
  });
}
