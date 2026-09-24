#!/bin/bash
# Installe tout ce dont HyperFrames a besoin dans les sessions Claude Code on the web.
# Idempotent : chaque étape est sautée si déjà faite (l'état du conteneur est mis en cache).
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

HF_VERSION="0.8.74"
HF="npx --yes hyperframes@${HF_VERSION}"
export HYPERFRAMES_SKIP_SKILLS=1

log() { echo "[session-start] $*" >&2; }

# 1. FFmpeg / FFprobe (encodage vidéo, obligatoire)
if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
  log "Installation de FFmpeg..."
  SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
  $SUDO apt-get update -qq >/dev/null 2>&1 || true   # certains PPA peuvent être bloqués par le proxy
  DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y -qq ffmpeg >/dev/null
fi

# 2. CLI HyperFrames (mise en cache npx) + Chrome headless shell (rendu local, obligatoire)
log "Chrome headless pour HyperFrames..."
$HF browser ensure >/dev/null 2>&1

# 3. whisper.cpp (transcription / sous-titres) — compilé là où HyperFrames le cherche
WHISPER_DIR="$HOME/.cache/hyperframes/whisper/whisper.cpp"
if ! command -v whisper-cli >/dev/null 2>&1 && [ ! -x "$WHISPER_DIR/build/bin/whisper-cli" ]; then
  log "Compilation de whisper.cpp..."
  rm -rf "$WHISPER_DIR"
  mkdir -p "$(dirname "$WHISPER_DIR")"
  git clone --depth 1 -q https://github.com/ggml-org/whisper.cpp.git "$WHISPER_DIR"
  cmake -S "$WHISPER_DIR" -B "$WHISPER_DIR/build" -DCMAKE_BUILD_TYPE=Release >/dev/null
  cmake --build "$WHISPER_DIR/build" --config Release -j"$(nproc)" --target whisper-cli >/dev/null
fi

# 4. Kokoro TTS (voix off locale)
if ! python3 -c "import kokoro_onnx, soundfile" >/dev/null 2>&1; then
  log "Installation de Kokoro TTS..."
  pip install -q kokoro-onnx soundfile
fi

# 5. Préchargement des modèles (voix Kokoro depuis GitHub, Whisper depuis huggingface.co).
#    Non bloquant : si le réseau de l'environnement refuse l'hôte, ils seront retentés au premier usage.
TTS_DIR="$HOME/.cache/hyperframes/tts"
if [ ! -f "$TTS_DIR/models/kokoro-v1.0.onnx" ] || [ ! -f "$TTS_DIR/voices/voices-v1.0.bin" ]; then
  log "Téléchargement du modèle de voix Kokoro..."
  TMP_WAV="$(mktemp --suffix=.wav)"
  $HF tts "ok" -o "$TMP_WAV" >/dev/null 2>&1 || log "Modèle Kokoro non téléchargé (réseau ?)"
  rm -f "$TMP_WAV"
fi
WHISPER_MODELS="$HOME/.cache/hyperframes/whisper/models"
mkdir -p "$WHISPER_MODELS"
for m in small.en small; do   # small.en = défaut HyperFrames, small = multilingue (français)
  f="$WHISPER_MODELS/ggml-$m.bin"
  if [ ! -s "$f" ]; then
    log "Téléchargement du modèle Whisper $m..."
    curl -fsSL --retry 2 -o "$f.part" "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-$m.bin" \
      && mv "$f.part" "$f" \
      || { rm -f "$f.part"; log "Modèle Whisper $m non téléchargé : autoriser huggingface.co dans l'accès réseau de l'environnement."; }
  fi
done

log "Prêt. Diagnostic :"
$HF doctor >&2 || true
