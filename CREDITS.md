# Kredit & sumber asli

Dotfiles ini adalah **gabungan dan modifikasi** dari beberapa proyek open source. Semua hak cipta
tetap milik pembuat aslinya. File lisensi asli disimpan apa adanya di folder masing-masing.

| Komponen | Sumber asli | Pembuat | Lisensi | Lokasi di repo ini |
|---|---|---|---|---|
| **illogical-impulse**: config Hyprland, shell Quickshell `ii`, matugen, fish, kitty, foot, fuzzel, wlogout, Kvantum, fontconfig, dll. | [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) | [@end-4](https://github.com/end-4) dan kontributor | GPL-3.0 | `home/.config/{hypr,quickshell/ii,matugen,fish,...}` |
| **end4-pC**: shell Quickshell yang aktif (fork illogical-impulse) | [pctrade/end4-pC](https://github.com/pctrade/end4-pC) | [@pctrade](https://github.com/pctrade) dan kontributor | GPL-3.0 | `home/.config/quickshell/end4-pC` |
| **rounded-polygon-qmljs**: bentuk widget (bagian dari ii / end4-pC) | [end-4/rounded-polygon-qmljs](https://github.com/end-4/rounded-polygon-qmljs) | [@end-4](https://github.com/end-4) | Apache-2.0 | `.../modules/common/widgets/shapes` |
| **wezterm-config** | [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config) | Kevin Silvester | MIT | `home/.config/wezterm` |
| **Google Sans Flex** (font) | [end-4/google-sans-flex](https://github.com/end-4/google-sans-flex) | Google | SIL OFL 1.1 | `home/.local/share/fonts/illogical-impulse-google-sans-flex` |
| **LazyVim starter**: config Neovim | [LazyVim/starter](https://github.com/LazyVim/starter) | [@folke](https://github.com/folke) | Apache-2.0 | `home/.config/nvim` |
| **micro**: syntax & colorscheme | [cachyos/cachyos-micro-settings](https://github.com/cachyos/cachyos-micro-settings), [micro-editor](https://github.com/zyedidia/micro) | CachyOS, Zachary Yedidia et al. | GPL / MIT | `home/.config/micro` |
| Tema SDDM **qylock** (tidak disertakan, cuma direferensikan) | [Darkkal44/qylock](https://github.com/Darkkal44/qylock) | [@Darkkal44](https://github.com/Darkkal44) | lihat repo | – |

Commit persis yang dipakai tercatat di [`upstream/sources.tsv`](upstream/sources.tsv).

## Mana yang asli, mana yang dimodifikasi?

Repo ini memisahkan keduanya lewat riwayat git (cuma ada branch `main`):

- **Commit berjudul `upstream(<nama>): ...`** berisi salinan *tanpa modifikasi* dari sumber di atas,
  lengkap dengan URL dan commit hash-nya (`git log --grep='^upstream('`).
- **Commit lainnya** adalah modifikasi pribadi di atasnya.

Untuk melihat semua perubahan terhadap aslinya:

```bash
./upstream.sh diff                 # ringkasan semua sumber
./upstream.sh diff end4-pC --full  # isi perubahan untuk satu sumber
```

## Lisensi repo ini

Karena memuat dan memodifikasi karya berlisensi **GPL-3.0** (dots-hyprland dan end4-pC), repo
gabungan ini juga dirilis di bawah **GPL-3.0** (lihat [`LICENSE`](LICENSE)). Bagian yang memakai
lisensi lain (MIT, Apache-2.0, OFL) tetap tunduk pada lisensinya masing-masing; file lisensinya
ada di folder komponen tersebut.

Terima kasih untuk semua pembuat di atas. 🙏
