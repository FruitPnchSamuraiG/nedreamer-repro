# NE-Dreamer Reproducibility

## Project Goal
Reproduce the empirical results of the NE-Dreamer paper, focusing first on the DMLab Rooms results corresponding to figures C1 and C2.

## Machine / Date
- Machine: `7950x-4090-ws` (Ubuntu 24.04)
- GPU: 2x RTX 4090
- Restriction: physical GPU 1 only via `CUDA_VISIBLE_DEVICES=1`
- Start date: April 4, 2026

## Current Status
- Software setup complete
- DeepMind Lab built from source with compatibility patches
- NE-Dreamer environment installed
- DMLab smoke test passed on `rooms_collect_good_objects_train`
- Short sanity training runs passed for `ne_dreamer`, `r2dreamer`, `w/o shift`, and `w/o transformer`
- 120k-step pilot run completed
- C1 constrained pilot completed on one task: NE-Dreamer vs R2Dreamer, 10M steps, seed 0
- C2 constrained pilot in progress on one task: full NE-Dreamer reused as reference, plus w/o transformer and w/o shift

## What Is Reproduced So Far
- Setup reproducibility
- Environment/runtime reproducibility
- End-to-end training launch reproducibility
- Short-run training reproducibility on DMLab Rooms
- C1 constrained one-task comparison completed

## What Is Not Yet Reproduced
- Full paper-level C1/C2 empirical reproduction
- Multi-seed statistical comparison
- Multi-task comparison across the full Rooms suite

## Constraints
- Single shared GPU: physical GPU 1 only
- GPU 0 reserved for another user
- No initial sudo access; PI had to create `/mnt/data-hdd/hriday` and install required system packages
- Full C1 + C2 as reported in the paper is too large for a first pass on one shared GPU

## Current Verdict
As of April 5, 2026, NE-Dreamer plus DeepMind Lab can be installed, smoke-tested, and trained end-to-end on `7950x-4090-ws`, but the official DMLab setup path was not reproducible without compatibility patches and dependency pinning.

## Important Caveat: torch.compile
Upstream issue `corl-team/nedreamer#1` reports that `torch.compile` may introduce numerical instability in the TwoHot regression head and materially affect DMLab learning outcomes. Our local runs completed successfully, but result-level claims should still be treated as provisional until compile-sensitive behavior is checked explicitly.

## Repos
- NE-Dreamer: https://github.com/corl-team/nedreamer
- DeepMind Lab: https://github.com/google-deepmind/lab

## Artifacts In This Repo
- `SETUP.md`: exact environment and build steps
- `NOTES.md`: failure chronology and fixes
- `RESULTS.md`: run summary and outcome tracking
- `nedreamer.diff`, `lab-clean.diff`: local patches
- `nedreamer-sha.txt`, `lab-clean-sha.txt`: exact source revisions
- `pip-freeze-nedreamer.txt`, `gpu-info.txt`, `system-info.txt`: environment snapshots
- `run_two_5k_rooms_test.sh`, `run_two_10m_rooms.sh`, `run_two_10m_c2_rooms.sh`: run scripts
