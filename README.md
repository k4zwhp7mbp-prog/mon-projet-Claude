# mon-projet-Claude

Projet vidéo [HyperFrames](https://hyperframes.heygen.com) (HeyGen) : des compositions HTML + GSAP rendues en MP4.

## Structure

- `index.html` — composition principale (1920×1080, 10 s)
- `assets/vendor/gsap.min.js` — GSAP 3.14.2 en local (fonctionne sans accès au CDN)
- `hyperframes.json` — configuration du projet (registry, chemins des blocs/assets)
- `.claude/skills/` — skills HyperFrames pour Claude Code : `/hyperframes` (point d'entrée), les workflows (`/product-launch-video`, `/faceless-explainer`, `/motion-graphics`, `/embedded-captions`, `/slideshow`, …) et les skills techniques (`hyperframes-core`, `hyperframes-animation`, `media-use`, …)
- `.claude/hooks/session-start.sh` — installe automatiquement les outils dans chaque session Claude Code on the web
- `CLAUDE.md` / `AGENTS.md` — consignes pour les agents IA

## Prérequis

Dans Claude Code on the web, tout est installé automatiquement au démarrage de la session (FFmpeg, Chrome headless, whisper.cpp, Kokoro TTS, modèles). En local :

- Node.js 22+
- FFmpeg (`sudo apt-get install -y ffmpeg` ou `brew install ffmpeg`)
- Chrome headless : `npx hyperframes browser ensure`
- Optionnel : `pip install kokoro-onnx soundfile` (voix off locale), whisper.cpp (sous-titres, compilé automatiquement au premier usage si `cmake` est présent)

Vérifier l'environnement : `npx hyperframes doctor`

### Accès réseau (Claude Code on the web)

Pour que tout fonctionne, l'environnement doit autoriser ces domaines (Environnement → Edit → Network access) :

- `huggingface.co` — modèles Whisper (transcription / sous-titres)
- `cdn.jsdelivr.net` — bibliothèques chargées par les blocs du registry HyperFrames

## Commandes

```bash
npm run dev      # studio de prévisualisation dans le navigateur
npm run check    # lint + validation + inspection de la mise en page
npm run render   # rendu MP4 dans renders/
```

## Avec Claude Code

> « Avec /hyperframes, crée une intro de 15 secondes sur [ton sujet] »
