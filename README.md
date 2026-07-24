# Mega Man X8 16-bit — mogswe Speedrun Build

This is a modified version of **Mega Man X8 16-bit v1.0.0.9, Tchy & Rose Xorn's Speedrun Version v1.0.0.8**.

This project is a fork of the original [Mega Man X8 16-bit](https://github.com/Tchy258/Mega-Man-X8-16-bit-csharp-version) fangame. No original source code for this speedrun fork survived; this repository was rebuilt by decompiling/recovering the compiled game (via [GDRE Tools](https://github.com/GDRETools/gdsdecomp)) and applying the minimal set of bug fixes documented in [CHANGELOG.md](CHANGELOG.md) so the game runs correctly, both from source and as a standalone Windows build.

**If you are using this for competitive speedrunning: read [CHANGELOG.md](CHANGELOG.md) first.** It documents, in full, every change made relative to the original recovered/decompiled game, specifically so the community can verify that nothing affecting run timing, routing, or gameplay behavior was altered beyond restoring already-broken/non-functional code to its clearly-intended behavior.

## About

Mega Man X8 16-bit is a reimagining of the PS2 original with SNES styled graphics. The aim was to demake X8 in a similar feel to the first three Mega Man X games, while trying to actually finish a low-scope fangame. This fangame is fully playable from start to finish with X and runs on Godot Engine 3.5.

## Credits

- Alysson da Paz - Developer, Pixel Art, Sound Mixing
- LuizMiguel - Consulting and Quality Assurance
- Roberto Carlos Martinez Escudero - Spanish Localization
- Samuel "Streg" Oliveira - Megaman 1 Boss Battle Remix

- LuizMiguel, Medivelion, FadinTV, Megamanx_Zero, Shinobi_Speedruns, Koalacwb64, Vhevert, JandersonSilvaJS, SilverZ - Playtesting

- HeaxDePolo, ZafersanToksoz, QuartoDoDu, KaneTV, JulinhoRockman, itzBruHere, OlimTR, CalebHart42, Nostalgia_Games_BR, Meruziin, Fubadas, BadGokuH, Vubidugil, Fixxer0, Bacaxi15, Xopa, MazaKoopa, Orlandobrx, LuizTeles, Zekinoma - Special Thanks

- Tchy & Rose Xorn - Speedrun Version (v1.0.0.8), the version this build is based on

## Notice

Mega Man X8 16-bit is a free fangame. It is not affiliated, associated, authorized, endorsed or in any way connected with CAPCOM or any of it's subsidiaries or it's affiliates.

Mega Man X and all Mega Man/Rockman material is a property of CAPCOM.
Please support the official release.

## License

This project is licensed under the same terms as the original X8 16-bit project. See [LICENSE.md](LICENSE.md) for the full text. In short: free to use, modify, and distribute, not for monetization, must not be named to imply it's an official/enhanced version, and all credits/license terms must be preserved in derivative works — which this README and LICENSE.md do.

## Building

Requires **Godot Engine 3.5** (this project does not run on Godot 4.x).

1. Open this folder as a project in the Godot 3.5 editor. Godot will re-import the standard asset types automatically (textures, audio, fonts) — this can take a few minutes on first open.
2. To run from source: just press Play in the editor.
3. To export a standalone build: `Project > Export`, using the included `Windows Desktop` preset, or via CLI:
   ```
   Godot_v3.5-stable_win64.exe --path . --export "Windows Desktop" "path/to/output.exe"
   ```

See [CHANGELOG.md](CHANGELOG.md) for known caveats around exporting (specifically, why `.import/` is gitignored and why the `*_baked.scn`/`*_baked.res` files exist alongside stage folders — they are required for exported builds to work at all).
