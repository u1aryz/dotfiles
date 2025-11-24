function tag_from_version -d "Create git tag from package.json or deno.json version with v prefix"
    set -l pkg_version ''

    if test -f package.json
        set pkg_version (node -p "require('./package.json').version || ''" 2>/dev/null)
    end

    if test -z "$pkg_version" -a -f deno.json
        set pkg_version (node -p "require('./deno.json').version || ''" 2>/dev/null)
    end

    if test -z "$pkg_version"
        echo "Failed to retrieve version from package.json or deno.json" >&2
        return 1
    end

    set -l tag
    if string match -rq '^v' -- $pkg_version
        set tag $pkg_version
    else
        set tag v$pkg_version
    end

    if git rev-parse --quiet --verify "$tag" >/dev/null
        echo "Tag $tag already exists" >&2
        return 1
    end
    git tag "$tag"
end
