{
  description = "gensokyo private data stub for CI: no per-host data, flags the build as a CI build";
  outputs = { self }: {
    # nornpkgs reads this (`gensokyo-private.gensokyo.ci or false`) and
    # drops the CUDA-flavoured, hours-to-build packages from the home
    # profiles, so the CI runner builds a system closure it can finish.
    gensokyo.ci = true;
    nixosModules.default = { };
    data = { };
  };
}
