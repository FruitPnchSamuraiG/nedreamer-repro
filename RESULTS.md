# Results

## Verified Completed

### 1. DMLab smoke test
- Task: `dmlab_rooms_collect_good_objects_train`
- Result: environment reset, stepping, and level loading all succeeded. `smoke_ok` observed.

### 2. Short sanity training runs
- Task: `dmlab_rooms_collect_good_objects_train`
- Models: `ne_dreamer`, `r2dreamer`, `w/o shift`, `w/o transformer`
- Result: all launched, produced W&B runs, created logdirs, completed without crashing

### 3. 120k-step pilot run
- Task: `dmlab_rooms_collect_good_objects_train`
- Model: `ne_dreamer`
- Result: completed successfully, metrics logged to W&B
- W&B: https://wandb.ai/NE-Dreamer/nedreamer/runs/yu5ycbj0

### 4. C1 constrained pilot — one task, two models
- Task: `dmlab_rooms_collect_good_objects_train`
- Models: `ne_dreamer`, `r2dreamer`
- Seed: `0`
- Budget: `10M` steps each
- Status: completed
- Note: qualitative trend appears similar to the paper on this task, pending careful analysis

## Pending / In Progress

### 5. C2 constrained pilot — one task, ablations
- Task: `dmlab_rooms_collect_good_objects_train`
- Models:
  - full `ne_dreamer` (reused from C1)
  - `w/o transformer` (`num_layers=0`, local patch required)
  - `w/o shift` (`use_same=True`, `use_next=False`)
- Seed: `0`
- Budget: `10M` steps each
- Status: in progress

## Ablation Implementation Notes
- `w/o shift` maps to `model.ne_dreamer.use_same=True` and `model.ne_dreamer.use_next=False`
- `w/o transformer` required a local patch to `networks.py` — the public repo does not expose this ablation directly via config. Setting `num_layers=0` originally crashed; patch adds a no-transformer fallback path.

## How To Interpret Current Results
Current results show: setup works, DMLab works, training loop works for all models, C1 one-task comparison completed.
Current results do not yet show: paper-level reproduction, multi-seed robustness, or final comparative conclusions.

## Caveat
Upstream issue `corl-team/nedreamer#1` raises a possible `torch.compile` numerical-stability issue affecting DMLab learning. Any long-run comparison should be interpreted with that caveat unless compile-sensitive behavior is tested explicitly.
