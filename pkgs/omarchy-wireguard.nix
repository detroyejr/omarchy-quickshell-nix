{
  buildOmarchyPlugin,
  fetchFromGitHub,
  wireguard-tools,
  networkmanager,
}:

buildOmarchyPlugin {
  pname = "omarchy-wireguard";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "r3mcos3";
    repo = "remco.wireguard";
    rev = "0bbe737da96008e6fc2b3b1f3aef9b49d249dcfb";
    hash = "sha256-vizDFzT6ESfCy0O4QDLIDA+xOtx6xmeRMV3XL9un3iw=";
  };

  patchPhase = ''
    substituteInPlace BarWidget.qml \
      --replace-fail 'Quickshell.env("HOME") + "/.config/omarchy/plugins/remco.wireguard/scripts' "\"$out/scripts"
  '';

  runtimeInputs = [
    wireguard-tools
    networkmanager
  ];
}
