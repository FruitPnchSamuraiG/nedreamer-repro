# Results

## Verified Completed

### 1. DMLab smoke test
- Task: `dmlab_rooms_collect_good_objects_train`
- Result: environment reset succeeded, random-action stepping succeeded, no level-loading failure, `smoke_ok` observed

### 2. Short sanity training run
- Task: `dmlab_rooms_collect_good_objects_train`
- Models: `ne_dreamer`, `r2dreamer`
- Result: both models launched, produced W&B runs, created logdirs, completed without crashing

### 3. 120k-step pilot run
- Task: `dmlab_rooms_collect_good_objects_train`
- Model: `ne_dreamer`
- Result: completed successfully, evaluation and training metrics logged
- Note: validates end-to-end execution, not paper-level performance reproduction
- W&B: https://wandb.ai/NE-Dreamer/nedreamer/runs/yu5ycbj0

## Pending / In Progress

### Two-model long comparison
- Task: `dmlab_rooms_collect_good_objects_train`
- Models: `ne_dreamer`, `r2dreamer`
- Seed: `0`
- Budget: `10M` steps each
- Purpose: first constrained C1-style comparison on one shared GPU

## How To Interpret Current Results
Current results show: setup works, DMLab works, NE-Dreamer training loop works, baseline training loop works.
Current results do not yet show: paper-level reproduction, multi-seed robustness, or final comparative conclusions.

## Caveat
Upstream issue `corl-team/nedreamer#1` raises a possible `torch.compile` numerical-stability issue affecting DMLab learning. Any long-run comparison should be interpreted with that caveat unless compile-sensitive behavior is tested explicitly.
