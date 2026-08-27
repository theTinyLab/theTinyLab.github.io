# thetinylab.cloud

Public website for **theTinyLab** — a FOSS-only homelab run like a small
business. Built with Hugo and a fully custom theme (`themes/tinylab/`).
Static output only: no frameworks, no analytics, no external requests.

Deployed to GitHub Pages by `.github/workflows/pages.yml` on every push to
`main`. The workflow runs a leak-prevention gate (`scripts/leak-check.sh`)
before building — internal infrastructure detail (addresses, subnets, segment
numbers, hostnames, internal service versions) must never enter this repo.

The development source of truth lives in the private `theTinySite` working
repo; this repository is the deployment mirror. Edits belong upstream.
