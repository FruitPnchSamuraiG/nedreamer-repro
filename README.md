# NE-Dreamer Reproducibility

## Project Goal
Reproduce the empirical results of the NE-Dreamer (C1 and C2 figures) on a lab workstation.

## Machine / Date
- **Machine:** 7950x-4090-ws (Ubuntu 24.04)
- **GPU:** 2x RTX 4090 — restricted to physical GPU 1 (`CUDA_VISIBLE_DEVICES=1`)
- **Date:** April 4, 2026

## Current Status
- Software setup complete
- DMLab built from source with patches
- NE-Dreamer environment installed
- Smoke test passed (`rooms_collect_good_objects_train` resets and steps correctly)
- Training reproduction pending

## Constraints
- Single shared GPU (physical GPU 1 only — GPU 0 reserved for another user)
- No sudo access initially — required PI to create `/mnt/data-hdd/hriday/` and install system packages
- Full C1 + C2 reproduction (140 runs × 50M steps) is not feasible on one GPU in one pass
- Planned scope: Phase 1 smoke + sanity run → Phase 2 1 task/1 seed → Phase 3 1-2 tasks/3 seeds

## Current Verdict
> As of April 4, 2026, NE-Dreamer + DeepMind Lab could be installed and smoke-tested on 7950x-4090-ws, but the official DMLab setup path was not reproducible without compatibility patches and dependency pinning.

## Repos
- NE-Dreamer: https://github.com/corl-team/nedreamer
- DeepMind Lab: https://github.com/google-deepmind/lab
- Exact SHAs: see `nedreamer-sha.txt` and `lab-clean-sha.txt`
