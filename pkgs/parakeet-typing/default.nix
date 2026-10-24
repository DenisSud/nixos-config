# parakeet-typing — local Parakeet TDT v3 voice typing for GNOME
#
# CPU-only on purpose: the int8 quantized 0.6B model runs at ~35-40x
# realtime on a modern Ryzen, so an ONNX Runtime CUDA build (large, slow to
# rebuild, NVIDIA-only) would buy nothing for dictation-sized utterances.
#
# Model provenance (pinned to one Hugging Face commit):
#   https://huggingface.co/csukuangfj/sherpa-onnx-nemo-parakeet-tdt-0.6b-v3-int8
# The files are NVIDIA's parakeet-tdt-0.6b-v3 (CC-BY-4.0) exported to ONNX
# and int8-quantized for sherpa-onnx.
{
  lib,
  python3Packages,
  fetchurl,
  runCommand,
  glib,
  ibus,
  gobject-introspection,
  pipewire,
  wireplumber,
  libnotify,
  gnome-shell,
  xorg,
}:

let
  hf = "https://huggingface.co/csukuangfj/sherpa-onnx-nemo-parakeet-tdt-0.6b-v3-int8/resolve/2bda32ec70b097a55adaa07d9a7173915b43cc78";

  encoder = fetchurl {
    url = "${hf}/encoder.int8.onnx";
    hash = "sha256-rPwrRFY3fhXQTwJDr1QLf+fJkvjYmNdRzxNMOlX9Ikc=";
  };
  decoder = fetchurl {
    url = "${hf}/decoder.int8.onnx";
    hash = "sha256-F55QxD0aneeciiQUmi+brG61mBgj8qLtiNZVskJI204=";
  };
  joiner = fetchurl {
    url = "${hf}/joiner.int8.onnx";
    hash = "sha256-MWTBP8KCEAlEDSD8tf3Hi/8otNsvjQ8LMpEBcZwJSLM=";
  };
  tokens = fetchurl {
    url = "${hf}/tokens.txt";
    hash = "sha256-1YVEZ56kvGrFY9H1Ret9R0vWz6Rn8KbiwdwcfTfjw10=";
  };
  # silero-vad is the default endpoint model: MIT, 644 kB, and it held up
  # better than ten-vad on this machine's real recordings.  Pinned by hash;
  # the upstream release asset is not versioned per file, so bump the hash
  # deliberately if it is ever replaced.
  sileroVad = fetchurl {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/silero_vad.onnx";
    hash = "sha256-niRJ4Qh0ltjUyrqQfyPgvT942R+lUkebucI6wJy7H9Y=";
  };
  # ten-vad: 129 kB int8, selected with `"vad_model": "ten"` in
  # ~/.config/parakeet-typing/config.json.  Apache-2.0 plus additional
  # conditions (see TEN-framework/ten-vad LICENSE); fine for personal use.
  tenVad = fetchurl {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/ten-vad.int8.onnx";
    hash = "sha256-iAwHLxiO+haeoCiyFZ0bOkOOFT0IC4fqwxt07K1RHmE=";
  };

  model = runCommand "parakeet-tdt-0.6b-v3-int8" { } ''
    runHook preInstall
    mkdir -p "$out"
    cp ${encoder} "$out/encoder.int8.onnx"
    cp ${decoder} "$out/decoder.int8.onnx"
    cp ${joiner} "$out/joiner.int8.onnx"
    cp ${tokens} "$out/tokens.txt"
    cp ${sileroVad} "$out/silero_vad.onnx"
    cp ${tenVad} "$out/ten-vad.int8.onnx"
    runHook postInstall
  '';

  python = python3Packages;
in
python.buildPythonApplication rec {
  pname = "parakeet-typing";
  version = "0.2.0";
  pyproject = true;

  src = lib.cleanSource ./.;

  build-system = [ python.setuptools ];

  dependencies = [
    python.numpy
    python.sherpa-onnx
    python.pygobject3
  ];

  # GI typelibs for PyGObject; PATH for the tools the CLI/engine shell out to.
  makeWrapperArgs = [
    "--prefix"
    "GI_TYPELIB_PATH"
    ":"
    "${lib.makeSearchPath "lib/girepository-1.0" [
      glib.out
      ibus
      gobject-introspection.out
    ]}"
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [
      pipewire
      wireplumber
      ibus
      (lib.getBin glib)
      libnotify
      # `gnome-extensions` (best-effort runtime enable in the login service).
      gnome-shell
      # IBus calls setxkbmap when switching input sources; without it the
      # ibus CLI exits 1 even though the switch worked.
      xorg.setxkbmap
    ]}"
    "--set"
    "PARAKEET_TYPING_MODEL_DIR"
    "${model}"
    "--set"
    "PARAKEET_TYPING_IBUS"
    "${ibus}/bin/ibus"
    "--set"
    "PARAKEET_TYPING_PW_RECORD"
    "${pipewire}/bin/pw-record"
    "--set"
    "PARAKEET_TYPING_PW_PLAY"
    "${pipewire}/bin/pw-play"
  ];

  # The endpoint policy is pure numpy and needs no model: cheap to test.
  doCheck = true;
  checkPhase = ''
    python -m unittest discover -s tests -t .
  '';

  postInstall = ''
    install -Dm644 ${./share/parakeet-typing.xml} \
      "$out/share/ibus/component/parakeet-typing.xml"
    substituteInPlace "$out/share/ibus/component/parakeet-typing.xml" \
      --replace-fail '@ENGINE@' "$out/bin/parakeet-typing engine"
  '';

  # The nixpkgs sherpa-onnx package installs plain files without dist-info,
  # so the automatic runtime dependency check cannot see it.
  dontCheckRuntimeDeps = true;

  pythonImportsCheck = [ "parakeet_typing" ];

  meta = {
    description = "Local NVIDIA Parakeet TDT v3 voice typing for GNOME (IBus engine)";
    homepage = "https://github.com/DenisSud/nixos-config";
    license = lib.licenses.mit;
    mainProgram = "parakeet-typing";
    platforms = lib.platforms.linux;
    # Consumed by i18n.inputMethod.ibus.engines — the NixOS ibus module
    # merges this package's share/ibus/component into the ibus-with-plugins
    # buildEnv (and therefore into IBUS_COMPONENT_PATH).
    isIbusEngine = true;
  };
}
