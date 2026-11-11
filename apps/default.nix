{ callPackage }:
{
  hype = callPackage ./hype.nix { };
  signed = callPackage ./signed.nix { };
  disktree = callPackage ./disktree.nix { };
  monologue = callPackage ./monologue.nix { };
  gliff = callPackage ./gliff.nix { };
  folio = callPackage ./folio.nix { };
}
