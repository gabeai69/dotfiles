# dotfiles — Hyprland (illogical-impulse / end4-pC)

Setup Hyprland milik gabe: shell Quickshell **end4-pC** (fork dari illogical-impulse oleh end-4),
config Hyprland berbasis Lua, wezterm, kitty, foot, fish, starship, nvim, tema Material You (matugen),
Kvantum, wallpaper dan video wallpaper (mpvpaper).

## Install di device baru

Butuh distro berbasis Arch (diuji di CachyOS).

```bash
git clone <URL-REPO-INI> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Yang dilakukan `install.sh`:

1. Menginstall `yay` kalau belum ada.
2. Menginstall semua dependensi illogical-impulse (Hyprland, Quickshell, font, portal, dll.) lewat
   installer resmi [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland), dikunci di commit
   yang cocok dengan config ini. Langkah copy config bawaannya dilewati.
3. Menginstall paket tambahan dari `packages/extra.txt`.
4. Membuat symlink config dari `home/` ke `$HOME` sesuai `links.txt`. Config lama yang bentrok
   dipindah ke `~/.dotfiles-backup/<waktu>/`, jadi tidak ada yang terhapus.

Opsi: `--links-only` (cuma symlink), `--no-deps`, `--no-extra`.

Setelah itu logout, lalu pilih sesi **Hyprland**. Atur monitor dengan `nwg-displays`.

## Menyimpan perubahan

Karena config berupa symlink ke repo ini, setiap perubahan langsung masuk ke `~/dotfiles`.
Untuk commit dan push:

```bash
~/dotfiles/save.sh               # atau: ./save.sh "ganti keybind"
```

Di device lain: `cd ~/dotfiles && git pull`, lalu `./install.sh --links-only` kalau ada file baru.

## Catatan

- **Monitor bersifat per-device.** `hypr/monitors.*` dan `hypr/workspaces.*` tidak di-commit
  (setup asli mematikan `eDP-1`, jadi layar laptop bisa mati kalau ikut terpasang).
- **Username berbeda?** Kalau `$HOME` bukan `/home/gabe`, `install.sh` mengganti path absolut di
  config secara otomatis.
- **API key AI** (OpenRouter, Gemini, dll.) disimpan di keyring, bukan di repo. Isi ulang di
  sidebar setelah install.
- `packages/pacman-full.txt` berisi daftar lengkap paket di mesin asal, cuma sebagai referensi
  (ada kernel/driver AMD khusus CachyOS, jadi tidak diinstall otomatis).
- `quickshell/end4-pC` dan `wezterm` disalin dari repo upstream (berikut perubahan lokal),
  bukan sebagai submodule:
  - end4-pC: https://github.com/pctrade/end4-pC
  - wezterm: https://github.com/KevinSilvester/wezterm-config
- Tema SDDM (qylock, ~1.2 GB) tidak disertakan. Kalau mau:
  `git clone https://github.com/Darkkal44/qylock ~/qylock && cd ~/qylock && ./sddm.sh`
- Hanya video wallpaper yang sedang aktif yang disertakan. Video lain di `~/Videos` tidak ikut
  karena ukurannya besar (salah satunya lebih dari 100 MB, melewati batas GitHub).
