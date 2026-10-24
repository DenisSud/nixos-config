# parakeet-typing

Local, streaming-style voice typing for GNOME using NVIDIA **Parakeet TDT
0.6B v3** (25 European languages, including Russian and Ukrainian).
No cloud, no network after the build.

## How it works

```
 hotkey  ┌──────────────────────────────┐  IBus preedit + commit
────────►│ parakeet-typing toggle       │──────────────► any focused app
         └──────────────┬───────────────┘
                        │ `ibus engine parakeet`
                        ▼
         ┌──────────────────────────────┐
         │ IBus engine process          │
         │  pw-record ─► silero VAD     │
         │      │                       │
         │      └─► Parakeet TDT (int8) │  re-decode every 350 ms,
         │          partial hypothesis  │  final decode on endpoint
         └──────────────┬───────────────┘
                        │ session bus
                        ▼
         ┌──────────────────────────────┐
         │ GNOME Shell pill extension   │  live waveform at bottom centre
         └──────────────────────────────┘
```

- **Insertion** uses an IBus input method, so arbitrary Unicode text lands in
  the focused field of GTK/Qt/Electron/terminal apps. uinput typers
  (ydotool/dotool) are not involved; no extra device permissions.
- **Streaming** re-decodes the growing utterance on a fixed cadence (the
  model itself is an offline TDT checkpoint; the English-only "realtime"
  Parakeet variants are not multilingual). On a Ryzen 5 9600X a 10 s
  utterance decodes in ~220 ms, so the cadence has plenty of headroom.
- **Endpointing** is a VAD model plus a small policy layer
  (`parakeet_typing/endpoint.py`): the model says what is speech, the policy
  decides when dictation is over. Onset needs the model *and* 6 dB above the
  adaptive noise floor, so a false positive in a noisy room does not start a
  session. The endpoint waits 0.6 s in a clean pause and 1.2 s while the tail
  is still noisy, plus another 0.25 s while the running hypothesis is still
  changing (a mid-sentence pause rarely comes with settled text). Press the
  hotkey again to finish immediately; Escape cancels.
- **The final decode never sees the silence we waited for.** The trailing
  hangover is trimmed off (keeping 150 ms), because handing the int8
  transducer a chunk that ends in dead air regularly made it emit *nothing* —
  which looked like the transcript disappearing. If a final decode still comes
  back empty or degenerate (`Hehehehehehe`), the last non-empty partial is
  committed instead, so a session never silently drops what the preedit showed.
- After a commit the engine stays active for a short correction window
  (default 15 s) and replays the user's BackSpace/typing edits against the
  committed text. That is stored as a *correction* record, flagged
  unreliable if the cursor may have left the dictated segment.

The first activation after login pays ~1 s for model loading; audio capture
starts first and is buffered, so the first words are not lost. The IBus
engine process stays alive for the rest of the session and keeps the model
warm.

## Commands

```bash
parakeet-typing toggle          # what the GNOME keybinding calls
parakeet-typing status          # engine + dataset overview
parakeet-typing doctor --mic    # installation / microphone check
parakeet-typing setup --binding '<Super><Alt>v' \
    --extension parakeet-indicator@denis
parakeet-typing stream file.wav # run the streaming pipeline headless
parakeet-typing review          # play recent utterances, fix transcripts
parakeet-typing export --out DIR [--corrected-only] [--use-tracked]
```

## Dataset

Everything is append-only, under `~/.local/share/parakeet-typing/`:

```
audio/2026/10/23/<id>.wav     16 kHz mono, includes 0.6 s pre-roll
utterances.jsonl              one record per committed segment
corrections.jsonl             post-commit edits / review results
```

An utterance record contains the transcript, the partial hypotheses, decode
latencies, segment index and the settings used. Correction records contain
the committed text, the reconstructed final text, a `reliable` flag and the
raw key events.

`export` writes a Hugging Face **audiofolder** dataset (`metadata.jsonl` +
`audio/`), suitable for fine-tuning or analysis. `review` is the reliable
way to produce ground truth: replay the audio, edit the transcript in
`$EDITOR`, and the corrected text is appended to `corrections.jsonl`.

Logging audio can be disabled with `{"log_audio": false}` in the config.

## Configuration

Optional `~/.config/parakeet-typing/config.json` (all keys optional):

```json
{
  "num_threads": 4,
  "partial_interval": 0.35,
  "vad_model": "silero",
  "vad_threshold": 0.45,
  "end_silence": 0.6,
  "end_silence_noisy": 1.2,
  "pause_grace": 0.25,
  "partial_grace": 0.7,
  "onset_snr": 6.0,
  "quiet_snr": 9.0,
  "tail_pad": 0.15,
  "lead_pad": 0.1,
  "pre_roll": 0.6,
  "max_utterance": 20.0,
  "min_speech": 0.2,
  "correction_window": 15.0,
  "idle_timeout": 30.0,
  "log_audio": true,
  "log_partials": true,
  "hotkey": "<Super><Alt>v"
}
```

`partial_interval` trades CPU/latency for how often the preedit updates.
`end_silence` / `end_silence_noisy` are the hangovers after a quiet and a
noisy pause; `pause_grace` is added while the hypothesis is younger than
`partial_grace`. `onset_snr` / `quiet_snr` are dB above the adaptive noise
floor. `correction_window: 0` restores the input source immediately after a
commit and disables edit tracking.

Two VAD models ship with the package: **silero** (default, MIT, 644 kB) and
**ten-vad** (129 kB int8, selected with `"vad_model": "ten"`; Apache-2.0 with
additional conditions, see its LICENSE). TEN is not the default because it
under-segmented this machine's real recordings at its default threshold;
`"vad_threshold": 0.3` is a better starting point if you want to try it.
Both are only the frame classifier — the hangover/trim policy is the same.

## GNOME integration

- The NixOS module adds the package to `i18n.inputMethod.ibus.engines`;
  nixpkgs' `ibus-with-plugins` wrapper merges the component XML into
  `IBUS_COMPONENT_PATH` (IBus compiles user component dirs out and the
  wrapper overrides the env var).
- A systemd **user** oneshot at `graphical-session.target` installs the
  custom keybinding and appends the indicator UUID to
  `org.gnome.shell enabled-extensions`. `gsettings` is the source of truth
  for both; the service is idempotent.
- The first time the engine is installed (or when the shell version changes)
  log out and back in so GNOME Shell discovers the system extension. IBus
  itself can be refreshed with `ibus restart`.
- The pill sits above normal windows at the bottom centre. Click it to
  commit; right-click to cancel; Escape also cancels while listening.
- If the microphone is muted (`wpctl get-volume @DEFAULT_AUDIO_SOURCE@`),
  unmute it once with `wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0`;
  `parakeet-typing doctor --mic` warns about this.

## Limitations

- IBus-based apps only (that covers GNOME text fields, GTK/Qt/Electron,
  terminals; rare custom toolkits that bypass input methods are not covered).
- CPU-only on purpose: the int8 model is already 35-40x realtime; a CUDA
  ONNX Runtime build would add a large, rebuild-heavy dependency for no
  practical gain at dictation lengths.
- A very long uninterrupted utterance is split at `max_utterance` (20 s) and
  committed in segments; the boundary can cut a word. Pausing naturally
  avoids it.
- The correction tracker is best-effort: arrows, selection and shortcuts
  mark the sample unreliable. Use `parakeet-typing review` for ground truth.
