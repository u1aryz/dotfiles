function aicommit -d "Generate and select AI-powered commit messages"
    # Constants
    set -l TIMEOUT_SECONDS 60

    # Helper function for fzf selection
    function __aicommit_select --argument-names prompt
        printf '%s\n' $argv[2..] | fzf --prompt="$prompt" --height=40% --reverse
    end

    # Parse arguments using argparse
    argparse -n aicommit h/help -- $argv
    or return

    if set -q _flag_help
        echo "使い方: aicommit [オプション]"
        echo ""
        echo "AIを使用してConventional Commit形式のコミットメッセージを生成し、選択してコミットします。"
        echo "言語とpiモデルはfzfで対話的に選択します。"
        echo ""
        echo "オプション:"
        echo "  -h, --help     このヘルプメッセージを表示"
        return 0
    end

    # Check if there are staged changes (exclude lock files from diff)
    set -l diff_output (git diff --cached -- . ':!*.lock' ':!package-lock.json' ':!pnpm-lock.yaml' 2>&1)
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
    set -l lang (__aicommit_select "言語を選択: " ja en)
    if test -z "$lang"
        echo "キャンセルされました。"
        return 0
    end

    # Select pi model with fzf
    set -l pi_model_list (pi --list-models 2>/dev/null)
    set -l list_models_status $status
    if test $list_models_status -ne 0
        echo "エラー: piのモデル一覧取得に失敗しました (exit code: $list_models_status)"
        return 1
    end

    if test (count $pi_model_list) -eq 0; or string match -q "No models available*" -- $pi_model_list[1]
        echo "エラー: 利用可能なpiモデルがありません。pi /login またはprovider/API key設定を確認してください。"
        return 1
    end

    set -l pi_models (printf '%s\n' $pi_model_list | awk 'NR == 1 && $1 == "provider" && $2 == "model" { next } NF >= 2 { print $2 }')
    if test (count $pi_models) -eq 0
        echo "エラー: piのモデル一覧からモデル名を抽出できませんでした。"
        return 1
    end

    set -l pi_model (__aicommit_select "piモデルを選択: " $pi_models)
    if test -z "$pi_model"
        echo "キャンセルされました。"
        return 0
    end

    # Get git status for context (only staged files)
    set -l git_status (git diff --cached --name-status)

    # Prepare prompt
    set -l lang_instruction (test "$lang" = ja; and echo "in Japanese"; or echo "in English")
    set -l subject_style_instruction
    if test "$lang" = ja
        set subject_style_instruction "- subject should be a concise noun phrase in Japanese\n- avoid verb endings such as: する, した, している\n- prefer subjects like: Codex呼び出しの最新化, 設定文言の整理"
    else
        set subject_style_instruction "- subject must use imperative mood, not progressive/gerund form\n- avoid subjects like: adding, updating, fixing, refactoring"
    end

    set -l prompt "Analyze the following git diff and git status, then suggest 3 conventional commit messages $lang_instruction.

Each message should follow this format:
- type: subject format (no scope needed)
- type should be one of: feat, fix, docs, style, refactor, test, chore, etc.
- subject should concisely describe the changes
$subject_style_instruction
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

    # Call pi to generate commit messages
    echo "コミットメッセージを生成中 (pi: $pi_model, $lang)..."

    # Create temporary files
    set -l prompt_file (mktemp)
    set -l stdout_file (mktemp)
    set -l stderr_file (mktemp)

    echo "$prompt" >$prompt_file

    set -l ai_cmd pi --model $pi_model --no-session -p

    # Execute command with timeout
    timeout --foreground $TIMEOUT_SECONDS $ai_cmd <$prompt_file >$stdout_file 2>$stderr_file
    set -l ai_status $status

    set -l ai_stdout (cat $stdout_file)
    set -l ai_stderr (cat $stderr_file)

    rm -f $prompt_file $stdout_file $stderr_file

    # Handle errors
    if test $ai_status -ne 0
        if test $ai_status -eq 124
            echo "エラー: pi ($pi_model) の呼び出しがタイムアウトしました ($TIMEOUT_SECONDS 秒)"
        else
            echo "エラー: pi ($pi_model) の呼び出しに失敗しました (exit code: $ai_status)"
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
    set -l selected (__aicommit_select "コミットメッセージを選択: " $messages)

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
