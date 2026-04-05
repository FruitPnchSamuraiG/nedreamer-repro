#!/usr/bin/env bash
set -euo pipefail
export PROJECT_ROOT=/mnt/data-hdd/hriday
export CUDA_VISIBLE_DEVICES=1
cd "$PROJECT_ROOT/src/nedreamer"
echo "Starting NE-Dreamer run at $(date)"
python train.py \
  env=dmlab_vision \
  env.task=dmlab_rooms_collect_good_objects_train \
  env.action_set=default \
  model.rep_loss=ne_dreamer \
  model.imag_horizon=15 \
  model.horizon_discount=0.85 \
  batch_size=8 \
  trainer.steps=10000000 \
  trainer.eval_every=50000 \
  trainer.update_log_every=2000 \
  seed=0 \
  logdir="$PROJECT_ROOT/logs/rooms_collect_ne_dreamer_s0_10m" \
  2>&1 | tee "$PROJECT_ROOT/logs/rooms_collect_ne_dreamer_s0_10m.console.log"
echo "Finished NE-Dreamer run at $(date)"
echo "Starting R2Dreamer run at $(date)"
python train.py \
  env=dmlab_vision \
  env.task=dmlab_rooms_collect_good_objects_train \
  env.action_set=default \
  model.rep_loss=r2dreamer \
  model.imag_horizon=15 \
  model.horizon_discount=0.85 \
  batch_size=8 \
  trainer.steps=10000000 \
  trainer.eval_every=50000 \
  trainer.update_log_every=2000 \
  seed=0 \
  logdir="$PROJECT_ROOT/logs/rooms_collect_r2dreamer_s0_10m" \
  2>&1 | tee "$PROJECT_ROOT/logs/rooms_collect_r2dreamer_s0_10m.console.log"
echo "All runs finished at $(date)"
