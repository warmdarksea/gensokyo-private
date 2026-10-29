#!/usr/bin/env bash
# Fetch the hidden `private` branch from a local origin -- the override for
# uploadpack.hideRefs (set by hooks/install.sh --origin).
#
#   hooks/fetch-private.sh              # from the `origin` remote (must be a local path)
#   hooks/fetch-private.sh /path/to/gensokyo-private
#
# git strips `-c` / GIT_CONFIG_* from the environment it hands to the local
# upload-pack, so the un-hide has to be spelled on upload-pack's own command
# line; the ext:: transport is the sanctioned way to do that. Local paths only:
# over ssh the server's config wins, which is the point of hiding the branch.
set -eu

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo=$here/..
src=${1:-$(git -C "$repo" remote get-url origin)}

case $src in
  file://*) src=${src#file://} ;;
  *://*|*@*:*) echo "fetch-private: $src is not a local path" >&2; exit 1 ;;
esac
gitdir=$(git -C "$src" rev-parse --absolute-git-dir)

git -C "$repo" -c protocol.ext.allow=always fetch \
  "ext::git -c uploadpack.hideRefs=!refs/heads/private upload-pack $gitdir" \
  private:private
echo "fetch-private: private <- $src"
