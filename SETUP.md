# Setup Guide

All commands run on 7950x-4090-ws as user `hriday`. No sudo access — data directory created by PI.

## Environment Variables
Add to `~/.bashrc`:
```bash
export PROJECT_ROOT=/mnt/data-hdd/hriday
export CUDA_VISIBLE_DEVICES=1
export PATH="$PROJECT_ROOT/bin:$PATH"
export XDG_CACHE_HOME="$PROJECT_ROOT/.cache"
export PIP_CACHE_DIR="$PROJECT_ROOT/.cache/pip"
export BAZELISK_HOME="$PROJECT_ROOT/.cache/bazelisk"
export TEST_TMPDIR="$PROJECT_ROOT/.cache/bazel_tmp"
export USE_BAZEL_VERSION=7.4.1
export MAMBA_ROOT_PREFIX="$PROJECT_ROOT/micromamba"
```

## Directory Structure
```bash
mkdir -p $PROJECT_ROOT/{src,data,logs,micromamba,bin,.cache/pip,.cache/bazelisk,.cache/bazel_tmp}
```

## Micromamba Install
```bash
curl -L https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C "$PROJECT_ROOT" bin/micromamba
eval "$("$PROJECT_ROOT/bin/micromamba" shell hook -s bash)"
micromamba create -y -n nedreamer python=3.11
micromamba activate nedreamer
```

## NE-Dreamer Install
```bash
cd "$PROJECT_ROOT/src"
git clone https://github.com/corl-team/nedreamer.git
cd nedreamer
# DEVIATION: requirements.txt pins matplotlib==3.5.0 which fails on Python 3.11
# Fix: change to matplotlib==3.8.4
sed -i 's/matplotlib==3.5.0/matplotlib==3.8.4/' requirements.txt
pip install -r requirements.txt
```

## Bazelisk Install (user-local, no sudo)
```bash
curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.17.0/bazelisk-linux-amd64 \
  -o "$PROJECT_ROOT/bin/bazel"
chmod +x "$PROJECT_ROOT/bin/bazel"
# Pin to Bazel 7.4.1 — Bazel 9 is too new for DMLab
export USE_BAZEL_VERSION=7.4.1
bazel version  # should show 7.4.1
```

## DeepMind Lab Build

### System packages required (need sudo — ask PI)
```bash
sudo apt-get install -y \
  build-essential curl freeglut3-dev gettext libffi-dev libglu1-mesa \
  libglu1-mesa-dev libjpeg-dev liblua5.1-0-dev libosmesa6-dev \
  libsdl2-dev lua5.1 pkg-config python3-dev unzip zip zlib1g-dev \
  openjdk-17-jdk
```

### Clone DMLab
```bash
cd "$PROJECT_ROOT/src"
git clone https://github.com/google-deepmind/lab.git lab-clean
cd lab-clean
```

### Patch 1: .bazelrc (disable bzlmod, set Python)
```bash
cat > .bazelrc <<'EOF'
common --noenable_bzlmod
build --python_version=PY3
build --action_env=PYTHON_BIN_PATH=/mnt/data-hdd/hriday/micromamba/envs/nedreamer/bin/python
EOF
```

### Patch 2: Pin abseil-cpp and add rules_cc + bazel_features to WORKSPACE
```bash
python - <<'PY'
from pathlib import Path
p = Path("WORKSPACE")
text = p.read_text()

# Pin abseil-cpp to 20240116.2 (floating master is too new)
old = '''http_archive(
    name = "com_google_absl",
    strip_prefix = "abseil-cpp-master",
    urls = ["https://github.com/abseil/abseil-cpp/archive/master.zip"],
)
'''
new = '''http_archive(
    name = "com_google_absl",
    strip_prefix = "abseil-cpp-20240116.2",
    urls = ["https://github.com/abseil/abseil-cpp/archive/refs/tags/20240116.2.zip"],
)
'''
text = text.replace(old, new)

# Add bazel_features + rules_cc after python_repo block
marker = """python_repo(
    name = "python_system",
    py_version = "PY3",
)
"""
new_tail = marker + """
http_archive(
    name = "bazel_features",
    sha256 = "a660027f5a87f13224ab54b8dc6e191693c554f2692fcca46e8e29ee7dabc43b",
    strip_prefix = "bazel_features-1.30.0",
    url = "https://github.com/bazel-contrib/bazel_features/releases/download/v1.30.0/bazel_features-v1.30.0.tar.gz",
)
load("@bazel_features//:deps.bzl", "bazel_features_deps")
bazel_features_deps()
http_archive(
    name = "rules_cc",
    sha256 = "a2fdfde2ab9b2176bd6a33afca14458039023edb1dd2e73e6823810809df4027",
    strip_prefix = "rules_cc-0.2.14",
    url = "https://github.com/bazelbuild/rules_cc/releases/download/0.2.14/rules_cc-0.2.14.tar.gz",
)
load("@rules_cc//cc:extensions.bzl", "compatibility_proxy_repo")
compatibility_proxy_repo()
"""
text = text.split(marker)[0] + new_tail
p.write_text(text)
print("WORKSPACE patched")
PY
```

### Build
```bash
bazel clean --expunge
bazel build -c opt //:deepmind_lab.so --verbose_failures
bazel build -c opt //python/pip_package:build_pip_package
./bazel-bin/python/pip_package/build_pip_package "$PROJECT_ROOT/data/dmlab_pkg"
python -m pip install --force-reinstall "$PROJECT_ROOT"/data/dmlab_pkg/deepmind_lab-*.whl
```

### Verify
```bash
python -c "import deepmind_lab; print(deepmind_lab.__file__)"
```

## Smoke Test
```bash
export CUDA_VISIBLE_DEVICES=1
cd "$PROJECT_ROOT/src/nedreamer"
python - <<'PY'
from envs.dmlab import DeepMindLabyrinth
import numpy as np
env = DeepMindLabyrinth(
    level="rooms_collect_good_objects_train",
    action_repeat=4,
    size=(64, 64),
    action_set="default",
    mode="train",
    seed=0,
)
obs = env.reset()
print("reset_ok", obs["image"].shape)
for t in range(20):
    obs, reward, done, info = env.step(np.random.randint(env.action_space.n))
    if done:
        break
env.close()
print("smoke_ok")
PY
```
Expected output: `smoke_ok`

## Additional Steps After DMLab Wheel Install

Rename MODULE.bazel files to disable bzlmod:
```bash
mv MODULE.bazel MODULE.bazel.off
mv MODULE.bazel.lock MODULE.bazel.lock.off
```

Fix setuptools and numpy compatibility:
```bash
python -m pip install --force-reinstall "setuptools<81"
python -m pip install --force-reinstall "numpy==1.23.5"
python -c "import deepmind_lab; print(deepmind_lab.__file__)"
```
