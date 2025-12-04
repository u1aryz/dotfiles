function aicommit -d "Generate and select AI-powered commit messages"
    # Constants
    set -l TIMEOUT_SECONDS 60

    # Helper function for fzf selection
    function __fzf_select --argument-names prompt
        printf '%s\n' $argv[2..] | fzf --prompt="$prompt" --height=40% --reverse
    end

    # Parse arguments using argparse
    argparse -n aicommit h/help -- $argv
    or return

    if set -q _flag_help
        echo "使い方: aicommit [オプション]"
        echo ""
        echo "AIを使用してConventional Commit形式のコミットメッセージを生成し、選択してコミットします。"
        echo "言語とコードエージェントはfzfで対話的に選択します。"
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
    set -l lang (__fzf_select "言語を選択: " ja en)
    if test -z "$lang"
        echo "キャンセルされました。"
        return 0
    end

    # Select code agent with fzf
    set -l code_agent (__fzf_select "コードエージェントを選択: " claude codex gemini)
    if test -z "$code_agent"
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

    # Call code agent to generate commit messages
    echo "コミットメッセージを生成中 ($code_agent, $lang)..."

    # Create temporary files
    set -l prompt_file (mktemp)
    set -l stdout_file (mktemp)
    set -l stderr_file (mktemp)

    echo "$prompt" >$prompt_file

    # Build command based on code agent
    set -l ai_cmd
    switch $code_agent
        case claude
            set ai_cmd claude --model sonnet -p
        case gemini
            set ai_cmd gemini --model flash-lite
        case codex
            set ai_cmd codex --model codex-mini-latest exec -
    end

    # Execute command with timeout
    timeout --foreground $TIMEOUT_SECONDS $ai_cmd <$prompt_file >$stdout_file 2>$stderr_file
    set -l ai_status $status

    set -l ai_stdout (cat $stdout_file)
    set -l ai_stderr (cat $stderr_file)

    rm -f $prompt_file $stdout_file $stderr_file

    # Handle errors
    if test $ai_status -ne 0
        if test $ai_status -eq 124
            echo "エラー: AI CLI ($code_agent) の呼び出しがタイムアウトしました ($TIMEOUT_SECONDS 秒)"
        else
            echo "エラー: AI CLI ($code_agent) の呼び出しに失敗しました (exit code: $ai_status)"
        end
        test -n "$ai_stderr"; and echo "$ai_stderr"
        return 1
    end

    # Parse the output to extract commit messages
    set -l messages (echo "$ai_stdout" | sed -E 's/ ([0-9]+)\. /\n\1. /g' | grep '^\d\.' | sed -E 's/^[0-9]+\. //')

    # Check if we found any messages
    set -l message_count (count $messages)
    if test "$message_count" -eq 0
        echo "エラー: AIの出力からコミットメッセージをパースできませんでした"
        echo "AIの出力:"
        echo "$ai_stdout"
        return 1
    end

    # Let user select a message with fzf
    set -l selected (__fzf_select "コミットメッセージを選択: " $messages)

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
