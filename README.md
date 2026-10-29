# gensokyo-private

Per-host configuration for nornpkgs that does not belong on a public host:
disk ids, VPN endpoints, host ids, initrd ssh keys and the like. Consumed as
the `gensokyo-private` flake input of nornpkgs.

## branches

* `private` — the real thing. Lives on this machine only; see the hooks below.
  Build against it with
  `make ... PRIVATE_FLAKE='git+file:///home/clownpiece/src/gensokyo-private?ref=private'`.
* `public` — the stub nornpkgs' `flake.lock` points at. Every per-host module
  is empty, so nornpkgs evaluates with by-label fallbacks.
* `ci` — the stub the GitHub Actions runner uses. Same as `public`, plus
  `gensokyo.ci = true`, which nornpkgs reads to drop the CUDA-flavoured,
  multi-hour packages from the home profiles. Override the input to it in CI:
  `--override-input gensokyo-private github:warmdarksea/gensokyo-private/ci`.

## hooks

`hooks/` keeps `private` from leaving this machine. Install once per clone:

```sh
hooks/install.sh            # pre-push: refuses to push private, or anything containing it
hooks/install.sh --origin   # on the repo others clone from: also refuses pushes *to*
                            # private without `-o private-ok`, and hides private from
                            # clone/fetch (uploadpack.hideRefs)
```

The hooks are copied into `.git/hooks`, so they stay active on every branch.
Re-run after editing them, and merge `public` into `private` so the private
checkout carries them too.

Overrides, for when you really mean it:

```sh
GENSOKYO_PUSH_PRIVATE=1 git push -o private-ok origin private   # env: client hook, -o: origin hook
git -c uploadpack.hideRefs='!refs/heads/private' fetch origin private:private   # local transport only
```

Pushes to `public` and `ci` are never blocked, unless their history contains
`private` (an accidental merge).
