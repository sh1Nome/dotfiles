# sbx の個人の応答スタイルは kit の files でユーザーグローバルの CLAUDE.md / AGENTS.md に置く

## Status

Accepted

## Context

共有テンプレート `.chezmoitemplates/AGENTS.md` の応答スタイルを、sbx サンドボックス内の Claude Code と Codex に常時適用したい。

kit の `agentInstructions` を `kind: mixin` で使っても、内容は別ファイル `kits-memory/<kit名>.md` に書かれ、  
本体には「関連するときだけ読め」というポインタしか入らない。

Claude Code は cwd から親ディレクトリを `/` の手前までさかのぼり、途中の各 `CLAUDE.md` を起動時に読む。  
さらに `~/.claude/CLAUDE.md` をユーザーグローバルとして cwd に関係なく常に読む。  
Codex は cwd から `.git` のあるディレクトリ（プロジェクトルート）を上に探し、  
そこから cwd までの各 `AGENTS.md` を読む。ルートより上は読まない。  
グローバルは `$CODEX_HOME/AGENTS.md`（既定 `~/.codex/AGENTS.md`）を別枠で読む。  
sbx は AI プロファイルを作業リポジトリの1つ上に生成するが、そこは Codex の探索範囲の外にあたる。  
どちらも動作上で確認しただけで、仕様かどうかは明確ではない。

実測では `~/.claude/CLAUDE.md` も `~/.codex/AGENTS.md` も存在せず、sbx はこの2パスを管理していない。  
kit の `files/home/` 以下は、サンドボックス生成時に `/home/agent/` へ配置される。

## Decision

応答スタイルの配布には `agentInstructions` も `setup.startup` も使わず、kit の `files/` 静的ツリーだけを使う。

- `claude-personal/files/home/dot_claude/CLAUDE.md.tmpl` を `/home/agent/.claude/CLAUDE.md` に置く
- `codex-personal/files/home/dot_codex/AGENTS.md.tmpl` を `/home/agent/.codex/AGENTS.md` に置く

各ファイルは共有テンプレートを展開し、末尾に `## このサンドボックスについて` を付ける。

## Consequences

- kit の変更は `files/` に2ファイル追加するだけで、spec.yaml を変更しない
- 共有テンプレートの応答スタイルが、cwd に関係なく Claude Code と Codex の両方に適用される
- sbx が作業リポジトリの1つ上に置くファイルとは独立で、競合しない
- `files/` 静的配置は生成時の1回だけで、ファイルが消えても再生成しない
- spec.yaml から `files/` を参照しないため、spec だけを見た人は個人設定の配布に気付きにくい
- `CODEX_HOME` 変更や `~/.codex/AGENTS.override.md` の出現、sbx がこの2パスを管理し始めた場合に無効化・衝突する
