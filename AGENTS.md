# AGENTS.md

macOS用の個人dotfilesリポジトリ。`~/.config/dotfiles` にcloneし、`link.sh` がホームディレクトリへのシンボリックリンクを作成する。

## コミット規約

Conventional Commits + 日本語の体言止め。`.fish/functions/aicommit.fish`(`aicommit` 関数)が生成するメッセージと同じ規約。

- タイプ: `feat:` `fix:` `chore:` `refactor:` など
- 件名は日本語の体言止め(「〜を追加」「〜に変更」「〜の解消」)。「する/した/している」で終わらない

例:

```
feat: herdrのタブ移動にprefix+p / prefix+nを追加割り当て
fix: Codexモデル指定の非推奨設定解消
chore: gitconfigにrerereを有効化
```

## フォーマット

設定ファイルを変更したら整形を実行する。

```sh
mise run format
```

## 注意事項

- 各ファイルはホームディレクトリからシンボリックリンクされているため、**変更は即座に実環境へ反映される**
- ファイルの追加・移動・リネーム時は `link.sh` のマッピング更新と再実行(`sh link.sh`)が必要(`.fish/` 配下は再帰リンクのためマッピング更新は不要、ただし追加時は `link.sh` の再実行が必要)
- 設定ファイル内のコメントは日本語で書く(既存スタイルに合わせる)
- `link.sh` は [setup-my-osx](https://github.com/u1aryz/setup-my-osx) のマシンセットアップから呼ばれるため、リネーム・移動時はそちらの更新が必要
