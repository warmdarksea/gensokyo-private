#!/usr/bin/env bash
# Install the gensokyo-private git hooks into this clone.
#
#   hooks/install.sh            client side: pre-push (never push `private`)
#   hooks/install.sh --origin   additionally mark this repo as the one others
#                               clone from: install the server-side `pre-receive`
#                               hook, enable push options, and hide `private`
#                               from clone/fetch
#
# The hooks are *copied* into $GIT_DIR/hooks rather than wired up through
# core.hooksPath, so they keep working on branches that don't carry hooks/
# (private, until public is merged into it). Re-run after changing hooks/.
#
# With --origin, `private` is hidden via uploadpack.hideRefs: a plain clone or
# fetch does not see it at all. To pull it anyway see hooks/fetch-private.sh
# (local paths only; over ssh the server-side config wins, which is the point).
set -eu

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
gitdir=$(git -C "$here/.." rev-parse --git-path hooks)
origin=0
[ "${1:-}" = --origin ] && origin=1

mkdir -p "$gitdir"
install -m 0755 "$here/pre-push" "$gitdir/pre-push"
echo "installed $gitdir/pre-push"

if [ "$origin" = 1 ]; then
  install -m 0755 "$here/pre-receive" "$gitdir/pre-receive"
  echo "installed $gitdir/pre-receive"
  git -C "$here/.." config receive.advertisePushOptions true
  git -C "$here/.." config --replace-all uploadpack.hideRefs refs/heads/private
  echo "set receive.advertisePushOptions=true, uploadpack.hideRefs=refs/heads/private"
fi
