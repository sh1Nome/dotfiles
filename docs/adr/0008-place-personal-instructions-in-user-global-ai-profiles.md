# sbx の個人の応答スタイルは kit の files でユーザーグローバルの CLAUDE.md / AGENTS.md に置く

## Status

Accepted

## Context

共有テンプレート `.chezmoitemplates/AGENTS.md` の応答スタイルを、sbx サンドボックス内の Claude Code と Codex に常時適用したい。

kit の `agentInstructions` を `kind: mixin` で使うと、sbx は内容を別ファイル `kits-memory/<kit名>.md` に書く。  
本体には「関連するときだけ読め」という参照指示しか入らない。

Claude Code は起動時に、作業ディレクトリ（cwd）から親ディレクトリを `/` の手前までさかのぼり、途中の各 `CLAUDE.md` を読む。  
さらに、ユーザー全体の設定として `~/.claude/CLAUDE.md` を cwd に関係なく常に読む。  
Codex は cwd から親ディレクトリをたどって `.git` のあるディレクトリ（プロジェクトルート）を探し、そこから cwd までの各 `AGENTS.md` を読む。プロジェクトルートより上は読まない。  
ユーザー全体の設定は `$CODEX_HOME/AGENTS.md`（既定 `~/.codex/AGENTS.md`）から別途読む。  
sbx は AI プロファイルを作業リポジトリの1つ上に生成するが、そこは Codex の探索範囲の外にあたる。  
両者の読み込み範囲は実際の動作で確認しただけで、仕様かどうかは明確ではない。

確認した環境では `~/.claude/CLAUDE.md` も `~/.codex/AGENTS.md` も存在せず、sbx はこの2パスを管理していない。  
sbx はサンドボックスの生成時に、kit の `files/home/` 以下を `/home/agent/` へ配置する。

## Decision

応答スタイルの配布には `agentInstructions` も `setup.startup` も使わず、kit の `files/` 静的ツリーだけを使う。

- `claude-personal/files/home/dot_claude/CLAUDE.md.tmpl` を `/home/agent/.claude/CLAUDE.md` に置く
- `codex-personal/files/home/dot_codex/AGENTS.md.tmpl` を `/home/agent/.codex/AGENTS.md` に置く

各ファイルは共有テンプレートを展開し、末尾に `## このサンドボックスについて` を付ける。

## Consequences

- kit の変更は `files/` に2ファイル追加するだけで、spec.yaml を変更しない
- Claude Code と Codex の両方が、cwd に関係なく共有テンプレートの応答スタイルを適用する
- sbx が作業リポジトリの1つ上に置くファイルとは独立で、競合しない
- `files/` の静的配置はサンドボックスの生成時に1回だけ行うため、ファイルが消えても再生成しない
- spec.yaml から `files/` を参照しないため、spec だけを見た人は個人設定の配布に気付きにくい
- `CODEX_HOME` を変更した場合や `~/.codex/AGENTS.override.md` を作成した場合、sbx がこの2パスを管理し始めた場合は、この構成が無効になったり設定が競合したりする
