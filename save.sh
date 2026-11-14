#!/usr/bin/env bash
# Simpan perubahan config ke git (dan push kalau ada remote).
#
#   ./save.sh                 # commit dengan pesan otomatis
#   ./save.sh "pesan commit"
#
# Beberapa aplikasi (KDE, fish, dll.) menyimpan file dengan cara menimpa symlink
# jadi file biasa. Script ini mendeteksi itu, menyalin versi terbaru ke repo,
# lalu memasang ulang symlink-nya.
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DOTS/home"

while IFS= read -r rel; do
  [[ -z "$rel" || "$rel" == \#* ]] && continue
  src="$SRC/$rel"; dst="$HOME/$rel"
  [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]] && continue
  [[ -e "$dst" ]] || continue
  echo "sinkron ulang: $rel"
  mkdir -p "$(dirname "$src")"
  if [[ -d "$dst" ]]; then
    rsync -a --delete --exclude .git "$dst/" "$src/"
    rm -rf "$dst"
  else
    cp -a "$dst" "$src"
    rm -f "$dst"
  fi
  ln -s "$src" "$dst"
done < "$DOTS/links.txt"

cd "$DOTS"
git add -A
if git diff --cached --quiet; then
  echo "Tidak ada perubahan."
else
  git commit -q -m "${1:-update dotfiles $(date '+%Y-%m-%d %H:%M') @ $(hostname)}"
  echo "Tersimpan: $(git log -1 --oneline)"
fi
if git remote get-url origin >/dev/null 2>&1; then
  git push -q origin HEAD && echo "Di-push ke $(git remote get-url origin)"
fi
