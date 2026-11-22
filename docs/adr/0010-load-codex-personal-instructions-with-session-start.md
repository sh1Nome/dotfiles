# codex-personal の個人ルールを SessionStart フックで読み込む

## Status

Accepted

## Context

個人ルールは共有テンプレート `.chezmoitemplates/AGENTS.md` で管理する。  
従来は `codex-personal` の `agent-context` で配布していた。  
この sandbox では、起動時に読む `AGENTS.md` に別ファイルへの参照だけが載っていた。  
Codex は worktree の作成依頼を受けたとき、その別ファイルにある配置先のルールを読み落とした。  
[ADR 0008]

sbx は、同じ構成で `agent-context@1` と `@2` の両方を選ぶと合成を拒否する。  
現行仕様では、`@2` で本文を直接展開するには  
`delivery: inline` の指定と対応する sbx が必要になる。  
[agent-context@2 の仕様] · [sbx の実装に関する Issue]

生成された `AGENTS.md` に追記する方法では、kit と sbx が同じファイルを更新する。  
`developer_instructions` には、Codex の設定で固定文を指定できる。  
pstack はこの環境ですでに `SessionStart` フックを使って指示を渡している。

Codex は `/etc/codex/hooks.json` をシステムのフック設定として読む。  
複数の kit が同じパスにファイルを配置すると、配置が競合する。  
ユーザー設定やプラグインに登録したフックは、ユーザーが信頼するまで実行されない。  
[フックの探索先] · [Codex のフックの信頼設定]

## Decision

`codex-personal` に共有テンプレートの展開結果と `SessionStart` の定義を同梱する。  
kit のインストール時に `/etc/codex/hooks.json` を読み、  
既存の項目の順序を保って自分の定義を追加する。  
自分の定義がすでにあれば、その位置で更新する。  
フックは同梱した本文を読み、`additionalContext` として Codex に渡す。  
`codex-personal` の `agent-context` 宣言は削除する。  
[Codex のフック仕様]

## Consequences

- ほかの kit が使う `agent-context` のバージョンは、個人ルールの配布方法に影響しない。
- Codex はこのシステムフックを管理対象として読み込み、ユーザー設定や pstack のフックも併用できる。  
  管理対象のフックは個別の信頼操作が不要で、ユーザーのフック一覧から個別に無効化することはできない。  
  [Codex のフックの信頼設定]
- フックはセッションの開始時や再開時、コンテキスト圧縮後などに個人ルールを渡す。  
  Codex は本文を開発者コンテキストとして扱う。  
  ルールを読み込むには `SessionStart` が実行される必要がある。
- 別の kit があとから `/etc/codex/hooks.json` を上書きすると、登録したフックも消える。

[ADR 0008]: 0008-place-personal-instructions-in-user-global-ai-profiles.md
[agent-context@2 の仕様]:
  https://redirect.github.com/docker/sandbox-kit-spec/blob/main/docs/spec/capabilities/com.docker.sandbox/agent-context%402.md
[sbx の実装に関する Issue]: https://redirect.github.com/docker/sbx-releases/issues/878
[フックの探索先]: https://developers.openai.com/codex/hooks#where-codex-looks-for-hooks
[Codex のフック仕様]: https://developers.openai.com/codex/hooks#sessionstart
[Codex のフックの信頼設定]:
  https://developers.openai.com/codex/hooks#review-and-trust-hooks
