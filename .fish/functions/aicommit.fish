function aicommit -d "Generate and select AI-powered commit messages"
    # Parse arguments
    set -l lang en

    # Parse options
    for arg in $argv
        switch $arg
            case '--lang=*'
                set lang (string split -f2 "=" -- $arg)
            case -l
                set lang ja
            case -h --help
                echo "使い方: aicommit [オプション]"
                echo ""
                echo "AIを使用してConventional Commit形式のコミットメッセージを生成し、選択してコミットします。"
                echo ""
                echo "オプション:"
                echo "  --lang=LANG    コミットメッセージの言語を指定 (en または ja、デフォルト: en)"
                echo "  -l             日本語のコミットメッセージを生成 (--lang=ja の省略形)"
                echo "  -h, --help     このヘルプメッセージを表示"
                return 0
        end
    end

    # Check if there are staged changes
    set -l diff_output (git diff --cached 2>&1)
    set -l diff_status $status

    if test $diff_status -ne 0
        echo "エラー: gitリポジトリではないか、gitコマンドが失敗しました"
        return 1
    end

    if test -z "$diff_output"
        echo "ステージされた変更がありません。"
        return 0
    end

    # Get git status for context (only staged files)
    set -l git_status (git diff --cached --name-status)

    # Prepare prompt based on language
    set -l prompt
    if test "$lang" = ja
        set prompt "以下のgit diffとgit statusを分析して、Conventional Commits形式のコミットメッセージを3つ提案してください。

各メッセージは以下の形式に従ってください：
- type: subject の形式（scopeは不要）
- typeは feat, fix, docs, style, refactor, test, chore などから適切なものを選択
- subjectは変更内容を簡潔に表現（日本語で）
- subjectの最初の一文字は小文字または大文字のどちらでも可
- 各メッセージは1行で完結させる

git status:
$git_status

git diff:
$diff_output

出力形式：
1. <コミットメッセージ1>
2. <コミットメッセージ2>
3. <コミットメッセージ3>

上記の形式で、番号とメッセージのみを出力してください。説明は不要です。"
    else
        set prompt "Analyze the following git diff and git status, then suggest 3 conventional commit messages.

Each message should follow this format:
- type: subject format (no scope needed)
- type should be one of: feat, fix, docs, style, refactor, test, chore, etc.
- subject should concisely describe the changes (in English)
- Each message should be a single line

git status:
$git_status

git diff:
$diff_output

Output format:
1. <commit message 1>
2. <commit message 2>
3. <commit message 3>

Output only the numbered messages in the above format. No explanations needed."
    end

    # Call Claude to generate commit messages
    echo "コミットメッセージを生成中..."

    # Use a temporary file to pass the prompt to avoid quoting issues
    set -l prompt_file (mktemp)
    echo "$prompt" >$prompt_file
    set -l claude_output (claude -p <$prompt_file 2>&1)
    set -l claude_status $status
    rm -f $prompt_file

    if test $claude_status -ne 0
        echo "エラー: Claude CLIの呼び出しに失敗しました"
        echo "$claude_output"
        return 1
    end

    # Parse the output to extract commit messages
    set -l messages_file (mktemp)
    echo "$claude_output" | perl -pe 's/ (\d+)\. /\n$1. /g' | grep '^\d\.' | sed -E 's/^[0-9]+\. //' >$messages_file

    # Check if we found any messages
    set -l message_count (wc -l <$messages_file | string trim)
    if test "$message_count" -eq 0
        echo "エラー: Claudeの出力からコミットメッセージをパースできませんでした"
        echo "Claudeの出力:"
        echo "$claude_output"
        rm -f $messages_file
        return 1
    end

    # Let user select a message with fzf
    set -l selected (fzf --prompt="コミットメッセージを選択: " --height=40% --reverse <$messages_file)
    rm -f $messages_file

    if test -z "$selected"
        echo "キャンセルされました。"
        return 0
    end

    # Perform the commit
    if git commit -m "$selected"
        echo "コミットが完了しました: $selected"
    else
        echo "エラー: コミットに失敗しました"
        return 1
    end
end
