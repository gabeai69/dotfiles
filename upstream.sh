#!/usr/bin/env bash
# Kelola file dari sumber asli (upstream) di dotfiles ini.
#
# Cara kerjanya:
#   branch `upstream` = file ASLI dari tiap sumber (tidak pernah diedit manual)
#   branch `main`     = upstream + modifikasi kamu
#
#   ./upstream.sh list                  # daftar sumber + commit yang dipakai
#   ./upstream.sh diff [nama] [--full]  # apa saja yang kamu ubah dari aslinya
#   ./upstream.sh update <nama> [ref]   # tarik versi baru dari sumber lalu merge ke main
#                                       # (ref default: branch utama terbaru di upstream)
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSV="$DOTS/upstream/sources.tsv"
CACHE="$HOME/.cache/dotfiles-upstream"
cd "$DOTS"

rows() { grep -vE '^\s*(#|$)' "$TSV" | awk -F'\t' -v n="${1:-}" 'n=="" || $1==n'; }
names() { rows | cut -f1 | awk '!s[$0]++'; }
need_name() { rows "$1" | grep -q . || { echo "Sumber tidak dikenal: $1 (lihat: $0 list)"; exit 1; }; }

# fetch <nama> <ref> -> cetak path clone yang sudah di-checkout ke ref
fetch() {
  local name="$1" ref="$2" url dir
  url="$(rows "$name" | head -1 | cut -f2)"
  dir="$CACHE/$name"
  if [[ ! -d "$dir/.git" ]]; then
    git clone --quiet --filter=blob:none "$url" "$dir" >&2
  fi
  git -C "$dir" fetch --quiet origin >&2
  [[ "$ref" == HEAD ]] && ref="$(git -C "$dir" rev-parse origin/HEAD)"
  git -C "$dir" checkout --quiet --force "$ref" >&2
  git -C "$dir" submodule update --init --recursive --quiet >&2 || true
  echo "$dir"
}

# import <nama> <clone> <worktree>: salin file upstream ke worktree branch upstream
import() {
  local name="$1" clone="$2" wt="$3" src dst
  while IFS=$'\t' read -r _ _ _ s d; do
    src="$clone/$s"; dst="$wt/$d"
    [[ "$s" == "." ]] && src="$clone"
    rm -rf "$dst"; mkdir -p "$(dirname "$dst")"
    if [[ -d "$src" ]]; then
      rsync -a --exclude .git --exclude .gitmodules "$src/" "$dst/"
    else
      cp -a "$src" "$dst"
    fi
  done < <(rows "$name")
}

case "${1:-}" in
  list)
    printf '%-18s %-10s %s\n' NAMA COMMIT URL
    while read -r n; do
      r="$(rows "$n" | head -1)"
      printf '%-18s %-10s %s\n' "$n" "$(cut -f3 <<<"$r" | cut -c1-8)" "$(cut -f2 <<<"$r")"
    done < <(names)
    ;;

  diff)
    shift; name=""; full=0
    for a in "$@"; do [[ "$a" == --full ]] && full=1 || name="$a"; done
    [[ -n "$name" ]] && need_name "$name"
    mapfile -t paths < <(rows "$name" | cut -f5)
    if (( full )); then git diff refs/heads/upstream refs/heads/main -- "${paths[@]}"
    else git diff --stat=120 refs/heads/upstream refs/heads/main -- "${paths[@]}"; fi
    ;;

  update)
    name="${2:?pakai: $0 update <nama> [ref]}"; ref="${3:-HEAD}"
    need_name "$name"
    [[ "$(git branch --show-current)" == main ]] || { echo "Pindah ke branch main dulu."; exit 1; }
    git diff --quiet && git diff --cached --quiet || { echo "Ada perubahan belum di-commit. Jalankan ./save.sh dulu."; exit 1; }

    clone="$(fetch "$name" "$ref")"
    new="$(git -C "$clone" rev-parse HEAD)"
    old="$(rows "$name" | head -1 | cut -f3)"
    [[ "$new" == "$old" ]] && { echo "$name sudah di versi ${new:0:8}."; exit 0; }

    wt="$(mktemp -d)"; trap 'git worktree remove --force "$wt" 2>/dev/null || true' EXIT
    git worktree add --quiet --detach "$wt" refs/heads/upstream
    import "$name" "$clone" "$wt"
    git -C "$wt" add -A
    git -C "$wt" commit --quiet -m "upstream($name): ${old:0:8} -> ${new:0:8}" \
      -m "Sumber asli: $(rows "$name" | head -1 | cut -f2) @ $new" \
      -m "File di commit ini adalah salinan TANPA modifikasi dari sumber di atas." || true
    git update-ref refs/heads/upstream "$(git -C "$wt" rev-parse HEAD)"

    sed -i "s/^\($name\t[^\t]*\t\)$old/\1$new/" "$TSV"
    git add "$TSV"
    git commit --quiet -m "upstream: catat $name @ ${new:0:8}"

    echo "Merge update $name ke main..."
    if git merge --no-edit -m "Merge upstream $name ${new:0:8}" refs/heads/upstream; then
      echo "Berhasil. Cek hasilnya, lalu ./save.sh untuk push."
    else
      echo
      echo "Ada KONFLIK antara modifikasi kamu dan versi baru upstream."
      echo "Edit file yang ditandai (git status), lalu: git add -A && git commit"
      echo "Atau batalkan: git merge --abort"
      exit 1
    fi
    ;;

  _import)  # internal: _import <nama> <worktree>
    need_name "$2"
    import "$2" "$(fetch "$2" "$(rows "$2" | head -1 | cut -f3)")" "$3"
    ;;

  *) sed -n '2,12p' "$0" ;;
esac
