function aicommit -d "Generate and select AI-powered commit messages"
    # Parse arguments using argparse
    argparse -n aicommit h/help -- $argv
    or return

    if set -q _flag_help
        echo "使い方: aicommit [オプション]"
        echo ""
        echo "AIを使用してConventional Commit形式のコミットメッセージを生成し、選択してコミットします。"
        echo "言語とAIプロバイダーはfzfで対話的に選択します。"
        echo ""
        echo "オプション:"
        echo "  -h, --help     このヘルプメッセージを表示"
        return 0
    end

    # Check if there are staged changes
    set -l diff_output (git diff --cached 2>&1)
    or begin
        echo "エラー: gitリポジトリではないか、gitコマンドが失敗しました"
        return 1
    end

    test -n "$diff_output"
    or begin
        echo "ステージされた変更がありません。"
        return 0
    end

    # Select language with fzf
    set -l lang (printf "ja\nen\n" | fzf --prompt="言語を選択: " --height=40% --reverse)
    if test -z "$lang"
        echo "キャンセルされました。"
        return 0
    end

    # Select AI provider with fzf
    set -l provider (printf "claude\ncodex\ngemini\n" | fzf --prompt="AIプロバイダーを選択: " --height=40% --reverse)
    if test -z "$provider"
        echo "キャンセルされました。"
        return 0
    end

    # Get git status for context (only staged files)
    set -l git_status (git diff --cached --name-status)

    # Prepare prompt
    set -l lang_instruction (test "$lang" = ja; and echo "in Japanese"; or echo "in English")

    set -l prompt "Analyze the following git diff and git status, then suggest 3 conventional commit messages $lang_instruction.

Each message should follow this format:
- type: subject format (no scope needed)
- type should be one of: feat, fix, docs, style, refactor, test, chore, etc.
- subject should concisely describe the changes
- subject can start with either lowercase or uppercase letter
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

    # Call AI provider to generate commit messages
    echo "コミットメッセージを生成中 ($provider)..."

    # Use a temporary file to pass the prompt to avoid quoting issues
    set -l prompt_file (mktemp)
    echo "$prompt" >$prompt_file

    # Execute command based on provider with timeout
    set -l timeout_seconds 60
    set -l ai_output
    set -l ai_status

    switch $provider
        case claude
            set ai_output (timeout $timeout_seconds claude --model sonnet -p <$prompt_file 2>&1)
            set ai_status $status
        case gemini
            set ai_output (timeout $timeout_seconds gemini --model flash-lite <$prompt_file 2>&1)
            set ai_status $status
        case codex
            set ai_output (timeout $timeout_seconds codex --model codex-mini-latest exec - <$prompt_file 2>&1)
            set ai_status $status
    end

    rm -f $prompt_file

    # Check for timeout (exit code 124)
    if test $ai_status -eq 124
        echo "エラー: AI CLI ($provider) の呼び出しがタイムアウトしました ("$timeout_seconds"秒)"
        return 1
    end

    if test $ai_status -ne 0
        echo "エラー: AI CLI ($provider) の呼び出しに失敗しました (exit code: $ai_status)"
        echo "$ai_output"
        return 1
    end

    # Parse the output to extract commit messages
    set -l messages_file (mktemp)
    echo "$ai_output" | perl -pe 's/ (\d+)\. /\n$1. /g' | grep '^\d\.' | sed -E 's/^[0-9]+\. //' >$messages_file

    # Check if we found any messages
    set -l message_count (wc -l <$messages_file | string trim)
    if test "$message_count" -eq 0
        echo "エラー: AIの出力からコミットメッセージをパースできませんでした"
        echo "AIの出力:"
        echo "$ai_output"
        rm -f $messages_file
        return 1
    end

    # Let user select a message with fzf
    set -l selected (fzf --prompt="コミットメッセージを選択: " --height=40% --reverse <$messages_file)
    set -l messages (cat $messages_file)
    rm -f $messages_file

    if test -z "$selected"
        echo "キャンセルされました。生成されたコミットメッセージ:"
        printf '%s\n' $messages
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
