# Reproduction Notes — Errors and Fixes

Date: April 4, 2026
Machine: 7950x-4090-ws, Ubuntu 24.04, Python 3.11, Bazel 7.4.1

---

## 1. matplotlib==3.5.0 incompatible with Python 3.11
- **Error:** pip install fails on matplotlib 3.5.0
- **Fix:** Changed to matplotlib==3.8.4 in requirements.txt
- **Type:** Upstream deviation — requirements.txt is not pinned to a working version for Python 3.11

---

## 2. Bazel 9.0.1 too new for DMLab
- **Error:** `name 'sh_binary' is not defined` in `python/pip_package/BUILD`
- **Fix:** Pinned `USE_BAZEL_VERSION=7.4.1` via bazelisk
- **Type:** Environment issue — DMLab was written for older Bazel, syntax changed in Bazel 9

---

## 3. bzlmod enabled by default in Bazel 7+
- **Error:** `@@bazel_features` cycle errors, MODULE.bazel conflicts with WORKSPACE
- **Fix:** Added `common --noenable_bzlmod` to `.bazelrc`, renamed MODULE.bazel to MODULE.bazel.off
- **Type:** Environment issue — DMLab uses WORKSPACE mode but Bazel 7 defaults to bzlmod

---

## 4. `rules_cc` not declared in WORKSPACE
- **Error:** `cannot load '@@rules_cc//cc:cc_library.bzl': no such file`
- **Fix:** Added `rules_cc` 0.2.14 + `bazel_features` 1.30.0 to WORKSPACE (bazel_features must come before rules_cc)
- **Type:** Upstream deviation — DMLab WORKSPACE missing explicit rules_cc declaration needed by Bazel 7

---

## 5. abseil-cpp floating master too new
- **Error:** `//visibility:public and //visibility:private cannot be used in combination`
- **Fix:** Pinned `com_google_absl` to `20240116.2` instead of floating `master`
- **Type:** Upstream deviation — DMLab uses floating dependency heads; upstream Abseil broke compatibility

---

## 6. /mnt/data-hdd/hriday did not exist
- **Error:** `Permission denied` when trying to create directory
- **Fix:** Asked PI (Oscar) to create the directory and install system packages
- **Type:** Environment issue — shared machine, no sudo access

---

## 7. torch.compile caveat from upstream issue #1
- **Issue:** `corl-team/nedreamer#1`
- **Claim:** `torch.compile` can break numerical stability in the TwoHot regression head and materially alter DMLab learning behavior
- **Our local observation:** sanity and pilot runs completed successfully, but torch.compile recompilation warnings were observed during training
- **Interpretation:** local execution is valid, but scientific conclusions should remain provisional until compile-sensitive behavior is checked explicitly
- **Type:** Upstream validity risk

---

## 8. deepmind_lab import required older setuptools
- **Error:** `ModuleNotFoundError: No module named 'pkg_resources'`
- **Fix:** `python -m pip install --force-reinstall "setuptools<81"`
- **Type:** Environment / packaging compatibility issue

---

## 9. deepmind_lab import failed with NumPy 2.x
- **Error:** `ImportError: numpy.core.multiarray failed to import`
- **Fix:** `python -m pip install --force-reinstall "numpy==1.23.5"`
- **Type:** Environment / binary compatibility issue

---

## 10. w/o transformer ablation not directly exposed in public config
- **Error:** setting `model.ne_dreamer.num_layers=0` crashed with `IndexError: index 0 is out of range`
- **Fix:** patched `networks.py` so `num_layers==0` skips transformer execution and uses a no-transformer fallback path
- **Type:** Upstream reproducibility gap / local ablation patch

---

## 11. w/o shift ablation mapping
- **Implementation:** `model.ne_dreamer.use_same=True`, `model.ne_dreamer.use_next=False`
- **Interpretation:** removes next-step target shift and predicts same-step embeddings instead
- **Type:** Local reconstruction from public code + paper description
