#!/usr/bin/env bash
# Installer dotfiles Hyprland (illogical-impulse / end4-pC) milik gabe.
#
#   ./install.sh               # install lengkap: dependensi + paket tambahan + symlink config
#   ./install.sh --links-only  # cuma pasang symlink config (paket sudah terinstall)
#   ./install.sh --no-deps     # lewati dependensi illogical-impulse
#   ./install.sh --no-extra    # lewati paket tambahan (packages/extra.txt)
#
# Aman dijalankan ulang: file lama di-backup ke ~/.dotfiles-backup/<waktu>/
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DOTS/home"
ORIG_HOME="/home/gabe"   # $HOME saat dotfiles ini dibuat
# Versi end-4/dots-hyprland yang cocok dengan config ini (dipakai untuk dependensi).
II_REPO="https://github.com/end-4/dots-hyprland.git"
II_REF="cb1c428bf841dabccff1b126904047c28e89ba8c"
II_DIR="$HOME/.cache/dots-hyprland"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DO_DEPS=1; DO_EXTRA=1
for arg in "$@"; do
  case "$arg" in
    --links-only) DO_DEPS=0; DO_EXTRA=0 ;;
    --no-deps)    DO_DEPS=0 ;;
    --no-extra)   DO_EXTRA=0 ;;
    -h|--help)    sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "Opsi tidak dikenal: $arg"; exit 1 ;;
  esac
done

c() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }
w() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

[[ $EUID -eq 0 ]] && { echo "Jangan jalankan sebagai root."; exit 1; }

# ---------------------------------------------------------------- paket
if (( DO_DEPS || DO_EXTRA )); then
  command -v pacman >/dev/null || { echo "Butuh distro berbasis Arch (pacman)."; exit 1; }
  sudo pacman -S --needed --noconfirm git base-devel
  if ! command -v yay >/dev/null && ! command -v paru >/dev/null; then
    c "Menginstall yay (AUR helper)"
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
  fi
fi
AUR="$(command -v yay || command -v paru || true)"

if (( DO_DEPS )); then
  c "Dependensi illogical-impulse (end-4/dots-hyprland @ ${II_REF:0:8})"
  if [[ ! -d "$II_DIR/.git" ]]; then
    git clone "$II_REPO" "$II_DIR"
  fi
  git -C "$II_DIR" fetch --quiet origin || w "fetch gagal, pakai salinan lokal"
  git -C "$II_DIR" checkout --quiet "$II_REF"
  git -C "$II_DIR" submodule update --init --recursive --quiet || true
  # Step 1 (paket) + step 2 (grup user, service, dll). Step 3 (copy config) dilewati
  # karena config kita sendiri yang dipasang di bawah.
  (cd "$II_DIR" && ./setup install --skip-allfiles)
fi

if (( DO_EXTRA )); then
  c "Paket tambahan (packages/extra.txt)"
  mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$DOTS/packages/extra.txt")
  if [[ -f "$DOTS/packages/aur.txt" ]]; then
    mapfile -t -O "${#pkgs[@]}" pkgs < <(grep -vE '^\s*(#|$)' "$DOTS/packages/aur.txt")
  fi
  (( ${#pkgs[@]} )) && "$AUR" -S --needed --noconfirm "${pkgs[@]}"
fi

# ---------------------------------------------------------------- username lain
if [[ "$HOME" != "$ORIG_HOME" ]]; then
  c "Mengganti path $ORIG_HOME -> $HOME di config"
  grep -rlIZ --exclude-dir=.git "$ORIG_HOME" "$SRC" | xargs -0r sed -i "s|$ORIG_HOME|$HOME|g"
  sed -i "s|^ORIG_HOME=\"$ORIG_HOME\"|ORIG_HOME=\"$HOME\"|" "$DOTS/install.sh"
fi

# ---------------------------------------------------------------- symlink
c "Memasang symlink config"
linked=0
while IFS= read -r rel; do
  [[ -z "$rel" || "$rel" == \#* ]] && continue
  src="$SRC/$rel"; dst="$HOME/$rel"
  [[ -e "$src" ]] || { w "lewati (tidak ada di repo): $rel"; continue; }
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then continue; fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$dst" "$BACKUP/$rel"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "   $rel"; linked=$((linked+1))
done < "$DOTS/links.txt"
echo "   ($linked symlink baru)"
[[ -d "$BACKUP" ]] && w "Config lama di-backup ke: $BACKUP"

# ---------------------------------------------------------------- finishing
command -v fc-cache >/dev/null && fc-cache -f >/dev/null 2>&1 || true
if [[ ! -e "$SRC/.config/hypr/monitors.lua" ]]; then
  : > "$SRC/.config/hypr/monitors.lua"   # per-device, tidak di-commit
  : > "$SRC/.config/hypr/workspaces.lua"
fi
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null; then
  hyprctl reload >/dev/null || true
fi

c "Selesai!"
cat <<EOF
   - Logout, lalu pilih sesi "Hyprland" di login manager.
   - Atur monitor dengan:  nwg-displays   (disimpan per-device, tidak masuk git)
   - Setelah ubah config:  $DOTS/save.sh   (commit + push)
EOF
