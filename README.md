# mon-projet-Claude

Projet vidéo [HyperFrames](https://hyperframes.heygen.com) (HeyGen) : des compositions HTML + GSAP rendues en MP4.

## Structure

- `index.html` — composition principale (1920×1080, 10 s)
- `hyperframes.json` — configuration du projet (registry, chemins des blocs/assets)
- `.claude/skills/` — skills HyperFrames pour Claude Code (`/hyperframes`, `hyperframes-core`, `hyperframes-animation`, …)
- `CLAUDE.md` / `AGENTS.md` — consignes pour les agents IA

## Prérequis

- Node.js 22+
- FFmpeg (`sudo apt-get install -y ffmpeg` ou `brew install ffmpeg`)
- Chrome headless : `npx hyperframes browser ensure`

Vérifier l'environnement : `npx hyperframes doctor`

## Commandes

```bash
npm run dev      # studio de prévisualisation dans le navigateur
npm run check    # lint + validation + inspection de la mise en page
npm run render   # rendu MP4 dans renders/
```

## Avec Claude Code

> « Avec /hyperframes, crée une intro de 15 secondes sur [ton sujet] »
