function tag_from_version -d "Create git tag from package.json or deno.json version with v prefix"
    set -l pkg_version

    test -f package.json
    and set pkg_version (node -p "require('./package.json').version || ''" 2>/dev/null)

    test -z "$pkg_version"; and test -f deno.json
    and set pkg_version (node -p "require('./deno.json').version || ''" 2>/dev/null)

    test -n "$pkg_version"
    or begin
        echo "Failed to retrieve version from package.json or deno.json" >&2
        return 1
    end

    set -l tag (string match -rq '^v' -- $pkg_version; and echo $pkg_version; or echo v$pkg_version)

    git rev-parse --quiet --verify "$tag" >/dev/null
    and begin
        echo "Tag $tag already exists" >&2
        return 1
    end

    git tag "$tag"
end
