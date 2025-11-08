# ARodriguezProjects — Public Portfolio

This repo holds the **sanitization rules** and helper script used to produce public, recruiter-friendly mirrors of private production repos.

## Mirrors
- https://github.com/arod2311/sousan-portfolio
- https://github.com/arod2311/stagealliance-portfolio

## How the mirror works
- Removes secrets and private files (see `.portfolio-redactions.txt`)
- Rewrites sensitive strings to placeholders
- Keeps only the code required to demonstrate structure and quality

## One-liner example
```bash
./mirror.sh ~/projects/repoProjects/sousan \
  git@github-aro:arod2311/sousan-portfolio.git


