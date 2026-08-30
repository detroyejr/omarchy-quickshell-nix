{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ttfx";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "ttfx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bwFjC6ZkZibkgXjoYVH2VuqqeXklGR9kmRl2fTitWBU=";
  };

  cargoHash = "sha256-DNrg12MNqBcQi6yvoJObM1gtE90iGBCxeQ3RwueYCE4=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd ttfx \
      --bash <($out/bin/ttfx --print-completion bash) \
      --zsh <($out/bin/ttfx --print-completion zsh)
  '';

  meta = {
    description = "Terminal text effects as a single binary";
    homepage = "https://github.com/omacom/ttfx";
    license = lib.licenses.mit;
    mainProgram = "ttfx";
    platforms = lib.platforms.unix;
  };
})
