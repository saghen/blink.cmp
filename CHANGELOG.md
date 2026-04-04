## [1.10.2](https://github.com/saghen/blink.cmp/compare/v1.10.2...v1.10.1) (2026-04-04)

### Features

* add option to make components in column non-operlapping ([3c0bbe2](https://github.com/saghen/blink.cmp/commit/3c0bbe20d5071ca54403447da6aae6ea7a7658de))
* added alignment option to columns ([ace77e2](https://github.com/saghen/blink.cmp/commit/ace77e2a3f153f286a73da7f4f313c8f50a9561d))
* **cmdline:** add & as trigger character for option access ([e8043b8](https://github.com/saghen/blink.cmp/commit/e8043b8f8d696655e8c7cb11a9c17ca90212aa6c))
* use `codegen-units = 1` for release builds ([00987e5](https://github.com/saghen/blink.cmp/commit/00987e5f4e69fbf0ded4759d4c5cc2cb25f83742))
* use lto for release builds ([710c885](https://github.com/saghen/blink.cmp/commit/710c88565a1fa78caa61d5f1b67bb0536a1d3ac7))

### Bug Fixes

* also add gap to width for empty columns ([c9bec7e](https://github.com/saghen/blink.cmp/commit/c9bec7eede788789981ac31d07678401d2d26f03))
* avoid selection race condition with stale context ([#2465](https://github.com/saghen/blink.cmp/issues/2465)) ([130503e](https://github.com/saghen/blink.cmp/commit/130503efc85bd51dcc44dc956c10e5e72c6c9297)), closes [#2464](https://github.com/saghen/blink.cmp/issues/2464)
* **cmdline:** improve guard for nvim_parse_cmd on incomplete input ([2054994](https://github.com/saghen/blink.cmp/commit/20549942e0cfb1c503b2d5d7883c9687858eba9f)), closes [#2462](https://github.com/saghen/blink.cmp/issues/2462)
* documentation/detail checks on vim.NIL ([83fe39a](https://github.com/saghen/blink.cmp/commit/83fe39a3eac1cd09334e3e4eb503e3ea319493ce))
* handle vim.NIL in lsp labelDetails fields ([1e3ca2b](https://github.com/saghen/blink.cmp/commit/1e3ca2b385b33a5ec09c1cea31b0a9af0b69aa28)), closes [#2456](https://github.com/saghen/blink.cmp/issues/2456)
* include dapui buffers on enable exceptions ([#2463](https://github.com/saghen/blink.cmp/issues/2463)) ([da1195d](https://github.com/saghen/blink.cmp/commit/da1195d28372d89d98231686098bc7996c96a2ee))
* **lsp:** handle remaining vim.NIL in LSP responses for nvim 0.12 ([aeb93ca](https://github.com/saghen/blink.cmp/commit/aeb93ca60fa41e0b2ee5041249cafd57fc4a49ab)), closes [#2466](https://github.com/saghen/blink.cmp/issues/2466)
* more instances of vim.NIL on lsp items ([d3f64d2](https://github.com/saghen/blink.cmp/commit/d3f64d27d3dfe02d838e44f24a125446a97ffbbd))
* skip restoring buflisted for problematic filetypes ([ea6ca20](https://github.com/saghen/blink.cmp/commit/ea6ca20f4e1b9720939f658d43429879a927cd82)), closes [neovim/neovim#37832](https://github.com/neovim/neovim/issues/37832)
* skip selection logic for gone context instead of stale ([c676bd7](https://github.com/saghen/blink.cmp/commit/c676bd7acde417a30b875a8a9344784aa2a45e52))
* treat `<C-h>` as backspace in buffer events ([01d7ae8](https://github.com/saghen/blink.cmp/commit/01d7ae8a5639c94bf79295eedc84420f68df39d3)), closes [#2452](https://github.com/saghen/blink.cmp/issues/2452)

### Performance Improvements

* **cmdline:** compute range offset once ([70f9ebc](https://github.com/saghen/blink.cmp/commit/70f9ebc8abfdb6f25bb4ecd28da7fc52eddc61f9))

## [1.10.1](https://github.com/Saghen/blink.cmp/compare/v1.10.0...v1.10.1) (2026-03-14)

### Bug Fixes

* os should be system_info ([#2445](https://github.com/saghen/blink.cmp/issues/2445)) ([19c25fa](https://github.com/saghen/blink.cmp/commit/19c25fa5e95f1387f53b461a425ad2129ed1d681))

## [1.10.0](https://github.com/Saghen/blink.cmp/compare/v1.9.1...v1.10.0) (2026-03-14)

### Highlights

This will be the final 1.x release before 2.0!

- Fuzzy matching now builds on stable Rust!
  - The underlying fuzzy matching library no longer requires nightly: https://github.com/saghen/frizbee
- Added many new prebuilt binary targets (arm64/x86_64 OpenBSD and FreeBSD, arm64 Windows)
- `:h 'formatoptions'` no longer breaks auto insert

### Features

* add aarch64 support on OpenBSD ([#2441](https://github.com/saghen/blink.cmp/issues/2441)) ([be47387](https://github.com/saghen/blink.cmp/commit/be473873b751ab735eacf8b53002a77519d630f7))
* **download:** support glob in `force_version='v*` ([#2408](https://github.com/saghen/blink.cmp/issues/2408)) ([0036d63](https://github.com/saghen/blink.cmp/commit/0036d632b91799456b0e5dd3445737e1e624ead4))
* **health:** display OS/Arch for unsupported system_triple ([#2389](https://github.com/saghen/blink.cmp/issues/2389)) ([694b768](https://github.com/saghen/blink.cmp/commit/694b768d8531bee24a0a364ece300967e7e2cf9d))
* **keymap:** allow scrolling signature window while in snippets ([f9e855c](https://github.com/saghen/blink.cmp/commit/f9e855c4d96e1264f7c818844f5a0166ad48c212))
* **path:** expand env vars enclosed in braces ([#2439](https://github.com/saghen/blink.cmp/issues/2439)) ([816052a](https://github.com/saghen/blink.cmp/commit/816052a3a9676d85cd881e2b8021513422b65289))
* support FreeBSD aarch64 ([#2380](https://github.com/saghen/blink.cmp/issues/2380)) ([b4d3793](https://github.com/saghen/blink.cmp/commit/b4d379393882561f9055abe780342ee00f02c573))
* upgrade to frizbee 0.8.2, drop nightly rust requirement ([#2406](https://github.com/saghen/blink.cmp/issues/2406)) ([9ecf2c7](https://github.com/saghen/blink.cmp/commit/9ecf2c7a89acd0e0cb6b99cb5c17795fc3e84081))

### Bug Fixes

* **buffer:** discard `fs_stat` check for unmodified buffers ([#2398](https://github.com/saghen/blink.cmp/issues/2398)) ([cd79f57](https://github.com/saghen/blink.cmp/commit/cd79f572971c58784ca72551af29af3a63da9168))
* clear context and items on hide from list ([cadd805](https://github.com/saghen/blink.cmp/commit/cadd80502e11fca3d32aaba2c31659a1aaaa1865)), closes [#2355](https://github.com/saghen/blink.cmp/issues/2355)
* **cmdline:** guard against `nvim_parse_cmd` errors for incomplete expr ([658d0ec](https://github.com/saghen/blink.cmp/commit/658d0ec1d93646ff999fe6044098af89d81428ed)), closes [#2428](https://github.com/saghen/blink.cmp/issues/2428)
* **cmdline:** support complex `v:lua` expression ([4730d96](https://github.com/saghen/blink.cmp/commit/4730d9663632e8f1a900cc39a655886dc665f9d4)), closes [#2350](https://github.com/saghen/blink.cmp/issues/2350) [#2418](https://github.com/saghen/blink.cmp/issues/2418)
* completion items after applying preview breaking fuzzy matching ([58100f4](https://github.com/saghen/blink.cmp/commit/58100f4e9c2b25a43c2b45c47ec128f0bcd94336)), closes [#2362](https://github.com/saghen/blink.cmp/issues/2362)
* **context:** include missing line field in get_bounds return value ([32d8520](https://github.com/saghen/blink.cmp/commit/32d8520587f0adc36c8364c9d62ceedd5a0debfc))
* disable auto brackets for objective-c/objective-c++ ([47d8c7d](https://github.com/saghen/blink.cmp/commit/47d8c7d452ae00198625da87042868464796b262)), closes [#1977](https://github.com/saghen/blink.cmp/issues/1977)
* disable auto-wrap during completion to prevent preview undo errors ([#2378](https://github.com/saghen/blink.cmp/issues/2378)) ([d2fcad3](https://github.com/saghen/blink.cmp/commit/d2fcad3f64d4107498bcdf844abb22ebdb562444))
* disable formatoptions 'a' during completion and wrap text around paragraph if and only if it was set ([#2436](https://github.com/saghen/blink.cmp/issues/2436)) ([b09b847](https://github.com/saghen/blink.cmp/commit/b09b8479df03996adb83014d7b76aba2b5a79cc2)), closes [#2432](https://github.com/saghen/blink.cmp/issues/2432)
* **download:** check checksums on OpenBSD with sha256 command ([#2437](https://github.com/saghen/blink.cmp/issues/2437)) ([72c3bc2](https://github.com/saghen/blink.cmp/commit/72c3bc29688c405263569ca1083d862bfc09d4fc))
* **download:** return error for unknown system_triple ([#2392](https://github.com/saghen/blink.cmp/issues/2392)) ([85666c5](https://github.com/saghen/blink.cmp/commit/85666c58d8ed49539794e913fd15f508af2ca8fb)), closes [saghen/blink.cmp#2387](https://github.com/saghen/blink.cmp/issues/2387)
* guard against unsupported system for checksum ([3586996](https://github.com/saghen/blink.cmp/commit/3586996d1d468cd9bea24e534387e9ffd60198f1)), closes [#2401](https://github.com/saghen/blink.cmp/issues/2401)
* hide event receiving empty context ([cb8840b](https://github.com/saghen/blink.cmp/commit/cb8840b3a669e2af24e922ea58b44ccc0b8916ea))
* **path:** expand env vars whose names contain numbers ([#2440](https://github.com/saghen/blink.cmp/issues/2440)) ([ec05b2d](https://github.com/saghen/blink.cmp/commit/ec05b2de21a961157db0c9a19c7e21adf97c320b))
* **plugin:** guard against nil vim.lsp.config\['*'\] ([f85eb62](https://github.com/saghen/blink.cmp/commit/f85eb6252f4c0212be15c6c4213e9af587574cbe)), closes [#2379](https://github.com/saghen/blink.cmp/issues/2379)
* **provider:** prevent E5560 errors during fast events ([685d862](https://github.com/saghen/blink.cmp/commit/685d86211c69430d6429a5126f32a602d489dca9))
* race with no auto show delay, document bug ([11a8888](https://github.com/saghen/blink.cmp/commit/11a88884499d59e18132d1873ad97f842c49d1f5)), closes [#2419](https://github.com/saghen/blink.cmp/issues/2419)
* reload highlights on color scheme change ([#2273](https://github.com/saghen/blink.cmp/issues/2273)) ([8936aee](https://github.com/saghen/blink.cmp/commit/8936aee785533553cb00b6a50f8c8a835ff46fdd))
* restore cursor position after auto-wrap ([#2426](https://github.com/saghen/blink.cmp/issues/2426)) ([e9556f9](https://github.com/saghen/blink.cmp/commit/e9556f9b981f395e22a6bfd69fd5f3008a2a6cd9)), closes [#2378](https://github.com/saghen/blink.cmp/issues/2378)
* **signature:** use `win:set_height` when updating position ([1d6841e](https://github.com/saghen/blink.cmp/commit/1d6841e278c010a6f80ac7095d748e444c1e34f0))

### Performance Improvements

* **buffer:** more performant way to calculate the size of a buffer ([#2396](https://github.com/saghen/blink.cmp/issues/2396)) ([d162ef8](https://github.com/saghen/blink.cmp/commit/d162ef84327a937669b31f7a32dc2971178cc4c2))
* **cmdline:** optimize ex search command lookups ([7c80e36](https://github.com/saghen/blink.cmp/commit/7c80e36023c5499a97e097cb5f229e9b635725a0))

## [1.9.1](https://github.com/Saghen/blink.cmp/compare/v1.9.0...v1.9.1) (2026-02-04)

Minor hotfix updating the `flake.lock` to use the latest rust nightly, fixing the frizbee build for nix users.

## [1.9.0](https://github.com/Saghen/blink.cmp/compare/v1.8.0...v1.9.0) (2025-11-14)

### Features

* add `force` option to accept completions without visual feedback ([3182a89](https://github.com/Saghen/blink.cmp/commit/3182a8963a4d7aca4cc1c49ca079c6ebada18474))
* **cmdline:** match neovim's select behavior for S-Tab ([#2313](https://github.com/Saghen/blink.cmp/issues/2313)) ([37ce860](https://github.com/Saghen/blink.cmp/commit/37ce860d8eeeee92d60b9a72db21e369d97e6a75))
* **cmdline:** support v:lua custom completion ([#2350](https://github.com/Saghen/blink.cmp/issues/2350)) ([2b4d146](https://github.com/Saghen/blink/commit/2b4d146d0221180c8534c1241ac6dbfa4a2e0412))
* **keymaps:** implemented more detailed descriptions ([#2282](https://github.com/Saghen/blink.cmp/issues/2282)) ([20756cf](https://github.com/Saghen/blink/commit/20756cfa7ec395d7799f4ddcaff5a00f297c9a06))
* **nix:** change plugin pname to blink.cmp ([57d900e](https://github.com/Saghen/blink.cmp/commit/57d900e6982f63c7cde689aa06d8af76c8da083e))
* support for FreeBSD x86_64 ([#2326](https://github.com/Saghen/blink.cmp/issues/2326)) ([18712d9](https://github.com/Saghen/blink/commit/18712d9d292dd362067de74d3b54eb90ce860ba9))

### Bug Fixes

* **cmdline:** escape only unquoted args with spaces ([39ce844](https://github.com/Saghen/blink.cmp/commit/39ce844ed96d145c5a96510b0733d14a72481a74)), closes [#2301](https://github.com/Saghen/blink/issues/2301)
* **cmdline:** handle path-like first arguments in `:!` shellcmd ([74967d4](https://github.com/Saghen/blink.cmp/commit/74967d4f9e6bffd4f707493917503e9d9c73e92c)), closes [#2272](https://github.com/Saghen/blink/issues/2272)
* comments ([#2297](https://github.com/Saghen/blink.cmp/issues/2297)) ([3b83374](https://github.com/Saghen/blink/commit/3b83374f982103a9423432e1edbf5c17ef8ca509))
* documentation draw() function crashing on unmodifiable buffer ([#2319](https://github.com/Saghen/blink.cmp/issues/2319)) ([5074242](https://github.com/Saghen/blink/commit/507424257ba992259f2073ac7ec540af506a0899))
* don't clear last_char on transient mode changes ([#2325](https://github.com/Saghen/blink.cmp/issues/2325)) ([b137f63](https://github.com/Saghen/blink/commit/b137f63d89d0285ca76eed12e1923220e0aff8c1)), closes [#2323](https://github.com/Saghen/blink/issues/2323)
* explicitly target temp buffer in dot-repeat ([820f1dd](https://github.com/Saghen/blink.cmp/commit/820f1ddf634ec267412e403711bf74be26cac677)), closes [#2330](https://github.com/Saghen/blink/issues/2330)
* **ghost_text:** ensure display across settings ([b14922e](https://github.com/Saghen/blink.cmp/commit/b14922e5c4b30efe0857256989b72eaf1f14109f))
* **ghost_text:** handle multibyte chars and improve performance ([#2252](https://github.com/Saghen/blink.cmp/issues/2252)) ([73ea297](https://github.com/Saghen/blink/commit/73ea297bc665c936b51797d5a55599536ffee0d8))
* **ghost_text:** prevent highlight blending ([ceed154](https://github.com/Saghen/blink.cmp/commit/ceed1545929b74cf79b5a8950e7c415683bf690b)), closes [#2320](https://github.com/Saghen/blink/issues/2320)
* **keymap:** add missing return in cmdline preset ([716967c](https://github.com/Saghen/blink.cmp/commit/716967ca4a1242f15fb9a4c610098b61a0dec6be))
* **keymap:** assert description defined before checking if fallback ([e72fc44](https://github.com/Saghen/blink.cmp/commit/e72fc4443f2f91e023d0edd168074ba16898e970))
* **keymap:** infinite recursion on fallback ([f631fce](https://github.com/Saghen/blink.cmp/commit/f631fcef4828bf35a1520468971f5420e0b47693)), closes [#2314](https://github.com/Saghen/blink/issues/2314)
* **menu:** always defer menu display through event loop ([5beb962](https://github.com/Saghen/blink.cmp/commit/5beb962fda05ab132617c81d22bc5eb2529b944f)), closes [#1932](https://github.com/Saghen/blink/issues/1932)
* **nix:** specify linker args for the Darwin build ([#2335](https://github.com/Saghen/blink.cmp/issues/2335)) ([1769b62](https://github.com/Saghen/blink/commit/1769b62d5c21803ff655c8deb9314e4a00f6fec5))
* **plugin:** respect user LSP capabilities in init ([7beba91](https://github.com/Saghen/blink.cmp/commit/7beba91fdc61fdc84ea6d6395d614671e609f895)), closes [#2288](https://github.com/Saghen/blink/issues/2288)
* **provider:** make `enabled` flag respect user config properly ([2e4e54b](https://github.com/Saghen/blink.cmp/commit/2e4e54b1283f4cf3673063fc3e10993c20aeec5c)), closes [#2251](https://github.com/Saghen/blink/issues/2251)
* **provider:** respect `min_keyword_length` over global setting ([#2354](https://github.com/Saghen/blink.cmp/issues/2354)) ([e05c91f](https://github.com/Saghen/blink/commit/e05c91f97b7643947e457cf0beef74bc577592bc))
* **signature:** enable trigger after show signature manually ([#2243](https://github.com/Saghen/blink.cmp/issues/2243)) ([7a97c64](https://github.com/Saghen/blink/commit/7a97c642a3ef2566a3b18461d257864ad1dbbb4f))
* **signature:** Update active parameter to use line and col range ([#2296](https://github.com/Saghen/blink.cmp/issues/2296)) ([b6f04e8](https://github.com/Saghen/blink/commit/b6f04e80a0728d81ece2f4adc204141ae84749e0))
* **terminal:** handle `TermRequest` race condition with pcall ([2b6c8dc](https://github.com/Saghen/blink.cmp/commit/2b6c8dc6286b4ddec849a5c1f245614db4d5566a)), closes [#2322](https://github.com/Saghen/blink/issues/2322)
* **text_edits:** only restore buflisted for non-file buffers ([0cd7c4c](https://github.com/Saghen/blink.cmp/commit/0cd7c4cc9b3f47886976ec8ff635d8654aaf6e58)), closes [#2261](https://github.com/Saghen/blink/issues/2261)
* **usercmd:** subcmd completion and error handling ([#2276](https://github.com/Saghen/blink.cmp/issues/2276)) ([f132267](https://github.com/Saghen/blink/commit/f13226770b4947eb7e66befbeb53c3db39f13e25))
* **window:** make popup windows unmodifiable ([#2254](https://github.com/Saghen/blink.cmp/issues/2254)) ([d017b6f](https://github.com/Saghen/blink/commit/d017b6f32669d69918882637931ce7ece5a2b5e8))

## [1.8.0](https://github.com/Saghen/blink.cmp/compare/v1.7.0...v1.8.0) (2025-11-14)

### Highlights

- Frizbee updated to 0.6.0 for [~2x performance boost](https://github.com/saghen/frizbee/pull/43)
- Mostly eliminated overhead while running macros
- Removed `stat` calls and reduced memory usage in path source

### Features

* allow string return in keymap ([#2144](https://github.com/Saghen/blink.cmp/issues/2144)) ([7fc7947](https://github.com/Saghen/blink.cmp/commit/7fc79472833027eb8d8e1a348d139cc66e042893))
* **cmdline:** enable buffer source for grep commands ([1596716](https://github.com/Saghen/blink.cmp/commit/15967164b71142f95a59f59a7ad6e6d57abc320f)), closes [#2251](https://github.com/Saghen/blink.cmp/issues/2251)
* **fuzzy:** allow setting sort list as a function ([#2189](https://github.com/Saghen/blink.cmp/issues/2189)) ([138314a](https://github.com/Saghen/blink.cmp/commit/138314a7bda2d987822b40d824f98624f2c5cd37))

### Bug Fixes

* `blink.cmp.KeymapCommand` type annotations ([#2180](https://github.com/Saghen/blink.cmp/issues/2180)) ([a999ddc](https://github.com/Saghen/blink.cmp/commit/a999ddca2f629faf8a554a8fff904931935a7b1c))
* clamp the start and end lines of the range ([#2177](https://github.com/Saghen/blink.cmp/issues/2177)) ([89c196f](https://github.com/Saghen/blink.cmp/commit/89c196f326b5ea42856eae997191fa7625c2c6eb)), closes [#2170](https://github.com/Saghen/blink.cmp/issues/2170)
* **cmdline:** handle `:=expr` for proper Lua expression completion ([2fcf66a](https://github.com/Saghen/blink.cmp/commit/2fcf66aa31e37d4b443c669ec1bf189530dcbf20))
* **cmdline:** skip filename modifiers detection when using help command ([cb87357](https://github.com/Saghen/blink.cmp/commit/cb87357e93376fbe9b12e60333c7f5788baca057)), closes [#2211](https://github.com/Saghen/blink.cmp/issues/2211)
* **cmdline:** skip handling command separator during path completion ([cc8c9b7](https://github.com/Saghen/blink.cmp/commit/cc8c9b737d9ddc5dd0d9869ca2970a3859be9c5f)), closes [#2192](https://github.com/Saghen/blink.cmp/issues/2192)
* correct usage of 'e.g.' and 'i.e.' in documentation ([1e96a5b](https://github.com/Saghen/blink.cmp/commit/1e96a5bde3fd15ec6cc1013a6828830b3686aa9d))
* disable in macros ([afc4f4d](https://github.com/Saghen/blink.cmp/commit/afc4f4d260af11b248a79c5c8b4f82014f7330f4)), closes [#2161](https://github.com/Saghen/blink.cmp/issues/2161)
* don't modify global &iskeyword ([#2223](https://github.com/Saghen/blink.cmp/issues/2223)) ([8743384](https://github.com/Saghen/blink.cmp/commit/87433840b4d8cce053d6b8cd57f3d75a27c8cd8b))
* ellipsis double width replacement not applied ([#2225](https://github.com/Saghen/blink.cmp/issues/2225)) ([312097b](https://github.com/Saghen/blink.cmp/commit/312097b9e34e45e430d55968cef014b88e6e3549))
* injected per-filetype providers not inheriting default providers ([40380e7](https://github.com/Saghen/blink.cmp/commit/40380e711b616a28affb0f4086a2f7de2f2a556b))
* **luasnip:** only pass `fallback_match` if different from `line_to_cursor` ([a60d8c0](https://github.com/Saghen/blink.cmp/commit/a60d8c0a07a99a8549bc0d74edefc02c47312077))
* **luasnip:** use actual cursor pos for snippet match ([#2206](https://github.com/Saghen/blink.cmp/issues/2206)) ([de2f709](https://github.com/Saghen/blink.cmp/commit/de2f70935d27c3f911fb37dc20ca5aec60956ebc))
* **menu:** add missing loading item properties ([ab1b366](https://github.com/Saghen/blink.cmp/commit/ab1b3661e2b263e3fd305f24bfe4b3d5c2049bc4)), closes [#2](https://github.com/Saghen/blink.cmp/issues/2)
* **nix:** fix Cargo sandbox builds on Darwin via Fenix update ([#2226](https://github.com/Saghen/blink.cmp/issues/2226)) ([d93e01a](https://github.com/Saghen/blink.cmp/commit/d93e01a5570e70830306c265b74699b3a1d38295))
* **snippet:** handle `$VAR` and `${VAR}` variable forms correctly ([a4ab037](https://github.com/Saghen/blink.cmp/commit/a4ab037eefdb9949896ea8553f918bd6250d62bd)), closes [#2212](https://github.com/Saghen/blink.cmp/issues/2212)
* **snippets:** ensure proper espcaping of special chars ([#2239](https://github.com/Saghen/blink.cmp/issues/2239)) ([230ccf8](https://github.com/Saghen/blink.cmp/commit/230ccf84764cac7bd81b002cc76be41cbc4671a8)), closes [#2072](https://github.com/Saghen/blink.cmp/issues/2072) [#2028](https://github.com/Saghen/blink.cmp/issues/2028)
* **snippets:** provide `textEdit` field for builtin snippet ([#2233](https://github.com/Saghen/blink.cmp/issues/2233)) ([2408f14](https://github.com/Saghen/blink.cmp/commit/2408f14f740f89d603cad33fe8cbd92ab068cc92)), closes [#2159](https://github.com/Saghen/blink.cmp/issues/2159)
* stick to vsnip API in vimscript ([#2197](https://github.com/Saghen/blink.cmp/issues/2197)) ([5eb4e7f](https://github.com/Saghen/blink.cmp/commit/5eb4e7fb3d2d5f28303fb558c614569adabff3ac))

### Performance Improvements

* **path:** drop unused stat calls ([2b44b9c](https://github.com/Saghen/blink.cmp/commit/2b44b9cc94d426b355f1c43e4fc25170f1a89948)), closes [#2196](https://github.com/Saghen/blink.cmp/issues/2196)
* **path:** improve async dir scan with chunked callbacks ([#2204](https://github.com/Saghen/blink.cmp/issues/2204)) ([5037cfa](https://github.com/Saghen/blink.cmp/commit/5037cfa645a9c4f5d6e2a3f6a44e096df86c8093)), closes [#2196](https://github.com/Saghen/blink.cmp/issues/2196)
* **path:** limit max entries per directory to 5000 ([5b4055e](https://github.com/Saghen/blink.cmp/commit/5b4055eba7b141096e1bdf7941ff531b2bd98653)), closes [#2196](https://github.com/Saghen/blink.cmp/issues/2196)

## [1.7.0](https://github.com/Saghen/blink.cmp/compare/v1.6.0...v1.7.0) (2025-09-15)

### Highlights

* [Configurable delay](https://cmp.saghen.dev/recipes.html#disable-or-delay-auto-showing-completion-menu) before showing completion menu (`completion.menu.auto_show_delay_ms`)
* Added `:BlinkCmp build` command for building fuzzy matching library from source, primarily for `vim.pack` users building from soruce
* Dropped LMDB in favor of pure Rust implementation for frecency DB, resolving neovim crashing on accepting completions
  * Moved from `~/.local/share/nvim/blink/cmp/fuzzy.db` to `~/.local/state/nvim/blink/cmp/frecency.dat`
* Added support for vsnip via `snippets.preset = 'vsnip'`
* Fixed stutter on `InsertEnter` when using snippets with `TM_SELECTED_TEXT` (such as with `friendly-snippets` in latex)
* Misc cmdline fixes/performance improvements

### Features

* `completion.menu.auto_show_delay_ms` option ([debe907](https://github.com/Saghen/blink.cmp/commit/debe907a5f3e340cf940d6fb47e52cb845992452)), closes [#619](https://github.com/Saghen/blink.cmp/issues/619)
* `scroll_signature_up/down` keymap commands ([#2057](https://github.com/Saghen/blink.cmp/issues/2057)) ([b7e2404](https://github.com/Saghen/blink.cmp/commit/b7e240484affbb62eebb8604ea3d63f88d320f12))
* add `:BlinkCmp build` and `:BlinkCmp build-log` commands ([4c6a29e](https://github.com/Saghen/blink.cmp/commit/4c6a29ef6b527309566bcf1bb90318e36ca9f1f8))
* add `show_and_insert_or_accept_single` keymap, set as `<Tab>` in cmdline ([#2037](https://github.com/Saghen/blink.cmp/issues/2037)) ([a93cdb8](https://github.com/Saghen/blink.cmp/commit/a93cdb8769ac17ffe2abc7196f6ab9e500af1f37)), closes [#2032](https://github.com/Saghen/blink.cmp/issues/2032)
* add `snippet_indicator` option [#2034](https://github.com/Saghen/blink.cmp/issues/2034) ([#2038](https://github.com/Saghen/blink.cmp/issues/2038)) ([5e1c0e8](https://github.com/Saghen/blink.cmp/commit/5e1c0e8d54a266c7b1f629e943c0b360bcd9cd39))
* add `snippets.preset = 'vsnip'` ([#2110](https://github.com/Saghen/blink.cmp/issues/2110)) ([221c3d8](https://github.com/Saghen/blink.cmp/commit/221c3d86ddd0379bd51f4fe43ee7089fd07b7432))
* append-only frecency database, drop LMDB ([#2136](https://github.com/Saghen/blink.cmp/issues/2136)) ([f1c3905](https://github.com/Saghen/blink.cmp/commit/f1c3905d863942aa0b89e621a79b3a3cf2090fd0))
* **brackets:** add css pseudo-class exceptions ([#2054](https://github.com/Saghen/blink.cmp/issues/2054)) ([e3f28f1](https://github.com/Saghen/blink.cmp/commit/e3f28f12e6cc1113129150c069e84761abe8a31d)), closes [#2052](https://github.com/Saghen/blink.cmp/issues/2052)
* **cmdline:** handle ex special characters and filename modifiers ([#2074](https://github.com/Saghen/blink.cmp/issues/2074)) ([f6ca10f](https://github.com/Saghen/blink.cmp/commit/f6ca10fe15579775fd8c02e2d3cc74eaa9824f5e)), closes [#2068](https://github.com/Saghen/blink.cmp/issues/2068)
* **fuzzy:** make frecency database path configurable ([#2061](https://github.com/Saghen/blink.cmp/issues/2061)) ([b8154b4](https://github.com/Saghen/blink.cmp/commit/b8154b444cadc3c32896c27c7814fd4284f83d05)), closes [#2006](https://github.com/Saghen/blink.cmp/issues/2006)
* **keymap:** add `jump_by` option to navigate by item property ([6a84282](https://github.com/Saghen/blink.cmp/commit/6a84282009cdb348899b014d7332e63babd504e4)), closes [#1890](https://github.com/Saghen/blink.cmp/issues/1890)
* **keymap:** add fallback action to <C-e> mapping ([#2064](https://github.com/Saghen/blink.cmp/issues/2064)) ([d9fa997](https://github.com/Saghen/blink.cmp/commit/d9fa997147b7af3699ea6b980bdcf2cb06d1eb32)), closes [#2063](https://github.com/Saghen/blink.cmp/issues/2063)
* **luasnip:** pass matched part of trigger to luasnip. ([#2132](https://github.com/Saghen/blink.cmp/issues/2132)) ([6bceed7](https://github.com/Saghen/blink.cmp/commit/6bceed730e61fb36142ee6ff27358453f324453d))
* remove `item.documentation.render` ([aeba0f0](https://github.com/Saghen/blink.cmp/commit/aeba0f03985c7590d13606ea8ceb9a05c4995d38))
* **snippets:** add option `sources.providers.snippets.opts.use_label_description` ([#2094](https://github.com/Saghen/blink.cmp/issues/2094)) ([34e4483](https://github.com/Saghen/blink.cmp/commit/34e4483b39785a47e90a7826664273354f6d6ae0))

### Bug Fixes

* `:BlinkCmp build` working directory ([5209af5](https://github.com/Saghen/blink.cmp/commit/5209af5881cc795ee492ad4516285db925fdde92))
* add `svelte` to `javascript` auto-brackets `import` exception  ([#2152](https://github.com/Saghen/blink.cmp/issues/2152)) ([5a4461b](https://github.com/Saghen/blink.cmp/commit/5a4461b41ae0f64a17f4f0ffbb852997f2fd6921)), closes [#2151](https://github.com/Saghen/blink.cmp/issues/2151)
* **cmdline:** respect `wildignore` during command-line completion ([dc68824](https://github.com/Saghen/blink.cmp/commit/dc6882469bf3b98e078888f86bb68ad90d395c7e)), closes [#2083](https://github.com/Saghen/blink.cmp/issues/2083)
* **cmdline:** support wildcard completion in `file` ([7b0548e](https://github.com/Saghen/blink.cmp/commit/7b0548e5103e295f465be00b1bb7770c548776c1)), closes [#2106](https://github.com/Saghen/blink.cmp/issues/2106)
* **cmdline:** translate mappings for use with `:map` ([7770a67](https://github.com/Saghen/blink.cmp/commit/7770a67c2cd10d036cbd92ced2fd8b36a6fd29d8)), closes [#2126](https://github.com/Saghen/blink.cmp/issues/2126)
* disable frecency writing when not enabled ([fa9e5fa](https://github.com/Saghen/blink.cmp/commit/fa9e5fa324f8a721a562a7baeba35a0da44ec651)), closes [#2031](https://github.com/Saghen/blink.cmp/issues/2031)
* **fuzzy:** check shared lib existence before skipping download ([#2055](https://github.com/Saghen/blink.cmp/issues/2055)) ([b745bea](https://github.com/Saghen/blink.cmp/commit/b745bea3537b4a28f1976477a3474774c82f10ec)), closes [#2048](https://github.com/Saghen/blink.cmp/issues/2048)
* **ghost_text:** validate buffer before redraw to prevent errors ([#2050](https://github.com/Saghen/blink.cmp/issues/2050)) ([16b6ba0](https://github.com/Saghen/blink.cmp/commit/16b6ba0979756da3a38b936f9800d3479cd8202e)), closes [#1764](https://github.com/Saghen/blink.cmp/issues/1764)
* **keymap:** accept completion when only one item remains ([54cc521](https://github.com/Saghen/blink.cmp/commit/54cc5219b9307a5a261fac6978c1bdce492e8500))
* **keymap:** add fallback action to <C-y> mapping ([c375967](https://github.com/Saghen/blink.cmp/commit/c3759677caa289e6e6b5f37b191007eddefc1d3e))
* libc detection failing on shorter triples ([6d35b78](https://github.com/Saghen/blink.cmp/commit/6d35b7891717b65dcd8488471cc7cd747472d038)), closes [#2040](https://github.com/Saghen/blink.cmp/issues/2040)
* Move runtime inputs to derivation args and add libiconv for macOS compatibility ([#1993](https://github.com/Saghen/blink.cmp/issues/1993)) ([4834ecf](https://github.com/Saghen/blink.cmp/commit/4834ecfc2312b66436803c10acb6310391ddd43e))
* **presets:** add missing `cmdline` preset to hide completion on `<End>` ([#2030](https://github.com/Saghen/blink.cmp/issues/2030)) ([1a5607f](https://github.com/Saghen/blink.cmp/commit/1a5607f90c8804cc13ea94a3ec6ea614141609bf))
* prevent out of bounds scrollbar position ([e465c73](https://github.com/Saghen/blink.cmp/commit/e465c73674fb5fd3ecb7d0dabec195a4a929ee11))
* use table.concat instead of vim.fn.join for provider list ([4e9edba](https://github.com/Saghen/blink.cmp/commit/4e9edba1b1cef1585cc65e54287229e5d34e4df8))
* **window:** clamp highlights to prevent overflow beyond text bounds ([#2049](https://github.com/Saghen/blink.cmp/issues/2049)) ([d73dfcb](https://github.com/Saghen/blink.cmp/commit/d73dfcb488b7cfbfbefe2daa82bbf0bd6b043616))

### Performance Improvements

* **cmdline:** reduce spurious cursor and char events ([#1953](https://github.com/Saghen/blink.cmp/issues/1953)) ([6323a6d](https://github.com/Saghen/blink.cmp/commit/6323a6ddb191323904557dc9b545f309ea2b0e12))
* **snippets:** cache lazy vars when expanding vars ([33f0789](https://github.com/Saghen/blink.cmp/commit/33f0789297cfec5279c30c8f8980c035fdc91e34)), closes [#2024](https://github.com/Saghen/blink.cmp/issues/2024)
* **snippets:** fix previous attempt at caching snippet lazy vars ([ce26f9f](https://github.com/Saghen/blink.cmp/commit/ce26f9fbaa4560440dd981cad1d2e47ae82dd3a6)), closes [#2024](https://github.com/Saghen/blink.cmp/issues/2024)

### Reverts

* Move runtime inputs to derivation args and add libiconv for macOS compatibility ([#1993](https://github.com/Saghen/blink.cmp/issues/1993)) ([a0bcede](https://github.com/Saghen/blink.cmp/commit/a0bcedefce8d74179d0f2401d9915eaaf16974ce)), closes [#2044](https://github.com/Saghen/blink.cmp/issues/2044)

## [1.6.0](https://github.com/Saghen/blink.cmp/compare/v1.5.1...v1.6.0) (2025-07-24)

### Highlights

* Fuzzy matching:
  * Always prefer continuous matches over fuzzy matches (i.e. `foo` on `foobar` beats `f_o_o_bar`) (Change made in v1.5.0 but forgot to mention it)
  * `OFFSET_PREFIX_BONUS` for matching second character, if the first character is not a letter and not matched (i.e. `h` on `_hello`)
  * Lua implementation no longer ignores `score_offset`
* Fixed regression where text after the cursor was not being replaced

### Features

* add `.get_context()` function to API ([6f3ed55](https://github.com/Saghen/blink.cmp/commit/6f3ed55a0b1a298ddf4d00cc50dc66b59865df40))
* add `count` option to `select_next` and `select_prev` ([796a00e](https://github.com/Saghen/blink.cmp/commit/796a00e861a0872ad6452bc8a2faf250abf59117)), closes [#569](https://github.com/Saghen/blink.cmp/issues/569)
* add `OFFSET_PREFIX_BONUS` to lua matcher ([2faf063](https://github.com/Saghen/blink.cmp/commit/2faf06302894c9dc6f6771e2c3a9368194f655af))
* add terminal_command to the completion context ([#2001](https://github.com/Saghen/blink.cmp/issues/2001)) ([b163deb](https://github.com/Saghen/blink.cmp/commit/b163deb174806b5cdb1e7e68bf53e7cf56caea65))
* bump frizbee to 0.5.0 with offset prefix bonus ([b6ea46e](https://github.com/Saghen/blink.cmp/commit/b6ea46efdd219416d837ac48a71fd9df16d71606))
* lazily get `TM_SELECTED_TEXT` for snippets ([04f9f22](https://github.com/Saghen/blink.cmp/commit/04f9f224e4a71b672170f3b73d099b69ce1a7c4e)), closes [#1998](https://github.com/Saghen/blink.cmp/issues/1998)
* **snippet:** support variables in placeholders ([277203b](https://github.com/Saghen/blink.cmp/commit/277203ba10de02770329ac7d59dc8508afc24a39)), closes [#950](https://github.com/Saghen/blink.cmp/issues/950)
* update menu position on selection with dynamic direction priority ([d89b7e4](https://github.com/Saghen/blink.cmp/commit/d89b7e43edc7bdaddb87a6460e2baaef1cff3488)), closes [#2000](https://github.com/Saghen/blink.cmp/issues/2000)

### Bug Fixes

* apply score_offset and snippet.score_offset with lua matcher ([6c1d41e](https://github.com/Saghen/blink.cmp/commit/6c1d41e160b80e0d68a6b3dc50442bd5728b86e7))
* applying score_offset on nil match ([3545f6d](https://github.com/Saghen/blink.cmp/commit/3545f6dce83baacbedfb5dd8d1230cd0492fd1d7))
* **cmdline:** avoid doubling variable scope prefixes in expression ([60f446a](https://github.com/Saghen/blink.cmp/commit/60f446a62d9c3417e8de52f08a0712fcd398711f)), closes [#1994](https://github.com/Saghen/blink.cmp/issues/1994)
* **cmdline:** improve prefix handling to avoid duplication in expression ([af22c52](https://github.com/Saghen/blink.cmp/commit/af22c527a451d162e5229a1eff9283ee840b4bca)), closes [#2005](https://github.com/Saghen/blink.cmp/issues/2005)
* eager error in snippets ([adaff22](https://github.com/Saghen/blink.cmp/commit/adaff226a952acc583f57827bac36afa6a281db0))
* log errors from downloader and fallback to lua ([b812f16](https://github.com/Saghen/blink.cmp/commit/b812f1660b580c3e3f6e7dd666556f8ed955b741)), closes [#1999](https://github.com/Saghen/blink.cmp/issues/1999)
* revert [#1985](https://github.com/Saghen/blink.cmp/issues/1985) "use edit range start for compensation instead of old cursor" ([4663e23](https://github.com/Saghen/blink.cmp/commit/4663e231b70f59a2f413978d4149290e46e4acde)), closes [#2013](https://github.com/Saghen/blink.cmp/issues/2013)

## [1.5.1](https://github.com/Saghen/blink.cmp/compare/v1.5.0...v1.5.1) (2025-07-14)

### Bug Fixes

* add backward compatibility for offset encoding conversion ([02ee0a1](https://github.com/Saghen/blink.cmp/commit/02ee0a164117aa3caf7af80cde3b917ad5effcde)), closes [#1988](https://github.com/Saghen/blink.cmp/issues/1988)

## [1.5.0](https://github.com/Saghen/blink.cmp/compare/v1.4.1...v1.5.0) (2025-07-11)

### Highlights

* ~1.5-3x global speed-up due to dropping `items` on `BlinkCmp*` autocmds
  * You may use `require('blink.cmp').get_items()` instead
* Buffer source rewrite ([#1964](https://github.com/Saghen/blink.cmp/issues/1964))
  * Per-buffer caching for 2-100x speed-up, depending on the number, uniqueness and size of the buffers
  * Added total size cap of 500k chars (`max_total_buffer_size`) with configurable `rentention_order`
* Enable `cmdline` source in `command-line-window` (`q:`)

Thank you @soifou for practically writing the whole release!

### Features

* cache buffer items by changedtick ([5e8165b](https://github.com/Saghen/blink.cmp/commit/5e8165bef3134b2cf95e4a5fd55042bca8753836))
* add `clangd` hack, adding `.lsp_score` to completion items ([ca9019c](https://github.com/Saghen/blink.cmp/commit/ca9019cf9ab801c0818cbc825699b8582c9cb48a)), closes [#1778](https://github.com/Saghen/blink.cmp/issues/1778)
* add blink-cmp-wezterm source ([#1951](https://github.com/Saghen/blink.cmp/issues/1951)) ([a5081e8](https://github.com/Saghen/blink.cmp/commit/a5081e88f983ec229d4f1994b6fbf1ec354bd753))
* add blink-cmp-words to community sources ([#1938](https://github.com/Saghen/blink.cmp/issues/1938)) ([f4ecb69](https://github.com/Saghen/blink.cmp/commit/f4ecb693793cfb210e0dd08ee957c5c1ce806bbc))
* **cmdline:** autoshow for cmdwin ([36de2a7](https://github.com/Saghen/blink.cmp/commit/36de2a72881b00f4cc9abe04c3c9e45ca79bfb1b))
* **cmdline:** enable in `command-line-window` and vim filetype ([78b42f6](https://github.com/Saghen/blink.cmp/commit/78b42f6e59579a814815f4960375fc97cdd34e09)), closes [#1835](https://github.com/Saghen/blink.cmp/issues/1835) [#1447](https://github.com/Saghen/blink.cmp/issues/1447)
* **cmdline:** support `getcompletiontype` for cmdwin ([ec03764](https://github.com/Saghen/blink.cmp/commit/ec03764122b028f1e0f86b885d6ad2ac9ea7cddf))
* drop `BlinkCmpSourceCompletions` ([dc62667](https://github.com/Saghen/blink.cmp/commit/dc62667aa4bdef31ff0ff4700205dff402d5818c))
* prefer continuous matches ([#1888](https://github.com/Saghen/blink.cmp/issues/1888)) ([2096cf1](https://github.com/Saghen/blink.cmp/commit/2096cf158133884738fef07f7b7d5bbf9accc237))

### Bug Fixes

* add racket to blocked filetypes for auto brackets ([f31a46e](https://github.com/Saghen/blink.cmp/commit/f31a46e64b846944da046ed0d6f994afd2ceb7b6)), closes [#1965](https://github.com/Saghen/blink.cmp/issues/1965)
* **cmdline:** `:s`/`:g`/`:v` don't trigger auto completion ([#1956](https://github.com/Saghen/blink.cmp/issues/1956)) ([19a2ba4](https://github.com/Saghen/blink.cmp/commit/19a2ba4517c713dd6df9a958b59ded79cbf9d8fa))
* **cmdline:** avoids unintended prefix duplication of user-defined command ([36ea052](https://github.com/Saghen/blink.cmp/commit/36ea052e1e59d348910e6dae0c65ff6bc301df0b))
* **cmdline:** do not mutate label description for boolean option ([04b8325](https://github.com/Saghen/blink.cmp/commit/04b8325bfa97f99eb3aedde53c77af663746ceb5))
* **cmdline:** improve Vim expression detection and handle custom completions ([fe7c974](https://github.com/Saghen/blink.cmp/commit/fe7c97455a375259a480c496fe3410c52ac004dc))
* **cmdline:** pick last pasted char for completion, not just the first ([#1952](https://github.com/Saghen/blink.cmp/issues/1952)) ([e84b7d9](https://github.com/Saghen/blink.cmp/commit/e84b7d936eb8de042a5fc7c8dabef609dd8e2386)), closes [#1940](https://github.com/Saghen/blink.cmp/issues/1940)
* **cmdline:** prepend prefix for expressions ([c880c77](https://github.com/Saghen/blink.cmp/commit/c880c773298ebabb6d4b0754d039a78082cadf46)), closes [#1939](https://github.com/Saghen/blink.cmp/issues/1939)
* **cmdline:** prevent error when unique prefix for buffer is missing ([644fef3](https://github.com/Saghen/blink.cmp/commit/644fef327d3099fbf3be478735b3b55d9d4b74a3)), closes [#1927](https://github.com/Saghen/blink.cmp/issues/1927)
* **cmdline:** prevent hangs from shellcmd completion on win32/wsl ([#1933](https://github.com/Saghen/blink.cmp/issues/1933)) ([1cc44a3](https://github.com/Saghen/blink.cmp/commit/1cc44a31f02fa54de3c1f89937bf48a2ac59d8eb)), closes [#1926](https://github.com/Saghen/blink.cmp/issues/1926) [#1029](https://github.com/Saghen/blink.cmp/issues/1029)
* **ghost_text:** prevent out-of-bounds on multiline edits ([#1967](https://github.com/Saghen/blink.cmp/issues/1967)) ([f66e22e](https://github.com/Saghen/blink.cmp/commit/f66e22e3003c9dfe2eb7cddb4d314a57e48ac752)), closes [#1197](https://github.com/Saghen/blink.cmp/issues/1197) [#1739](https://github.com/Saghen/blink.cmp/issues/1739)
* handle completion type for even more edge cases ([78a6275](https://github.com/Saghen/blink.cmp/commit/78a6275fca5541610ec14ee9bce61fd55d92c4c6))
* keyword suffix matching and drop leading dash in lua impl ([6c4302b](https://github.com/Saghen/blink.cmp/commit/6c4302b42b0d420a991867fea57c9677a5099155)), closes [#1792](https://github.com/Saghen/blink.cmp/issues/1792)
* **lsp:** filter out text completion items only for lua_ls ([#1979](https://github.com/Saghen/blink.cmp/issues/1979)) ([2f2ebc5](https://github.com/Saghen/blink.cmp/commit/2f2ebc5e007bb72d98dd13e1268af301533acca1)), closes [#1838](https://github.com/Saghen/blink.cmp/issues/1838)
* **luasnip:** avoid false positives for in-snippet detection ([#1969](https://github.com/Saghen/blink.cmp/issues/1969)) ([47820df](https://github.com/Saghen/blink.cmp/commit/47820df10c5ef4bfae585a80f2baea5e90bac11d)), closes [#1805](https://github.com/Saghen/blink.cmp/issues/1805) [#1966](https://github.com/Saghen/blink.cmp/issues/1966)
* minor signature improvements ([#1971](https://github.com/Saghen/blink.cmp/issues/1971)) ([6d6b009](https://github.com/Saghen/blink.cmp/commit/6d6b0092cfe570ade9b183cd53bb1a620290d02b))
* show_signature now ignores trigger.enabled if called directly ([#1946](https://github.com/Saghen/blink.cmp/issues/1946)) ([83e6a29](https://github.com/Saghen/blink.cmp/commit/83e6a29c0bd7dc198d34921d0c41be1eb50d98af))
* signature show failing due to opts not defined ([#1949](https://github.com/Saghen/blink.cmp/issues/1949)) ([dad68b3](https://github.com/Saghen/blink.cmp/commit/dad68b32bc8b91f04b2efd14abc57dd650c51e7e))
* use cmdline config for cmdwin, add wrapper for completion type ([a4e2be4](https://github.com/Saghen/blink.cmp/commit/a4e2be425fe62cd9484a8dfbd7b3c82a8b04e465))
* use edit range start for compensation instead of old cursor ([#1985](https://github.com/Saghen/blink.cmp/issues/1985)) ([d2ca33f](https://github.com/Saghen/blink.cmp/commit/d2ca33f6f2ff7a599e4007e48461340aedc8ae1e)), closes [#1736](https://github.com/Saghen/blink.cmp/issues/1736) [#1978](https://github.com/Saghen/blink.cmp/issues/1978)
* use lsp offset encoding when compensating text edit range ([17e30f3](https://github.com/Saghen/blink.cmp/commit/17e30f35af24545fc2cd8711a0788f49b44c28ff))
* **winborder:** handle custom border chars ([#1984](https://github.com/Saghen/blink.cmp/issues/1984)) ([a946054](https://github.com/Saghen/blink.cmp/commit/a946054f679dcbf60dcf807817cee7bcda05ec6e))

### Performance Improvements

* drop `items` field from autocmds ([ed5472b](https://github.com/Saghen/blink.cmp/commit/ed5472bcb394f5484621fe6ee23004bc48e2448a)), closes [#1752](https://github.com/Saghen/blink.cmp/issues/1752)

## [1.4.1](https://github.com/Saghen/blink.cmp/compare/v1.4.0...v1.4.1) (2025-06-17)

### Features

* revert ignore htmx-lsp client ([#1913](https://github.com/Saghen/blink.cmp/issues/1913)) ([2ce8b3e](https://github.com/Saghen/blink.cmp/commit/2ce8b3e821b2e0b263410929322adeb7dc8684aa))

### Bug Fixes

* `!` prefix completion ([#1912](https://github.com/Saghen/blink.cmp/issues/1912)) ([9c5d823](https://github.com/Saghen/blink.cmp/commit/9c5d82370cf2e5f28c27437f4a88d315ace1844f))
* **cmdline:** correctly handle filetype completions ([c9de9dd](https://github.com/Saghen/blink.cmp/commit/c9de9dd53ec5817138e08c746b9a7a8db403ca24))
* **cmdline:** skip path completion handler when using vim expressions ([9da629b](https://github.com/Saghen/blink.cmp/commit/9da629bd69f79f9c0a79fb38eaad4c86e2527cdc)), closes [#1922](https://github.com/Saghen/blink.cmp/issues/1922)

## [1.4.0](https://github.com/Saghen/blink.cmp/compare/v1.3.1...v1.4.0) (2025-06-15)

### Highlights

- Improved edit range guessing ([#923](https://github.com/Saghen/blink.cmp/issues/923))
  - Clojure and other LSPs which don't send edit ranges should no longer insert the prefix
- Sort in rust when no lua sorts provided (in `fuzzy.sorts` table)
  - Improves performance by ~40% on long lists (i.e. from tailwind)
- Resolved neovim crash on large completions, i.e. from copilot (thank you @otakenz!)
- Major cmdline work by @soifou:
  - Paths no longer contain their prefix (such as in `:e`) and fuzzy match correctly
    - Escaped spaces in paths now work as expcted
  - Shows shortest unique prefix for `:buffer` items
  - Buffer completion on `:s/foo/bar/` and `:g`
    - Due to [an upstream issue](https://github.com/neovim/neovim/pull/9783), requires `providers.buffer.opts.enable_in_ex_commands = true`)
    - Note that this option disables `inccommand`

### Features

* add `!` as cmdline trigger character ([59a58b5](https://github.com/Saghen/blink.cmp/commit/59a58b55eea0255c031a09017341f4917ebd998e))
* add `completion.trigger.show_on_insert` option ([#1796](https://github.com/Saghen/blink.cmp/issues/1796)) ([03c5fea](https://github.com/Saghen/blink.cmp/commit/03c5fea5be494383ca730de30cbb23e40be256b6))
* **buffer:** add configurable sync/async buffer size thresholds ([#1795](https://github.com/Saghen/blink.cmp/issues/1795)) ([d324508](https://github.com/Saghen/blink.cmp/commit/d32450851da0301bee7a063483d20316765aa48d)), closes [#1789](https://github.com/Saghen/blink.cmp/issues/1789)
* **cmdline:** add buffer completion for `:s` and `:g` commands ([#1734](https://github.com/Saghen/blink.cmp/issues/1734)) ([75c9117](https://github.com/Saghen/blink.cmp/commit/75c911751fe97bd3802a1d8ab84801d8678ba179)), closes [#1625](https://github.com/Saghen/blink.cmp/issues/1625)
* **completion.trigger:** add `show_on_backspace_*` options ([#1813](https://github.com/Saghen/blink.cmp/issues/1813)) ([0289534](https://github.com/Saghen/blink.cmp/commit/02895348df97a16274307b71289aeee94f1760b8))
* don't disable signature help when pumvisible ([396f19a](https://github.com/Saghen/blink.cmp/commit/396f19a5e3fc81cf1eacd9e742b7bffe7b14023c))
* **frecency:** use blake3 hash as db key for accesses ([#1908](https://github.com/Saghen/blink.cmp/issues/1908)) ([9c007ae](https://github.com/Saghen/blink.cmp/commit/9c007aeb3d091d332f1a23449760738f0efde039))
* handle multiple filetypes in per_filetype table ([#1798](https://github.com/Saghen/blink.cmp/issues/1798)) ([becda04](https://github.com/Saghen/blink.cmp/commit/becda042731602b8342c261a0cec4176c6959ac3))
* improved edit range guess logic ([5cf9a78](https://github.com/Saghen/blink.cmp/commit/5cf9a786622764f4a8b90735c44e12009ae2e9fc)), closes [#923](https://github.com/Saghen/blink.cmp/issues/923)
* make max_typos optionally a number ([980b09c](https://github.com/Saghen/blink.cmp/commit/980b09c43851245cbcc113ffab89aefdd139c02d))
* sort in rust when no lua sorts provided ([#1830](https://github.com/Saghen/blink.cmp/issues/1830)) ([faee548](https://github.com/Saghen/blink.cmp/commit/faee548ce85c00cc35299fd0dcdac54f5bc5578e)), closes [#1752](https://github.com/Saghen/blink.cmp/issues/1752)
* space instead of autobrackets for lean ([#1825](https://github.com/Saghen/blink.cmp/issues/1825)) ([cd83fee](https://github.com/Saghen/blink.cmp/commit/cd83feedb6f61e84ac7c8c3f1ebd53809faf8ec7))
* update repro.lua with mason ([3e7b05e](https://github.com/Saghen/blink.cmp/commit/3e7b05e89e6a9f4648eb4e0b0d4e0d0446539e5b))
* **window:** support function for `direction_priority` in menu and signature ([#1873](https://github.com/Saghen/blink.cmp/issues/1873)) ([d59d55d](https://github.com/Saghen/blink.cmp/commit/d59d55de59a0a13709b1dc0cbac23f80d4c2c459)), closes [#1801](https://github.com/Saghen/blink.cmp/issues/1801)

### Bug Fixes

* add `fennel` and `jannet` to blocked auto bracket filetypes ([#1804](https://github.com/Saghen/blink.cmp/issues/1804)) ([a434b7b](https://github.com/Saghen/blink.cmp/commit/a434b7b68d30eebe2110a695d1abe3dd7f8e37fb))
* add `ps1` (powershell) to blocked auto bracket filetypes ([#1816](https://github.com/Saghen/blink.cmp/issues/1816)) ([992644b](https://github.com/Saghen/blink.cmp/commit/992644bfaa06ba89baec78672ec199996e21dbaf))
* add dot-repeat hack to terminal mode ([#1788](https://github.com/Saghen/blink.cmp/issues/1788)) ([9873411](https://github.com/Saghen/blink.cmp/commit/98734112c31541410f64473ac1aaa2b1e04933e8))
* add missing comma in configuration examples ([#1867](https://github.com/Saghen/blink.cmp/issues/1867)) ([7370740](https://github.com/Saghen/blink.cmp/commit/737074076292442ac48b2b303bbae6dfbe8f6f4a))
* avoid overlapping signature window with popupmenu ([0fc23d2](https://github.com/Saghen/blink.cmp/commit/0fc23d278ef32b89aa9f3f18f3125ef403e23bae))
* **buffer:** deduplicate words globally ([#1790](https://github.com/Saghen/blink.cmp/issues/1790)) ([c2bac7f](https://github.com/Saghen/blink.cmp/commit/c2bac7fba61e66dfc513cf63daa98546c86a617c)), closes [#1789](https://github.com/Saghen/blink.cmp/issues/1789)
* check for trigger character after semantic token auto brackets ([755bc7e](https://github.com/Saghen/blink.cmp/commit/755bc7eba29ea1e58558d27ec02f5ce6d2c5a386))
* **cmdline:** use current argument for 'file' completion in `input()` prompts ([#1821](https://github.com/Saghen/blink.cmp/issues/1821)) ([92029d3](https://github.com/Saghen/blink.cmp/commit/92029d3c99069d042cf04229dfc1462f13f03d7d)), closes [#1817](https://github.com/Saghen/blink.cmp/issues/1817)
* **completion:** reset `selected_item_idx` on hide to prevent stale selection ([#1860](https://github.com/Saghen/blink.cmp/issues/1860)) ([8cab663](https://github.com/Saghen/blink.cmp/commit/8cab663a36d474634b1b1d3e72118a718a143fcd)), closes [#1856](https://github.com/Saghen/blink.cmp/issues/1856)
* default providers used when filetype specific sources are empty ([3e4a237](https://github.com/Saghen/blink.cmp/commit/3e4a237d63ae7aa2b066c1ed92f1971ca9958c62))
* disable `completion.trigger.show_on_insert`, add to reference ([084439e](https://github.com/Saghen/blink.cmp/commit/084439ea63d3c35d28f4e7938b1bd9214452ad49))
* disabling keymaps in cmdline/term mode not working ([94000bd](https://github.com/Saghen/blink.cmp/commit/94000bd4a18260a37136e012512ae69f57e13c26)), closes [#1855](https://github.com/Saghen/blink.cmp/issues/1855)
* handle delay on `:ts xx` No tags file error ([#1814](https://github.com/Saghen/blink.cmp/issues/1814)) ([fd6e9c6](https://github.com/Saghen/blink.cmp/commit/fd6e9c6b966d7a86ed40db80b6f37994b56326e9))
* **keymap:** disable preset keymaps with `false` ([#1859](https://github.com/Saghen/blink.cmp/issues/1859)) ([0d9a7e4](https://github.com/Saghen/blink.cmp/commit/0d9a7e43e032b4754b97ea35d175a9aa8f0f0bf2)), closes [#1855](https://github.com/Saghen/blink.cmp/issues/1855)
* panic on no matched indices ([bf612a5](https://github.com/Saghen/blink.cmp/commit/bf612a5d221c79843a29e72142261419a5349878)), closes [#1902](https://github.com/Saghen/blink.cmp/issues/1902)
* perform keyword range checks on bytes instead of chars ([30f0a7b](https://github.com/Saghen/blink.cmp/commit/30f0a7b5bfed80c1e4b1f7ba065f5c36db0ce025)), closes [#1834](https://github.com/Saghen/blink.cmp/issues/1834)
* put output values of guess_keyword_range into a table ([#1833](https://github.com/Saghen/blink.cmp/issues/1833)) ([f03e488](https://github.com/Saghen/blink.cmp/commit/f03e488b37b7581c1ab1c642710ccb2beeb194c1))
* rust sorting provider order ([#1880](https://github.com/Saghen/blink.cmp/issues/1880)) ([8d0b89b](https://github.com/Saghen/blink.cmp/commit/8d0b89b60c9f3cd3eac7b48c7da8705fbe99173f)), closes [#1876](https://github.com/Saghen/blink.cmp/issues/1876) [#1846](https://github.com/Saghen/blink.cmp/issues/1846)
* screenpos in floating window due to incorrect winid ([#1853](https://github.com/Saghen/blink.cmp/issues/1853)) ([fe44a7d](https://github.com/Saghen/blink.cmp/commit/fe44a7dade1a975957bc4e1c03abddd4fc2fa603))
* skip useless redraws when not running in Neovide ([#1903](https://github.com/Saghen/blink.cmp/issues/1903)) ([feb34a9](https://github.com/Saghen/blink.cmp/commit/feb34a93a2b36afdebc011b8d15a52288beeed98))
* snippet edit range with lua implementation ([29c8d72](https://github.com/Saghen/blink.cmp/commit/29c8d7267dd73f9b88ae50b169edacf98911f0f6)), closes [#1340](https://github.com/Saghen/blink.cmp/issues/1340)
* use vim.tbl_isempty to check for empty providers table ([7c76cf5](https://github.com/Saghen/blink.cmp/commit/7c76cf55214f838845444637dfdafd2d5f227484))
* **window:** ensure completion buffer is modifiable before rendering ([#1891](https://github.com/Saghen/blink.cmp/issues/1891)) ([024727a](https://github.com/Saghen/blink.cmp/commit/024727a8123dc06e101b0e2323a1a50cb74ecb66)), closes [#1889](https://github.com/Saghen/blink.cmp/issues/1889)
* **window:** hide all blink windows when another completion menu is triggered ([#1852](https://github.com/Saghen/blink.cmp/issues/1852)) ([e7dcfe4](https://github.com/Saghen/blink.cmp/commit/e7dcfe43ac211cca998c734a1a3db53bd0d39ca4)), closes [#1806](https://github.com/Saghen/blink.cmp/issues/1806)

### Performance Improvements

* only check for tailwind colors when doc length = 7 ([02d5e15](https://github.com/Saghen/blink.cmp/commit/02d5e15a5fe3d1ea505052a782dc6f1f0671f5ec)), closes [#1752](https://github.com/Saghen/blink.cmp/issues/1752)

## [1.3.1](https://github.com/Saghen/blink.cmp/compare/v1.3.0...v1.3.1) (2025-05-15)

### Bug Fixes

* **flake:** aarch64 build on nix fails because of jemalloc ([#1759](https://github.com/Saghen/blink.cmp/issues/1759)) ([ef037d0](https://github.com/Saghen/blink.cmp/commit/ef037d0cd90e038c19877b110742cd606b5eeb34))
* only set error notifications to `err` in `nvim_echo` ([#1763](https://github.com/Saghen/blink.cmp/issues/1763)) ([12a530f](https://github.com/Saghen/blink.cmp/commit/12a530f82e2a8f053bd84617267eaa3dc229de0f))
## [1.3.1](https://github.com/Saghen/blink.cmp/compare/v1.3.0...v1.3.1) (2025-05-14)

### Bug Fixes

* **flake:** aarch64 build on nix fails because of jemalloc ([#1759](https://github.com/Saghen/blink.cmp/issues/1759)) ([ef037d0](https://github.com/Saghen/blink.cmp/commit/ef037d0cd90e038c19877b110742cd606b5eeb34))
* only set error notifications to `err` in `nvim_echo` ([#1763](https://github.com/Saghen/blink.cmp/issues/1763)) ([12a530f](https://github.com/Saghen/blink.cmp/commit/12a530f82e2a8f053bd84617267eaa3dc229de0f))

## [1.3.0](https://github.com/Saghen/blink.cmp/compare/v1.2.0...v1.3.0) (2025-05-13)

### Features

* add `signature.trigger.show_on_accept/show_on_accept_on_trigger_character` ([6770a4a](https://github.com/Saghen/blink.cmp/commit/6770a4a888b1a5351aa3475dd0fe80db7663146b)), closes [#1722](https://github.com/Saghen/blink.cmp/issues/1722)
* add extmarks at the start of terminal commands as a utility for creating shell completions ([#1747](https://github.com/Saghen/blink.cmp/issues/1747)) ([584e280](https://github.com/Saghen/blink.cmp/commit/584e2806472c7bb94e9070df62cdf5920ceceae0))
* add message on prebuilt binary download completion ([0a36e07](https://github.com/Saghen/blink.cmp/commit/0a36e07a90dca1fb9717d2aceeba91b3d72c093e))

### Bug Fixes

* get up to date cursor in luasnip execute ([3077615](https://github.com/Saghen/blink.cmp/commit/307761556c48a6b4db62674ae4df42e01317d8b7)), closes [#1740](https://github.com/Saghen/blink.cmp/issues/1740)
* guard against nil triples ([cdbe943](https://github.com/Saghen/blink.cmp/commit/cdbe9436b29788edcecb309a340e905b6b4bbbcb)), closes [#1730](https://github.com/Saghen/blink.cmp/issues/1730)
* lua implementation not respecting `match_suffix` option ([091d09e](https://github.com/Saghen/blink.cmp/commit/091d09e324b05d2a1c84ca51059a62a6703595d2))
* nvim 0.10 compatibility for `nvim_echo` ([#1760](https://github.com/Saghen/blink.cmp/issues/1760)) ([834e419](https://github.com/Saghen/blink.cmp/commit/834e4194e38dd50a801ef4c88d0afc1f0c6dc5a0))
* only use largest range when item is a snippet ([59507fd](https://github.com/Saghen/blink.cmp/commit/59507fd789564365301a9182b1c91982b7a39607))
* treat dash as keyword in lua implementation ([45fcabc](https://github.com/Saghen/blink.cmp/commit/45fcabc4bbd8fb6aa41c25eeb682a66467498fd7)), closes [#1756](https://github.com/Saghen/blink.cmp/issues/1756)
* use `string.buffer` for frecency access ([6dc82a0](https://github.com/Saghen/blink.cmp/commit/6dc82a023ccc3e59112241fa46ba4de4f25b8ee9)), closes [#1627](https://github.com/Saghen/blink.cmp/issues/1627)

## [1.2.0](https://github.com/Saghen/blink.cmp/compare/v1.1.1...v1.2.0) (2025-05-02)

### Highlights

- Fuzzy matcher performance and correctness improvements ([v0.3.0..v0.4.2](https://github.com/Saghen/frizbee/compare/789d5e1...1802a51))
- `sources.per_filetype.*.inherit_defaults` for inheriting from the `default` sources ([docs]())
- `nvim_echo` for fancy notifications and error messages (Thanks @OXY2DEV!)
- Many bug fixes

### Features

* `ignore_root_slash` option for path source ([#1678](https://github.com/Saghen/blink.cmp/issues/1678)) ([5295e6a](https://github.com/Saghen/blink.cmp/commit/5295e6a35025f6955fc68ad2962789e253194540))
* add `completion.menu.draw.cursorline_priority` ([5b11128](https://github.com/Saghen/blink.cmp/commit/5b111287c85abd306f32d6a11408c79331e5a7af))
* add `sources.per_filetype.*.inherit_defaults` to inherit from `default` ([4a1a685](https://github.com/Saghen/blink.cmp/commit/4a1a685b2bdbb9603e75af265a89c1c11c011902)), closes [#1669](https://github.com/Saghen/blink.cmp/issues/1669)
* add bold style for border ([#1687](https://github.com/Saghen/blink.cmp/issues/1687)) ([7856f05](https://github.com/Saghen/blink.cmp/commit/7856f05dd48ea7f2c68ad3cba40202f8a9369b9e))
* begin typing async tasks ([a745202](https://github.com/Saghen/blink.cmp/commit/a745202df1f2cb736c5009223605ad13574e62ec))
* extend tailwind color hack to cssls ([#1594](https://github.com/Saghen/blink.cmp/issues/1594)) ([54c5c9c](https://github.com/Saghen/blink.cmp/commit/54c5c9cc84560971fc93d3bc518bb9ebbc3db541))
* ignore keyword length on trigger character ([#1699](https://github.com/Saghen/blink.cmp/issues/1699)) ([f233029](https://github.com/Saghen/blink.cmp/commit/f233029f79312d1028cbf168a8eef3182bac5a4f))
* option to run select_next/prev when only ghost text is visible ([a5be099](https://github.com/Saghen/blink.cmp/commit/a5be099b0519339bc0d9e2dc96744b55640e810e)), closes [#1572](https://github.com/Saghen/blink.cmp/issues/1572)
* prioritize lowercase over uppercase in `label` sort ([bdb1497](https://github.com/Saghen/blink.cmp/commit/bdb1497c8bb4c331d27e7072420df909c8907f38)), closes [#1642](https://github.com/Saghen/blink.cmp/issues/1642)
* remove 1024 char limit on fuzzy ([7281aed](https://github.com/Saghen/blink.cmp/commit/7281aed98f89cf190a2894f3688701df625fa6a7)), closes [#1473](https://github.com/Saghen/blink.cmp/issues/1473)
* revert show `~` indicator for items which expand as snippets ([39622d1](https://github.com/Saghen/blink.cmp/commit/39622d10c486e1e121963e8bfd8b886b1cf18048))
* set glibc to 2.17 for linux builds ([efa0b4d](https://github.com/Saghen/blink.cmp/commit/efa0b4d94d2dd1e7b572cd9bd83fbf394d60ec4a)), closes [#1482](https://github.com/Saghen/blink.cmp/issues/1482)
* show `~` indicator for items which expand as snippets ([7bf9d6c](https://github.com/Saghen/blink.cmp/commit/7bf9d6c78207f45d74911b63661ff7407c192235)), closes [#1660](https://github.com/Saghen/blink.cmp/issues/1660)
* simplify repro.lua ([ca7e138](https://github.com/Saghen/blink.cmp/commit/ca7e138495b51b6556bb3fd41346341134d26962))
* temporarily disable prefetching ([aace22d](https://github.com/Saghen/blink.cmp/commit/aace22d69cb9091f83b0534d1a6657dcc59736eb)), closes [#1633](https://github.com/Saghen/blink.cmp/issues/1633)
* use `blink-cmp-dot-repeat` filetype for dot repeat buffer ([651a3d4](https://github.com/Saghen/blink.cmp/commit/651a3d4d6a0d3ba6ce1c8be0927471d60478b409)), closes [#1623](https://github.com/Saghen/blink.cmp/issues/1623)
* use `nvim_echo` for emitting errors and notifs ([#1523](https://github.com/Saghen/blink.cmp/issues/1523)) ([695a7ed](https://github.com/Saghen/blink.cmp/commit/695a7edea71a7fa937315eb3391f7f9c7432f100)), closes [#973](https://github.com/Saghen/blink.cmp/issues/973) [#1628](https://github.com/Saghen/blink.cmp/issues/1628)
* use buffer events suppression hach for cmdline events ([596a386](https://github.com/Saghen/blink.cmp/commit/596a386a4af5f047e9c1ce2946a4af52b5a77c8c)), closes [#1649](https://github.com/Saghen/blink.cmp/issues/1649)
* use built-in markdown renderer for documentation ([30f0749](https://github.com/Saghen/blink.cmp/commit/30f0749a6f4c0a38b9da0563fe6ac3752dc07ca6)), closes [#1579](https://github.com/Saghen/blink.cmp/issues/1579)
* use current buffer only in search mode ([dcd783e](https://github.com/Saghen/blink.cmp/commit/dcd783e02308fba03fb0190a4b68d61bfdd9a4eb)), closes [#1592](https://github.com/Saghen/blink.cmp/issues/1592)
* use linebreak on documentation window ([53b2b05](https://github.com/Saghen/blink.cmp/commit/53b2b055f7c641c699ef8c073400c468145be23d)), closes [#1579](https://github.com/Saghen/blink.cmp/issues/1579)

### Bug Fixes

* avoid undefined highlight group 'CmpGhostText' ([#1617](https://github.com/Saghen/blink.cmp/issues/1617)) ([76f11c4](https://github.com/Saghen/blink.cmp/commit/76f11c4934aa0bde55ee806e575e2d54e0d5ba97))
* bump frizbee to 0.4.1 ([c3a5421](https://github.com/Saghen/blink.cmp/commit/c3a54218bc799bd497db4fb7132d60b14b31707a)), closes [#1642](https://github.com/Saghen/blink.cmp/issues/1642) [#1147](https://github.com/Saghen/blink.cmp/issues/1147)
* close dir handle on read failure in path source ([7dc5a6b](https://github.com/Saghen/blink.cmp/commit/7dc5a6bbace7f2032911d61e0f844d8029332bf0))
* **cmdline:** handle error if getcompletion returns an error ([#1700](https://github.com/Saghen/blink.cmp/issues/1700)) ([4e119c5](https://github.com/Saghen/blink.cmp/commit/4e119c560110b362025ec8ec195dd8f5694ea745))
* default sources not being used ([f1efa3b](https://github.com/Saghen/blink.cmp/commit/f1efa3ba3247542c6cd9928e27ba080583caf179))
* disable auto brackets by default for cpp filetype ([#1595](https://github.com/Saghen/blink.cmp/issues/1595)) ([0528949](https://github.com/Saghen/blink.cmp/commit/05289494b7112cb07539c4498925f2e1029b19a3))
* disable auto brackets in typescript imports ([72cdff5](https://github.com/Saghen/blink.cmp/commit/72cdff5cc4fd28afb48371cef1059be668d2b132)), closes [#1609](https://github.com/Saghen/blink.cmp/issues/1609)
* disable Neovide drawing when setting up dot repeat ([#1582](https://github.com/Saghen/blink.cmp/issues/1582)) ([d5943ac](https://github.com/Saghen/blink.cmp/commit/d5943ac41950bcb006dcf2bcea49628b7d6f1852))
* ghost text failing to clear ([84b7b9f](https://github.com/Saghen/blink.cmp/commit/84b7b9fc6ce405df0b62d4259eb1607026dc09ad)), closes [#1581](https://github.com/Saghen/blink.cmp/issues/1581)
* ghost_text preview error on completion cancellation at buffer end ([#1676](https://github.com/Saghen/blink.cmp/issues/1676)) ([11ed30a](https://github.com/Saghen/blink.cmp/commit/11ed30a8db12c53428793de23e0fe5e0b27eb53f))
* inconsistent menu cycling behavior ([efde0c2](https://github.com/Saghen/blink.cmp/commit/efde0c2f5415f9b0d15a202445350fdf00aa7eb3)), closes [#1637](https://github.com/Saghen/blink.cmp/issues/1637)
* **luasnip:** guard against missing callbacks ([fa7ad0a](https://github.com/Saghen/blink.cmp/commit/fa7ad0ac6f2c5ce8b5c7730a384961a2c6e45375)), closes [#1643](https://github.com/Saghen/blink.cmp/issues/1643)
* multi-line snippet indentation when no placeholders ([9ac195c](https://github.com/Saghen/blink.cmp/commit/9ac195c1ca484bf40a4dcae85faff398dd690d0b)), closes [#1635](https://github.com/Saghen/blink.cmp/issues/1635)
* protect against non-empty empty textEdit ([#1601](https://github.com/Saghen/blink.cmp/issues/1601)) ([6cd64bd](https://github.com/Saghen/blink.cmp/commit/6cd64bd9f1b0ee4e49a38b7cfcd155bcef2953ed))
* remove unsupported `params` field from draw highlight type ([7e313f0](https://github.com/Saghen/blink.cmp/commit/7e313f0a2eafd24d1b6bb26378300285adebf23f))
* remove unused keys from mode specific keymaps ([405bd23](https://github.com/Saghen/blink.cmp/commit/405bd23d2362f2405ccb844f5a9f09ac796ab3b4))
* schedule nvim_echo ([#1683](https://github.com/Saghen/blink.cmp/issues/1683)) ([f2e4f6a](https://github.com/Saghen/blink.cmp/commit/f2e4f6aae833c5c2866d203666910005363779d7))
* sending exact and score to lsp ([e08ae37](https://github.com/Saghen/blink.cmp/commit/e08ae37d8f07baac2d6e6ad94159b0c6bc12094d)), closes [#1667](https://github.com/Saghen/blink.cmp/issues/1667)
* serialization issue with draw function ([#1719](https://github.com/Saghen/blink.cmp/issues/1719)) ([d361815](https://github.com/Saghen/blink.cmp/commit/d3618154527d7c894d9825dfe0f5da5997e6b16d))
* **snippets:** strings like `%20` in the register resulting in repeated errors ([#1693](https://github.com/Saghen/blink.cmp/issues/1693)) ([4040d83](https://github.com/Saghen/blink.cmp/commit/4040d836b3826efa06ae778e9195b98b993cfe5b))
* unhandled terminal mode in set_cursor implementation ([#1672](https://github.com/Saghen/blink.cmp/issues/1672)) ([07a09ac](https://github.com/Saghen/blink.cmp/commit/07a09acac1775b95f6fa9e624c9799e1b3bdfdca))
* unify and correct source list type ([#1622](https://github.com/Saghen/blink.cmp/issues/1622)) ([e16586c](https://github.com/Saghen/blink.cmp/commit/e16586c49309c29f238e1068546e7ba64cc15a78))

### Performance Improvements

* mark help tags as complete backwards ([ea29ab1](https://github.com/Saghen/blink.cmp/commit/ea29ab1620de5e61284abc01ae39e56df5a5fe53)), closes [#1538](https://github.com/Saghen/blink.cmp/issues/1538)

## [1.1.1](https://github.com/Saghen/blink.cmp/compare/v1.1.0...v1.1.1) (2025-04-03)

### Bug Fixes

* resolve failing on 0.10 due to missing client wrap ([f3f4bb8](https://github.com/Saghen/blink.cmp/commit/f3f4bb8aac48cd342f74543548bd97d71e3f6343))
## [1.1.1](https://github.com/Saghen/blink.cmp/compare/v1.1.0...v1.1.1) (2025-04-03)

### Bug Fixes

* resolve failing on 0.10 due to missing client wrap ([f3f4bb8](https://github.com/Saghen/blink.cmp/commit/f3f4bb8aac48cd342f74543548bd97d71e3f6343))

## [1.1.0](https://github.com/Saghen/blink.cmp/compare/v1.0.0...v1.1.0) (2025-04-03)

### Highlights

- `<Tab>` now shows the menu when ghost text is visible in cmdline with `noice.nvim`
- Many fixes to menu unexpectedly opening or staying open (i.e. after pressing `<Tab>`)
- `frizbee` (fuzzy matcher) updated to `v0.3.0`
  - Capitals now receive a bonus similar to delimiters, for better matching on PascalCase and camelCase (i.e. `fb` matched on `fooBar` beats `foobar`)
  - Delimiters no longer incorrectly receive a bonus when coming after a delimiter (i.e. `f_b` matched on `foo__bar` no longer beats `foo_bar`)
- Cmdline shell commands have been disabled by default on windows
  - You may re-enable them by overriding the logic with `sources.providers.cmdline.enabled = true`
- [Recipe for kind icon with background](https://cmp.saghen.dev/recipes#kind-icon-background)

### Features

* bump frizbee to 0.3.0 ([46188c1](https://github.com/Saghen/blink.cmp/commit/46188c1092f81b05b777f9f634d509ffaeb53917)), closes [#1147](https://github.com/Saghen/blink.cmp/issues/1147) [#1473](https://github.com/Saghen/blink.cmp/issues/1473)
* **cmdline:** show menu on tab when ghost text visible ([380548f](https://github.com/Saghen/blink.cmp/commit/380548f9820082be5b5a733586b7fe8fd3560fbf))
* configure lua_ls type checking ([c7ceb78](https://github.com/Saghen/blink.cmp/commit/c7ceb78ec51594ee2ce0599bf4fbcd0173e2398c))
* set kind icon default priority to `20000` ([f1e1940](https://github.com/Saghen/blink.cmp/commit/f1e1940a31f4b748559851a7adca43506a55a991))
* support highlight priority for menu draw ([bf2b10e](https://github.com/Saghen/blink.cmp/commit/bf2b10e85fe08ba7891ae72802e818fe9af05f9b))
* use non-deprecated LSP methods when supported ([033fbcc](https://github.com/Saghen/blink.cmp/commit/033fbcc7ec55546aa0c3889aa50b6e76915c3f62))

### Bug Fixes

* cmdline ignoring two cursor moved events after auto insert ([40adb0d](https://github.com/Saghen/blink.cmp/commit/40adb0d6c596d533240a1d3c5e7a66161636104a))
* disable cmdline shell completions on windows by default ([3350451](https://github.com/Saghen/blink.cmp/commit/335045136a8f2924c04aefd13207dd6874df654e)), closes [#1529](https://github.com/Saghen/blink.cmp/issues/1529) [#795](https://github.com/Saghen/blink.cmp/issues/795) [#1167](https://github.com/Saghen/blink.cmp/issues/1167)
* **docs:** show_documentation crashing when documentation is nil ([#1552](https://github.com/Saghen/blink.cmp/issues/1552)) ([6fe420a](https://github.com/Saghen/blink.cmp/commit/6fe420a3d122ff0d613ea2fc4f70cff2eb16e69e))
* ignore prefetch context for cursor moved updates ([a8c5684](https://github.com/Saghen/blink.cmp/commit/a8c5684ba1c996f165ef0956feb90c66d7e8bd81)), closes [#1563](https://github.com/Saghen/blink.cmp/issues/1563) [#1569](https://github.com/Saghen/blink.cmp/issues/1569)
* maintain menu when cursor moves onto trigger character ([61178aa](https://github.com/Saghen/blink.cmp/commit/61178aa4d11bb1d1b74e30921511b025811b983b)), closes [#1559](https://github.com/Saghen/blink.cmp/issues/1559)
* menu position for multibyte characters ([#1573](https://github.com/Saghen/blink.cmp/issues/1573)) ([bd086ef](https://github.com/Saghen/blink.cmp/commit/bd086ef156ca19385114d7bd3a0d870e17dd6800))
* refresh the menu on char after auto insertion ([6f3baea](https://github.com/Saghen/blink.cmp/commit/6f3baea09209c52f552ffd318d6da498716dd90f)), closes [#1568](https://github.com/Saghen/blink.cmp/issues/1568)
* **snippet:** correctly expand luasnip hidden snippet ([#1521](https://github.com/Saghen/blink.cmp/issues/1521)) ([c02a45b](https://github.com/Saghen/blink.cmp/commit/c02a45b3f6ba212789095b9f18e3093683ff5537)), closes [#f0f68](https://github.com/Saghen/blink.cmp/issues/f0f68) [#1503](https://github.com/Saghen/blink.cmp/issues/1503) [#1515](https://github.com/Saghen/blink.cmp/issues/1515)
* **snippet:** keep luasnip item in completion list on exact match ([#1554](https://github.com/Saghen/blink.cmp/issues/1554)) ([623ed75](https://github.com/Saghen/blink.cmp/commit/623ed751616726e78f547cbba19cb6829011da3d)), closes [#1553](https://github.com/Saghen/blink.cmp/issues/1553)
* **trigger:** adjust query bounds logic to handle 0-indexed cursor ([#1559](https://github.com/Saghen/blink.cmp/issues/1559)) ([b83ffad](https://github.com/Saghen/blink.cmp/commit/b83ffad9fb7126d32c2c086bd331f16392f29104)), closes [#1500](https://github.com/Saghen/blink.cmp/issues/1500)
* use max of label, insert_text and filter_text guessed edit ranges ([7d5ddba](https://github.com/Saghen/blink.cmp/commit/7d5ddbae953f42f787a62972f563951f30438eec)), closes [#1340](https://github.com/Saghen/blink.cmp/issues/1340)
* use regular trigger characters for keeping menu open ([6172f8f](https://github.com/Saghen/blink.cmp/commit/6172f8fba999bb83faa532a0bdf5910fcd7041c0))
* **window:** correctly extract `CursorLine` winhiglight ([#1536](https://github.com/Saghen/blink.cmp/issues/1536)) ([e28d61e](https://github.com/Saghen/blink.cmp/commit/e28d61ee057239c437aaa5aa48106c5d4eb303a3)), closes [#1513](https://github.com/Saghen/blink.cmp/issues/1513)

## [1.0.0](https://github.com/Saghen/blink.cmp/compare/v0.14.2...v1.0.0) (2025-03-25)

10 months, 133 contributors and 1214 commits later... blink.cmp is stable! Special thanks to:

- @stefanboca for writing blink.compat and extensive work on frizbee
- @soifou for maintaining the repo and carrying the luasnip source
- @scottmckendry who 
- @mikavilpas + @xzbdmw for implementing dot-repeat support
- [And many more!](https://github.com/Saghen/blink.cmp?tab=readme-ov-file#special-thanks)

### Features

* reduce snippet score offset from -6 to -4 ([62317cb](https://github.com/Saghen/blink.cmp/commit/62317cb002411a9784b0a8c10f5ef093bdfd6fdf))

### Bug Fixes

* disable completions when `vim.b.completion` is false ([79545c3](https://github.com/Saghen/blink.cmp/commit/79545c371ab08cf4563fffb9f5c7a7c9e8fbc786))
* disable in dap-repl if user disabled ([0153b5b](https://github.com/Saghen/blink.cmp/commit/0153b5b0e0ae9a5298060fd7588af35f6168d9b2)), closes [#1495](https://github.com/Saghen/blink.cmp/issues/1495)
* frecency db not updating ([ccdef85](https://github.com/Saghen/blink.cmp/commit/ccdef85a32a674f0cbe60c9e2c055b76f9379f76))

## [0.14.2](https://github.com/Saghen/blink.cmp/compare/v0.14.1...v0.14.2) (2025-03-24)

### Features

* completions in dap-repl by default, document `enabled` behavior ([51d3ad4](https://github.com/Saghen/blink.cmp/commit/51d3ad4ae11b8b981da89759f5a5ee6578971cb2)), closes [#1492](https://github.com/Saghen/blink.cmp/issues/1492)
* **keymap:** allow to override `inherit` preset with user keymaps ([#1483](https://github.com/Saghen/blink.cmp/issues/1483)) ([2477442](https://github.com/Saghen/blink.cmp/commit/247744293512c852f6932982126a0bf118f4a2ad)), closes [#1479](https://github.com/Saghen/blink.cmp/issues/1479)

### Bug Fixes

* add bracket exception for `except` statements in python ([2a5a6da](https://github.com/Saghen/blink.cmp/commit/2a5a6da63f0236e7c3d89449cec2dea6d0391325)), closes [#1188](https://github.com/Saghen/blink.cmp/issues/1188)
* **cmdline:** separetely caculate start_pos for `:=xx` ([#1488](https://github.com/Saghen/blink.cmp/issues/1488)) ([873512b](https://github.com/Saghen/blink.cmp/commit/873512b79cda43a35a9f68ca8d7d541e2b9b69d6))
* **fuzzy:** truncate length of `filter_text` to 512 ([#1475](https://github.com/Saghen/blink.cmp/issues/1475)) ([cb15a0f](https://github.com/Saghen/blink.cmp/commit/cb15a0fe998e53c5b2a1041467b6342450a4a5a0))
* use only first line for preview ([e843b91](https://github.com/Saghen/blink.cmp/commit/e843b9100baa435c989c9ba6540e91091b7cbfe6)), closes [#1477](https://github.com/Saghen/blink.cmp/issues/1477)

### Performance Improvements

* lookup rather than iteration one by one ([#1490](https://github.com/Saghen/blink.cmp/issues/1490)) ([61636a2](https://github.com/Saghen/blink.cmp/commit/61636a2630acd4a0b5711f684509cb8b3e78941c))

## [0.14.1](https://github.com/Saghen/blink.cmp/compare/v0.14.0...v0.14.1) (2025-03-20)

### Features

* allow overriding default enable conditions ([32ac556](https://github.com/Saghen/blink.cmp/commit/32ac556f63e6e368351c0e9736fddf2f80315eac))
* draw cursor line background above other highlights ([a026b8d](https://github.com/Saghen/blink.cmp/commit/a026b8db7f8ab0e98b9a2e0a7a8d7a7b73410a27)), closes [#1254](https://github.com/Saghen/blink.cmp/issues/1254) [#1371](https://github.com/Saghen/blink.cmp/issues/1371)
* support `vim.o.winborder` ([768e6cc](https://github.com/Saghen/blink.cmp/commit/768e6cce4da9cbb5e686c3f7f0324836f344062e)), closes [#1462](https://github.com/Saghen/blink.cmp/issues/1462)
* use fixed nightly rust version for release only ([6f9d669](https://github.com/Saghen/blink.cmp/commit/6f9d669a9464953bc116548bc104cb8cc7fc4c16))

### Bug Fixes

* `padded` border type passed to `nvim_open_win` ([13ce441](https://github.com/Saghen/blink.cmp/commit/13ce441233e48d186eb10abb7c830700304cf361))
* cursor line hl name from existing cursor line hl ([f86f162](https://github.com/Saghen/blink.cmp/commit/f86f1628b4d295384a017cc89e4f46aaf2298e36))
* **download:** handle first-time loading issue of rust lua module ([#1472](https://github.com/Saghen/blink.cmp/issues/1472)) ([40a9786](https://github.com/Saghen/blink.cmp/commit/40a97868b94fb88946b0fe018ec68392ff3a3ef5)), closes [#38a234e9](https://github.com/Saghen/blink.cmp/issues/38a234e9) [#1471](https://github.com/Saghen/blink.cmp/issues/1471)
* **luasnip:** use `cursor` to locate `clear_region.to` ([#1459](https://github.com/Saghen/blink.cmp/issues/1459)) ([0a56a23](https://github.com/Saghen/blink.cmp/commit/0a56a2337dad26c78183ef2a83df5fcbcf59fd00))
* pcall getting vim.o.winborder ([c1407e0](https://github.com/Saghen/blink.cmp/commit/c1407e04c6c51ce9e35d3ba37e59e6634014d6de))
* **scrollbar:** explicitly set border to 'none' ([#1461](https://github.com/Saghen/blink.cmp/issues/1461)) ([1825d4d](https://github.com/Saghen/blink.cmp/commit/1825d4dbdfa6d78fcc445e1268047757800b853f))
* semantic token auto brackets running when disabled, and vice versa ([5b1d349](https://github.com/Saghen/blink.cmp/commit/5b1d3498b13c9321c4ed862a217889a22fc3e565)), closes [#1465](https://github.com/Saghen/blink.cmp/issues/1465)

## [0.14.0](https://github.com/Saghen/blink.cmp/compare/v0.13.1...v0.14.0) (2025-03-18)

### Highlights

- The `enabled` option now includes `vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false` and mode checks internally
  - When replacing this option, you no longer need to include those checks
- `sources.providers[id].name` is no longer required, and defaults to the `id` capitalized
  - For example, `id = buffer` will default to `name = Buffer`)

### BREAKING CHANGES

* use default sources when dynamically adding filetype sources
* apply default and mode specific rules to `enabled` by default
* require sources to explicitly use default accept implementation
* allow creating generic sources for `complete-functions` (#1351)

### Features

* add `'inherit'` keymap preset for modes ([e58c130](https://github.com/Saghen/blink.cmp/commit/e58c130e0de93f374037076981b8cae19887cdc6)), closes [#1327](https://github.com/Saghen/blink.cmp/issues/1327)
* add `insert_prev/next` commands and `is_active` API ([0a7f700](https://github.com/Saghen/blink.cmp/commit/0a7f7002e89a2cadd20c99e78ced3cb9167b2497)), closes [#1367](https://github.com/Saghen/blink.cmp/issues/1367)
* add `nu` to blocked auto bracket filetypes ([ef9d861](https://github.com/Saghen/blink.cmp/commit/ef9d861952bfe29d096c993d4bd69576e09447fe)), closes [#1383](https://github.com/Saghen/blink.cmp/issues/1383)
* allow creating generic sources for `complete-functions` ([#1351](https://github.com/Saghen/blink.cmp/issues/1351)) ([02136c1](https://github.com/Saghen/blink.cmp/commit/02136c182f93b7f3bd8d8b0a745b4d3abc95ce5c))
* apply default and mode specific rules to `enabled` by default ([23c2afa](https://github.com/Saghen/blink.cmp/commit/23c2afa1fa0b8082659b6c696b69bfe5f0cff49b))
* default `source.providers[id].name` to source id capitalized ([6ded22a](https://github.com/Saghen/blink.cmp/commit/6ded22acedb222370c88a386ca47bf7a4e68310f)), closes [#1353](https://github.com/Saghen/blink.cmp/issues/1353)
* don't trigger when CursorMoved onto trigger character ([be15af8](https://github.com/Saghen/blink.cmp/commit/be15af8ce2e643f7fd8d2f51820c243d3c54a013))
* enable cmdline in cmdline mode only ([6a98990](https://github.com/Saghen/blink.cmp/commit/6a989902c9227227729ee5dd602b5577c28f96fc)), closes [#1405](https://github.com/Saghen/blink.cmp/issues/1405)
* force update_delay_ms to >= 50 ([cf0c7e3](https://github.com/Saghen/blink.cmp/commit/cf0c7e37f391c8a6e430cb7d9cdee1f440d1bd7c)), closes [#1352](https://github.com/Saghen/blink.cmp/issues/1352)
* handle large buf text completion with pure lua ([#1394](https://github.com/Saghen/blink.cmp/issues/1394)) ([8e744eb](https://github.com/Saghen/blink.cmp/commit/8e744eb176fd79c3e410fd3b8aeedd3b55e7bf3c))
* ignore htmx-lsp client (hack) ([d5aa7f4](https://github.com/Saghen/blink.cmp/commit/d5aa7f455a41f483051db12aedb0ce9bafde6786)), closes [#825](https://github.com/Saghen/blink.cmp/issues/825)
* **keymap:** toggle signature help window in snippet ([#1411](https://github.com/Saghen/blink.cmp/issues/1411)) ([86d7cd6](https://github.com/Saghen/blink.cmp/commit/86d7cd6f3a0debf6bcb5a2187ea019214a62f2ff))
* only check cmdline cursor position when in cmdline mode ([8a17009](https://github.com/Saghen/blink.cmp/commit/8a170091a67e3fb521f86e0334fc3b996591e1ec)), closes [#1355](https://github.com/Saghen/blink.cmp/issues/1355)
* require sources to explicitly use default accept implementation ([c5ca0f2](https://github.com/Saghen/blink.cmp/commit/c5ca0f2acd46c574a9926d7262c9662e237c5b4f))
* **snippet:** add opt-in `prefer_doc_trig` for luasnip regex trigger ([#1426](https://github.com/Saghen/blink.cmp/issues/1426)) ([d3607d2](https://github.com/Saghen/blink.cmp/commit/d3607d2daa4fd4f06e8f9c22e1b2a272fdd7fc30)), closes [#1373](https://github.com/Saghen/blink.cmp/issues/1373)
* support `triggerParameterHints` and `triggerSuggest` LSP client commands ([4ed2fa7](https://github.com/Saghen/blink.cmp/commit/4ed2fa70752c89688917924a1c7fbdae008e36ee)), closes [#1333](https://github.com/Saghen/blink.cmp/issues/1333)
* use builtin neovim semantic token api ([#1186](https://github.com/Saghen/blink.cmp/issues/1186)) ([bf810eb](https://github.com/Saghen/blink.cmp/commit/bf810ebe1251dfa756c7fa328e56b0c2e157d313)), closes [#187](https://github.com/Saghen/blink.cmp/issues/187)
* use default sources when dynamically adding filetype sources ([183dd14](https://github.com/Saghen/blink.cmp/commit/183dd1468a3a943f16735a671a2983db8f50c504)), closes [#1217](https://github.com/Saghen/blink.cmp/issues/1217)

### Bug Fixes

* buffer source using rust matcher during async ([bf8ee3a](https://github.com/Saghen/blink.cmp/commit/bf8ee3a687a6b99f0bdb65a27a3ba6fcf0012192)), closes [#1346](https://github.com/Saghen/blink.cmp/issues/1346)
* bypass prebuilt binary download on nix ([6c83ef1](https://github.com/Saghen/blink.cmp/commit/6c83ef1ae34abd7ef9a32bfcd9595ac77b61037c)), closes [#1334](https://github.com/Saghen/blink.cmp/issues/1334)
* check if frizzbee shared library exists ([#1417](https://github.com/Saghen/blink.cmp/issues/1417)) ([bfa1aea](https://github.com/Saghen/blink.cmp/commit/bfa1aea2cc8754db36729f32d669bb855037eb9f)), closes [#1410](https://github.com/Saghen/blink.cmp/issues/1410)
* **cmdline:** correctly handle bulk deletions in nvim < 0.11 ([#1427](https://github.com/Saghen/blink.cmp/issues/1427)) ([3900772](https://github.com/Saghen/blink.cmp/commit/39007722d159372489e5051258ba7cc7f336a1b9)), closes [#1369](https://github.com/Saghen/blink.cmp/issues/1369)
* **cmdline:** handle boolean options and improve file completion ([#1399](https://github.com/Saghen/blink.cmp/issues/1399)) ([43687e3](https://github.com/Saghen/blink.cmp/commit/43687e3b780f7537b1af78d65b5f4504b93274bc)), closes [#1366](https://github.com/Saghen/blink.cmp/issues/1366)
* disable binary checks when version file missing ([bcae807](https://github.com/Saghen/blink.cmp/commit/bcae8076af3aba729f4eeb2940c6b5dc45304085)), closes [#1376](https://github.com/Saghen/blink.cmp/issues/1376) [#1364](https://github.com/Saghen/blink.cmp/issues/1364)
* downloader never downloading if version and library missing ([38a234e](https://github.com/Saghen/blink.cmp/commit/38a234e9050b4f3e740545365246ec9181205c04))
* drop `client_name` from LSP item when resolving ([e66e50e](https://github.com/Saghen/blink.cmp/commit/e66e50e99e735ebee0434567c091068f131ef853)), closes [#1347](https://github.com/Saghen/blink.cmp/issues/1347)
* ensure noice never required in cmdline ([9645614](https://github.com/Saghen/blink.cmp/commit/96456149ebe4b6c74aa8efbec37e536561270990)), closes [#1406](https://github.com/Saghen/blink.cmp/issues/1406) [#1396](https://github.com/Saghen/blink.cmp/issues/1396)
* **ghost-text:** check buffer valid before deleting extmark ([273bb36](https://github.com/Saghen/blink.cmp/commit/273bb364d8601dd72ca0b657079f4624bc76c3af)), closes [#1378](https://github.com/Saghen/blink.cmp/issues/1378)
* handle blob-type in documentation height computation ([#1384](https://github.com/Saghen/blink.cmp/issues/1384)) ([becb5d4](https://github.com/Saghen/blink.cmp/commit/becb5d4256bedc9cba2b68cfa611f8c82f93795e)), closes [#1320](https://github.com/Saghen/blink.cmp/issues/1320)
* improve luasnip integration and expand functionality ([#1375](https://github.com/Saghen/blink.cmp/issues/1375)) ([f0f68a1](https://github.com/Saghen/blink.cmp/commit/f0f68a1df964dd146abb6f524b6c055ccd7893c5))
* incorrect initial trigger character ([6eea1bb](https://github.com/Saghen/blink.cmp/commit/6eea1bb18771128b68000eb6d7e4ac26249db35e))
* list selection cycling with preselect = false ([62c0532](https://github.com/Saghen/blink.cmp/commit/62c05326fe2943d1a25e9d8a6113c5f54c1e8586))
* lsp client command names ([36a8b30](https://github.com/Saghen/blink.cmp/commit/36a8b30f20131eb51983d69afe49d399786c2388))
* **lsp:** missing `source` parameter ([#1451](https://github.com/Saghen/blink.cmp/issues/1451)) ([5e2c28b](https://github.com/Saghen/blink.cmp/commit/5e2c28bff4356340bac5111bfd01d77ff1ea4f4c))
* **luasnip:** hide completion window when expanding autosnippets ([#1450](https://github.com/Saghen/blink.cmp/issues/1450)) ([cf83e5d](https://github.com/Saghen/blink.cmp/commit/cf83e5db39a41a52077de6b204dd419d099f170f)), closes [#1018](https://github.com/Saghen/blink.cmp/issues/1018)
* **luasnip:** use `enter` instead of `leave` luasnip event ([#1455](https://github.com/Saghen/blink.cmp/issues/1455)) ([cb5142e](https://github.com/Saghen/blink.cmp/commit/cb5142e3126833f3ddccf2898f297eb8a459b625))
* mini snippets source not clearing keyword ([970dae0](https://github.com/Saghen/blink.cmp/commit/970dae08be3b9c06b298730f3b312ebfb98cac7c))
* never show signature help if disabled ([f29498e](https://github.com/Saghen/blink.cmp/commit/f29498e5f0f9a78bddb9d1c03c67e213896291d3)), closes [#1062](https://github.com/Saghen/blink.cmp/issues/1062)
* **nix:** don't add trailing newline to version ([#1356](https://github.com/Saghen/blink.cmp/issues/1356)) ([c90bd67](https://github.com/Saghen/blink.cmp/commit/c90bd6745e243d6cdc01a23f85ecdfb2f9cebabe))
* off by one error in within_query_bounds ([60a571e](https://github.com/Saghen/blink.cmp/commit/60a571e2155c18d18a6021ad4f89709d46e8445a))
* prefer luasnip name over regex trigger in completion results ([#1382](https://github.com/Saghen/blink.cmp/issues/1382)) ([662a67c](https://github.com/Saghen/blink.cmp/commit/662a67c6277790140c16164f3eca17fa19ae7a4c)), closes [#1373](https://github.com/Saghen/blink.cmp/issues/1373)
* preserve 'buflisted' state when applying LSP text edits ([#1432](https://github.com/Saghen/blink.cmp/issues/1432)) ([16fece7](https://github.com/Saghen/blink.cmp/commit/16fece774c9ad818ac8eb0f4f88fec3258053869))
* return 0 offset when in cmdline without noice ([b737295](https://github.com/Saghen/blink.cmp/commit/b737295fbe38b6a7dca01e6068a56cda23407f0a)), closes [#1406](https://github.com/Saghen/blink.cmp/issues/1406)
* schedule semantic process request from LspTokenUpdate ([0075a2d](https://github.com/Saghen/blink.cmp/commit/0075a2d6591dc249d3c149a027cf49fc4754d096))
* text edit range on windows paths ([86bf6fd](https://github.com/Saghen/blink.cmp/commit/86bf6fd96af672797c1269e8388d43f3db41804c)), closes [#1385](https://github.com/Saghen/blink.cmp/issues/1385)

## [0.13.1](https://github.com/Saghen/blink.cmp/compare/v0.13.0...v0.13.1) (2025-02-27)

### BREAKING CHANGES

* add `<Left>`, `<Right>` and `<C-space>` to cmdline preset
* fallback to next keymap when menu not shown for select_next/prev

### Features

* add `<Left>`, `<Right>` and `<C-space>` to cmdline preset ([8f7c23d](https://github.com/Saghen/blink.cmp/commit/8f7c23d6a817d6039f1a90a23cfbc0fd165a4153)), closes [#1328](https://github.com/Saghen/blink.cmp/issues/1328)
* fallback to next keymap when menu not shown for select_next/prev ([ffebcd2](https://github.com/Saghen/blink.cmp/commit/ffebcd2ad4ae7358bcd3f67b9975bfb9dbad2659)), closes [#1336](https://github.com/Saghen/blink.cmp/issues/1336)

### Bug Fixes

* **download:** correctly handle `download = false` and `implementation = "rust"` ([#1334](https://github.com/Saghen/blink.cmp/issues/1334)) ([2c8e4c7](https://github.com/Saghen/blink.cmp/commit/2c8e4c78b2ca735262be2ef201c38738db3c9674))
* lua fuzzy implementation off by 1 and suffix matching ([2c1524f](https://github.com/Saghen/blink.cmp/commit/2c1524f369b27ec09ff7b0425188933768622918)), closes [#1335](https://github.com/Saghen/blink.cmp/issues/1335)
* mini snippets validation ([c412578](https://github.com/Saghen/blink.cmp/commit/c412578824eb58f9f521643be16d9eb1568d068f)), closes [#1332](https://github.com/Saghen/blink.cmp/issues/1332) [#1342](https://github.com/Saghen/blink.cmp/issues/1342)

## [0.13.0](https://github.com/Saghen/blink.cmp/compare/v0.12.4...v0.13.0) (2025-02-26)

### Highlights

* Optional pure Lua mode! (no Rust dependency)
  * By default, if the Rust implementation is not available, Blink will emit a warning and fallback to the Lua implementation
  * [See the documentation](https://cmp.saghen.dev/configuration/fuzzy.html#rust-vs-lua-implementation)
* Cmdline configuration matches built-in cmdline behavior by default
  * Ghost text has been enabled by default with `noice.nvim`
  * [See the documentation](https://cmp.saghen.dev/modes/cmdline.html)
* Prebuilt binaries should now work on systems as old as Ubuntu 14.04
* Slow completions with multiple LSPs (especially `tailwind` and `emmet`) [has been resolved](https://github.com/Saghen/blink.cmp/issues/1115)
* Sources may now define `kind_icon`, `kind_hl` and `kind_name`
* [Guide on writing your own sources](https://cmp.saghen.dev/development/source-boilerplate.html)

### BREAKING CHANGES

* disable auto-brackets for `rust`
* fallback to mappings only for `<C-n>` and `<C-p>` by default
* match built-in cmdline behavior by default (#1314)
* set `BlinkCmpSource` highlight to `PmenuExtra` (#1284)
* disable accidentally enabled `exact` sorter
* set `BlinkCmpLabel(Deprecated|Description|Detail)` to `PmenuExtra`
* revert cmdline draw config to default

### Features

* `kind_icon` and `kind_name` on completion items ([010d939](https://github.com/Saghen/blink.cmp/commit/010d939e7fd6cb8d8e4a9b1dec228b8405d15fb4)), closes [#984](https://github.com/Saghen/blink.cmp/issues/984)
* add `get_selected_item_idx` and `get_items` API ([dc267e0](https://github.com/Saghen/blink.cmp/commit/dc267e089385890c6f73bd4d22f7c05eb5471474)), closes [#242](https://github.com/Saghen/blink.cmp/issues/242)
* add `show_with_menu` and `show_without_menu` to ghost text config ([132e362](https://github.com/Saghen/blink.cmp/commit/132e362299077ea168e8a047f3bce5f08269baf3)), closes [#1256](https://github.com/Saghen/blink.cmp/issues/1256)
* apply emmet-ls hack to emmet-language-server ([6abb8ab](https://github.com/Saghen/blink.cmp/commit/6abb8ab17c94080c53b66fdd6575cea0daae09f8))
* cache dot repeat buffer ([fb6a268](https://github.com/Saghen/blink.cmp/commit/fb6a2684fba9eff28679250470587f332fbc483e))
* disable accidentally enabled `exact` sorter ([c3a87dd](https://github.com/Saghen/blink.cmp/commit/c3a87dd75ab44fef5cfb0f2bc0402c0e5e4dde53))
* disable auto-brackets for `rust` ([54fd294](https://github.com/Saghen/blink.cmp/commit/54fd2943c5fe54659670498e25070d235d539bd4)), closes [#359](https://github.com/Saghen/blink.cmp/issues/359)
* download implementation with lua matcher ([2868fbd](https://github.com/Saghen/blink.cmp/commit/2868fbd86624c218c3ab492d5b1700ecbe80e265))
* fallback to mappings only for `<C-n>` and `<C-p>` by default ([1953baa](https://github.com/Saghen/blink.cmp/commit/1953baa6d274de20878dd805362ad09483227377)), closes [#1286](https://github.com/Saghen/blink.cmp/issues/1286)
* ignore `A-z` trigger characters ([a283be6](https://github.com/Saghen/blink.cmp/commit/a283be6cc9a25ffcbd45f0853cd653446ddc97f3))
* isolate tailwind hack, support changing icon ([7eee42b](https://github.com/Saghen/blink.cmp/commit/7eee42b8cd052bb5280cce484b6479d553128b4c)), closes [#1011](https://github.com/Saghen/blink.cmp/issues/1011)
* lua fuzzy matching implementation ([87c88de](https://github.com/Saghen/blink.cmp/commit/87c88deb9ca06ad2b6ab7d9a11e6cd4c6d91982e))
* match built-in cmdline behavior by default ([#1314](https://github.com/Saghen/blink.cmp/issues/1314)) ([54091b6](https://github.com/Saghen/blink.cmp/commit/54091b68797d6ea44c5acafe8709bf32923d7e07))
* multi LSP isIncomplete caching ([ceb9f91](https://github.com/Saghen/blink.cmp/commit/ceb9f9114fea01bcd925cf3f2c663fed44d16c5a)), closes [#1115](https://github.com/Saghen/blink.cmp/issues/1115) [#921](https://github.com/Saghen/blink.cmp/issues/921)
* **nix:** remove unneeded fetchGit ([#1315](https://github.com/Saghen/blink.cmp/issues/1315)) ([82d0720](https://github.com/Saghen/blink.cmp/commit/82d0720e7d6931c4fc7e3b37e536d1c37cb1ca6f))
* re-enable neovim 0.11 vim.validate ([22e6351](https://github.com/Saghen/blink.cmp/commit/22e63518beb26e4e8a9ba6725386ae4ed700658f)), closes [#1275](https://github.com/Saghen/blink.cmp/issues/1275)
* revert cmdline draw config to default ([a472b3e](https://github.com/Saghen/blink.cmp/commit/a472b3ec616392255f9c8dd26fdb2c7a899f3af1)), closes [#1243](https://github.com/Saghen/blink.cmp/issues/1243)
* set `BlinkCmpLabel(Deprecated|Description|Detail)` to `PmenuExtra` ([3a97722](https://github.com/Saghen/blink.cmp/commit/3a977226433e0c3bbc15d3c9ca2e7ef589b115af))
* set `BlinkCmpSource` highlight to `PmenuExtra` ([#1284](https://github.com/Saghen/blink.cmp/issues/1284)) ([6894225](https://github.com/Saghen/blink.cmp/commit/68942256d71e8d66632eb840b051a9320bc502dc))
* set glibc to 2.21 for linux builds ([f1877a0](https://github.com/Saghen/blink.cmp/commit/f1877a033734d1e2d6d58d9b01f05092d1d318ab)), closes [#160](https://github.com/Saghen/blink.cmp/issues/160)
* show loading indicator on long running fetch ([3d38eb4](https://github.com/Saghen/blink.cmp/commit/3d38eb457ce841ac479f5e43fa4d55aac6badf89)), closes [#81](https://github.com/Saghen/blink.cmp/issues/81)
* support ghost text with noice ([#1269](https://github.com/Saghen/blink.cmp/issues/1269)) ([9cbbcc0](https://github.com/Saghen/blink.cmp/commit/9cbbcc068ad4daee5c7a48f5ce73b1b12665fa0d))
* use `source_id` when tracking item across lists ([78ef9e1](https://github.com/Saghen/blink.cmp/commit/78ef9e15ab314b2a349679a5f40ccf90074f8575))
* use published `frizbee` crate ([2dbc1b7](https://github.com/Saghen/blink.cmp/commit/2dbc1b78cda0632029d946b709eddaf43d9b13e0)), closes [#839](https://github.com/Saghen/blink.cmp/issues/839)
* use zig for glibc 2.27 builds ([323e480](https://github.com/Saghen/blink.cmp/commit/323e480535ecaab01136aeef04eb03925d9fad8b)), closes [#160](https://github.com/Saghen/blink.cmp/issues/160)

### Bug Fixes

* add missing `source_id` component to completion menu draw ([558c2a4](https://github.com/Saghen/blink.cmp/commit/558c2a41cc4f09d2c5fcfb54472d942dc3109f3c)), closes [#1321](https://github.com/Saghen/blink.cmp/issues/1321)
* cached LSP items wrong cursor column ([3b768bb](https://github.com/Saghen/blink.cmp/commit/3b768bb2c5880655b9b00d1529ff4b390218fc71)), closes [#1281](https://github.com/Saghen/blink.cmp/issues/1281)
* cmdline arg_number on border with another argument ([79aa4e5](https://github.com/Saghen/blink.cmp/commit/79aa4e575607568c8ac2a7c699b3593694fc0939)), closes [#1288](https://github.com/Saghen/blink.cmp/issues/1288)
* completions not showing on manual trigger immediately after prefetch ([5a6f8d8](https://github.com/Saghen/blink.cmp/commit/5a6f8d8d130bbcb02227b75ac695fbcdeee4a012))
* context/items not pass to `completion.menu.auto_show` ([#1290](https://github.com/Saghen/blink.cmp/issues/1290)) ([2f208a7](https://github.com/Saghen/blink.cmp/commit/2f208a7b1621f0bc570dd3ef3673e3a3a25b1aa3))
* cross zig configuration ([1004e71](https://github.com/Saghen/blink.cmp/commit/1004e71d788d2062bfe6aac7cf83fd9352975c09))
* docs creating tags breaking panvimdoc ([af2f4ec](https://github.com/Saghen/blink.cmp/commit/af2f4ecec15ad70f807196a371d239c62a36a8c7)), closes [#1278](https://github.com/Saghen/blink.cmp/issues/1278)
* ignore empty completion type in input mode ([d2551d6](https://github.com/Saghen/blink.cmp/commit/d2551d65dbeb13507926c90bf974e7be227c25cb)), closes [#1309](https://github.com/Saghen/blink.cmp/issues/1309)
* ignore failing `cc -dumpmachine` ([a4bb082](https://github.com/Saghen/blink.cmp/commit/a4bb08247e486fc3f183e28934fe20b19382ebe3)), closes [#1297](https://github.com/Saghen/blink.cmp/issues/1297) [#1299](https://github.com/Saghen/blink.cmp/issues/1299)
* incsearch flickering when typing characters during search ([#1305](https://github.com/Saghen/blink.cmp/issues/1305)) ([d2fbc41](https://github.com/Saghen/blink.cmp/commit/d2fbc41787d30fbfc6853ba82f2f0c47c9165034)), closes [#1061](https://github.com/Saghen/blink.cmp/issues/1061)
* insert text edit after additional text edits ([6ada545](https://github.com/Saghen/blink.cmp/commit/6ada545384de7a624b5d6090c78d58e05573f23a)), closes [#1270](https://github.com/Saghen/blink.cmp/issues/1270)
* lua expr cmdline completion clears prior input ([#1282](https://github.com/Saghen/blink.cmp/issues/1282)) ([30d9081](https://github.com/Saghen/blink.cmp/commit/30d9081004f2b41428e8a35995be9a7e380fd527)), closes [#1240](https://github.com/Saghen/blink.cmp/issues/1240)
* pcall dot repeat for `q:` window ([3c0115c](https://github.com/Saghen/blink.cmp/commit/3c0115cc31d42081ae61ecb25c71be1c278bf990)), closes [#1260](https://github.com/Saghen/blink.cmp/issues/1260)
* pick documentation direction via desired min width only ([2fb514b](https://github.com/Saghen/blink.cmp/commit/2fb514b8b1d2e5012ba036f55731f7a05351beb0)), closes [#1181](https://github.com/Saghen/blink.cmp/issues/1181)
* pick menu direction based on max height ([9446f50](https://github.com/Saghen/blink.cmp/commit/9446f5003c62143a83bdb6ecc9b659259db300c3))
* remove accidental backslash in keyword regex ([5b7915b](https://github.com/Saghen/blink.cmp/commit/5b7915b7d072cd6b8ac57ce426576b1b423da8ac)), closes [#1125](https://github.com/Saghen/blink.cmp/issues/1125)
* respect `vim.fn.input` completion type ([12d035e](https://github.com/Saghen/blink.cmp/commit/12d035e20156cf7294818fe51fb71b59237b7330)), closes [#1079](https://github.com/Saghen/blink.cmp/issues/1079)
* skip snippet and fallback commands in term/cmdline keymaps ([df46f6f](https://github.com/Saghen/blink.cmp/commit/df46f6fc7ceebe12e8f3b4366520b19d6dc8ef91)), closes [#1253](https://github.com/Saghen/blink.cmp/issues/1253)
* trigger custom client LSP commands ([#1255](https://github.com/Saghen/blink.cmp/issues/1255)) ([69fe0ed](https://github.com/Saghen/blink.cmp/commit/69fe0ed74c48ba511fdc6c1846cf45f8d20cf67b))

## [0.12.4](https://github.com/Saghen/blink.cmp/compare/v0.12.3...v0.12.4) (2025-02-16)

### Bug Fixes

* add noremap to dot repeat hack ([93052a8](https://github.com/Saghen/blink.cmp/commit/93052a80660d741a051d43dc487c8bf7a2530b11)), closes [#1239](https://github.com/Saghen/blink.cmp/issues/1239)
* deduplicate enabled providers ([505257b](https://github.com/Saghen/blink.cmp/commit/505257b223e855876a056eae968bb3a8d9692693)), closes [#1241](https://github.com/Saghen/blink.cmp/issues/1241)

## [0.12.3](https://github.com/Saghen/blink.cmp/compare/v0.12.2...v0.12.3) (2025-02-16)

### Bug Fixes

* move cursor for auto brackets in dot repeat ([5007e54](https://github.com/Saghen/blink.cmp/commit/5007e544362da031909ae718cf86e9bace964711)), closes [#1233](https://github.com/Saghen/blink.cmp/issues/1233)

## [0.12.2](https://github.com/Saghen/blink.cmp/compare/v0.12.1...v0.12.2) (2025-02-15)

### Bug Fixes

* use gnu when alpine-release does not exist ([1952303](https://github.com/Saghen/blink.cmp/commit/1952303de90fb8b05dec6c0a73299467e6edbdb3))

## [0.12.1](https://github.com/Saghen/blink.cmp/compare/v0.12.0...v0.12.1) (2025-02-15)

### Bug Fixes

* always create event listeners for cmdline/term ([8a2356a](https://github.com/Saghen/blink.cmp/commit/8a2356a1084e8ec8f6e0707df248b2ce0553a940))
* check `cmdline/term.enabled` before listening to events ([d24d446](https://github.com/Saghen/blink.cmp/commit/d24d4463595ab040dd3cf3f12a9589b00185b7d5))
* check if mode-specific configs are enabled before adding sources ([#1231](https://github.com/Saghen/blink.cmp/issues/1231)) ([19f60a6](https://github.com/Saghen/blink.cmp/commit/19f60a675eaaf4b160bd6458bfd72fc005da5b3f))

## [0.12.0](https://github.com/Saghen/blink.cmp/compare/v0.11.0...v0.12.0) (2025-02-15)

### Highlights

* Dot repeat (`.`) has been added! Special thanks to @mikavilpas and @xzbdmw
  * You may disable it with `completion.accept.dot_repeat = false` if you run into issues
  * [Implementation for those curious](https://github.com/Saghen/blink.cmp/blob/afb7955f9d5af82af1f1ee8e676136417f13ee9f/lua/blink/cmp/lib/text_edits.lua#L292-L371)
* Terminal completion (`term`) has been added but there's no sources taking advantage of it at the moment. [Contributions welcome!](https://github.com/Saghen/blink.cmp/issues/1149) Thanks @wurli!
* Mode specific configuration (`cmdline` and `term`) have been moved to their own top-level tables. The most notable moves are:
  * `keymap.cmdline` -> `cmdline.keymap`
  * `sources.cmdline` -> `cmdline.sources`
* During scoring, items with exact matches receive a bonus of 4, however if you always want exact matches at the top, you may use the new `exact` sorter: `fuzzy.sorts = { 'exact', 'score', 'sort_text' }`
* LSP commands are now supported
* Vim documentation has been added via panvimdoc, [see limitations](https://github.com/Saghen/blink.cmp/blob/be76c456417d6fe3163f0490f309f92a2c99771e/.github/workflows/panvimdoc.yaml#L1-L2)

### BREAKING CHANGES

* mode-specific config (#1203)
* explicit `snippets.score_offset` option
* add `exact` match comparator (#1099)
* default `BlinkCmpKind` hl to `PmenuKind`

### Features

* add `accept_and_enter` and `select_accept_and_enter` command ([#957](https://github.com/Saghen/blink.cmp/issues/957)) ([507d0d7](https://github.com/Saghen/blink.cmp/commit/507d0d7b6322bd376dc67bc255b2c48109397a7e))
* add `exact` match comparator ([#1099](https://github.com/Saghen/blink.cmp/issues/1099)) ([d6169f0](https://github.com/Saghen/blink.cmp/commit/d6169f0551bb1c8d18cc118e5c970a7b01a2726d)), closes [#1085](https://github.com/Saghen/blink.cmp/issues/1085)
* add `omnifunc` completion source ([9c1286f](https://github.com/Saghen/blink.cmp/commit/9c1286f28ee482aa427f2f226188c682a978d5a3))
* add asynchronous cc -dumpmachine for libc detection ([4ac2c27](https://github.com/Saghen/blink.cmp/commit/4ac2c271600cb95e1da3111ca498666dc6348a40))
* add client_name to completion item from lsp ([6d1d503](https://github.com/Saghen/blink.cmp/commit/6d1d503ab95b05772472fa867737d30e6bd222b2)), closes [#1162](https://github.com/Saghen/blink.cmp/issues/1162)
* add hints for mode-specific config ([035e1ba](https://github.com/Saghen/blink.cmp/commit/035e1bae395b2b34c6cf0234f4270bf9481905b4))
* add lsp command cancellation ([62d6ffe](https://github.com/Saghen/blink.cmp/commit/62d6ffee5bf42a26d8dd33c4315067bbaa2e4dd7))
* add workflow for vimdocs via panvimdoc ([a290e35](https://github.com/Saghen/blink.cmp/commit/a290e35df01c600695dbe519f4feea0f46866452))
* apply lsp commands ([#1130](https://github.com/Saghen/blink.cmp/issues/1130)) ([2de57ce](https://github.com/Saghen/blink.cmp/commit/2de57ce8677b4cc278086cfc7700ba10b987b8eb))
* automatic runtime linux libc detection ([#1144](https://github.com/Saghen/blink.cmp/issues/1144)) ([beffa19](https://github.com/Saghen/blink.cmp/commit/beffa1996d3a83a54c6b5fb707f9600761bf3d9f)), closes [#160](https://github.com/Saghen/blink.cmp/issues/160)
* bump deps and frizbee with bitmask prefiltering ([b078c6e](https://github.com/Saghen/blink.cmp/commit/b078c6ec59286641c8d71949500469df746d3510)), closes [#1105](https://github.com/Saghen/blink.cmp/issues/1105)
* default `BlinkCmpKind` hl to `PmenuKind` ([7ae6d9d](https://github.com/Saghen/blink.cmp/commit/7ae6d9d6f645f96fdf61350e7bb50a057d230999))
* disable path source when current path segment contains space ([0abe117](https://github.com/Saghen/blink.cmp/commit/0abe11770a7b9a23f577a4bd2e3994634f355016)), closes [#1126](https://github.com/Saghen/blink.cmp/issues/1126)
* efficient LSP item concatenation ([f8fd448](https://github.com/Saghen/blink.cmp/commit/f8fd44888d9bde7c60aa24973fa15a5355ab8f7f))
* explicit `snippets.score_offset` option ([cf57b2a](https://github.com/Saghen/blink.cmp/commit/cf57b2a708d6b221ab857a8f44f8ca654c5f731c))
* format lua files using stylua ([#1179](https://github.com/Saghen/blink.cmp/issues/1179)) ([567980d](https://github.com/Saghen/blink.cmp/commit/567980d6574cb23a98bc32f29025b31c3fb4dce0))
* ignore range in cmdline completions ([f0aeac2](https://github.com/Saghen/blink.cmp/commit/f0aeac28d18a3734473cb440ea96881a002b8ad0)), closes [#1155](https://github.com/Saghen/blink.cmp/issues/1155) [#1092](https://github.com/Saghen/blink.cmp/issues/1092)
* include `_` at beginning of buffer words ([846a044](https://github.com/Saghen/blink.cmp/commit/846a0448fd7ee4f34cdd2903e786c5c6ed50e142)), closes [#1091](https://github.com/Saghen/blink.cmp/issues/1091)
* mark command and data as resolvable ([ebb2e22](https://github.com/Saghen/blink.cmp/commit/ebb2e22a8b6c8656d11b07c321bbde9f9a483d2c))
* mode-specific config ([#1203](https://github.com/Saghen/blink.cmp/issues/1203)) ([93215d8](https://github.com/Saghen/blink.cmp/commit/93215d80346e14763a67d97785dccb1e1c3a6775))
* **omni:** infer completion kind where possible ([ce35af0](https://github.com/Saghen/blink.cmp/commit/ce35af01f4a1caff4ef3fbdc5b5e61740ae6a437))
* **omni:** use `complete-functions` info as documentation when available ([59c3e21](https://github.com/Saghen/blink.cmp/commit/59c3e21e152844c0665f758bce1528cdac0b5dfd))
* only load providers enabled for context ([aaad7db](https://github.com/Saghen/blink.cmp/commit/aaad7dbaa53b14b07bc4f9edb06556d4515b7fe0)), closes [#1070](https://github.com/Saghen/blink.cmp/issues/1070)
* simplify dot repeat hack ([9e95af4](https://github.com/Saghen/blink.cmp/commit/9e95af47ea25d396405a67d5b298446959f3e4b9)), closes [#1206](https://github.com/Saghen/blink.cmp/issues/1206)
* support custom `draw` function for documentation ([b88ba59](https://github.com/Saghen/blink.cmp/commit/b88ba59b066e4b6345ff631e07c79984407a8625)), closes [#1113](https://github.com/Saghen/blink.cmp/issues/1113)
* support dot-repeat via `vim.fn.complete` ([#1033](https://github.com/Saghen/blink.cmp/issues/1033)) ([4673d79](https://github.com/Saghen/blink.cmp/commit/4673d797b662ef1c8fb23b2c1807866d8cc9f441))
* support multi-line dot repeat ([a776a09](https://github.com/Saghen/blink.cmp/commit/a776a099988a74b9005e19bed2c5721a119aac52))
* terminal-mode completions ([#665](https://github.com/Saghen/blink.cmp/issues/665)) ([7b4e546](https://github.com/Saghen/blink.cmp/commit/7b4e546fcb18c230938065f5e65afed97861a869))

### Bug Fixes

* add elm to blocked filetypes for auto brackets ([844b97a](https://github.com/Saghen/blink.cmp/commit/844b97a3512120ce79bc4ce4371f6983f05f5774)), closes [#1226](https://github.com/Saghen/blink.cmp/issues/1226)
* avoid exiting completion mode when expanding snippets ([0bd150a](https://github.com/Saghen/blink.cmp/commit/0bd150a1b387a74c272850ae544cba464aa5326f))
* **buffer:** add back missing brackets in regex ([9f32ef5](https://github.com/Saghen/blink.cmp/commit/9f32ef5c3bb44f943238bbcde0c467936475f177)), closes [#964](https://github.com/Saghen/blink.cmp/issues/964)
* cancellation not bubbling to sources ([b2485c7](https://github.com/Saghen/blink.cmp/commit/b2485c76cb7877de6fe9c8670af59ba3d72fd74d)), closes [#1116](https://github.com/Saghen/blink.cmp/issues/1116) [#1115](https://github.com/Saghen/blink.cmp/issues/1115)
* close completion window only if open ([779afa4](https://github.com/Saghen/blink.cmp/commit/779afa4e5172b7fb72f096cffb8360d5e457aa7b)), closes [#1206](https://github.com/Saghen/blink.cmp/issues/1206)
* cmdline incorrect edit range ([d832ace](https://github.com/Saghen/blink.cmp/commit/d832ace702c82c26195911413745b839617aa7b0)), closes [#1117](https://github.com/Saghen/blink.cmp/issues/1117) [#1161](https://github.com/Saghen/blink.cmp/issues/1161)
* don't show signature help when trigger is disabled ([#1180](https://github.com/Saghen/blink.cmp/issues/1180)) ([3b770b0](https://github.com/Saghen/blink.cmp/commit/3b770b0b8f65d6cacafb78ffc7b1f1ea02502d5b))
* dot repeat no autocmds in win, buf opts, close compl window in insert mode ([6431adb](https://github.com/Saghen/blink.cmp/commit/6431adbd9819e7fc72fb2072da62bc219776e3ce))
* dot repeat sending to background ([1e7c433](https://github.com/Saghen/blink.cmp/commit/1e7c4331ca277eecb39a835fdd7b24fd6afd9b0a)), closes [#1206](https://github.com/Saghen/blink.cmp/issues/1206)
* ensure `TextChangedI` runs last with `mini.snippets` ([#1035](https://github.com/Saghen/blink.cmp/issues/1035)) ([7f3d982](https://github.com/Saghen/blink.cmp/commit/7f3d9828ebc0e42d0f41cb873e9b019a57e5bd72))
* execute requiring cancellation function ([d683d8f](https://github.com/Saghen/blink.cmp/commit/d683d8f0e93f94b15141fdcd76bba0653fd91c85))
* **luadoc:** KeymapCommand alias broken ([#1153](https://github.com/Saghen/blink.cmp/issues/1153)) ([03db0dd](https://github.com/Saghen/blink.cmp/commit/03db0dda54bb9cc6977f337f5342cae7b8ceb0d3))
* luasnip duplicate items ([f0f34c3](https://github.com/Saghen/blink.cmp/commit/f0f34c318af019b44fc8ea347895dcf92b682122)), closes [#1081](https://github.com/Saghen/blink.cmp/issues/1081)
* move cursor correctly with multi-line text edits ([ac2ecd6](https://github.com/Saghen/blink.cmp/commit/ac2ecd63f686dea8e8ba0af29f830642032791c3)), closes [#1123](https://github.com/Saghen/blink.cmp/issues/1123)
* outdated Cargo.lock ([cdd52ac](https://github.com/Saghen/blink.cmp/commit/cdd52acfec357521a105dee33e256c902607f7ee)), closes [#1150](https://github.com/Saghen/blink.cmp/issues/1150)
* pass resolved item to execute ([f22ca35](https://github.com/Saghen/blink.cmp/commit/f22ca35d06b2210ebc84280be94caa11cf2ffe9f)), closes [#1219](https://github.com/Saghen/blink.cmp/issues/1219)
* path completion in Windows using backward slash ([#1152](https://github.com/Saghen/blink.cmp/issues/1152)) ([575784f](https://github.com/Saghen/blink.cmp/commit/575784fd6cb1f664c4239680e77834739314ebf9))
* revert scheduling feedkeys to close completion menu ([2b7fbe9](https://github.com/Saghen/blink.cmp/commit/2b7fbe96febf86e8c76e80def9705245990a4d04))
* schedule closing completion menu after dot repeat ([a17a4be](https://github.com/Saghen/blink.cmp/commit/a17a4be0705b25ba5e586f6f418b44eecae85e8b))
* schedule just feedkeys to close completion menu ([363f351](https://github.com/Saghen/blink.cmp/commit/363f351898213b0da31397d167fc0e18eddb3d2a))
* support additional text edits when calculating cursor position ([cc34be8](https://github.com/Saghen/blink.cmp/commit/cc34be8ff1145264811e59b017f59676ad81000e)), closes [#223](https://github.com/Saghen/blink.cmp/issues/223) [#975](https://github.com/Saghen/blink.cmp/issues/975)
* use nearest char index for keyword range ([e3330cd](https://github.com/Saghen/blink.cmp/commit/e3330cdd6054b45af8467f62544bc0de6b89f408)), closes [#1131](https://github.com/Saghen/blink.cmp/issues/1131)
* use temporary floating window for dot repeat ([754a684](https://github.com/Saghen/blink.cmp/commit/754a684f5aa31126dfd537ab4888abe8c441fd3e))

## [0.11.0](https://github.com/Saghen/blink.cmp/compare/v0.10.0...v0.11.0) (2025-01-24)

> [!IMPORTANT]
> Blink.cmp now fetches the completion items immediately upon entering insert mode by default. More ideas for prefetching are being explored! https://github.com/Saghen/blink.cmp/issues/706
> 
> The fuzzy matcher now explicitly understands typos which should result in more predictable fuzziness on longer strings

### BREAKING CHANGES

* set prefetch on insert to true by default
* **keymap:** add Up/Down keymaps to default preset (#1031)

### Features

* `show_and_select` keymap command ([373535e](https://github.com/Saghen/blink.cmp/commit/373535e0f17f1c83455d0f586507d2fc87f867af)), closes [#1004](https://github.com/Saghen/blink.cmp/issues/1004)
* add `add_filetype_source` API ([40d0ce0](https://github.com/Saghen/blink.cmp/commit/40d0ce0f90f07750b7bf85562d2a12231ef6c789))
* add `BlinkCmp status` command ([#809](https://github.com/Saghen/blink.cmp/issues/809)) ([86c9676](https://github.com/Saghen/blink.cmp/commit/86c96769907102d29cac64e085c49479257c50ca))
* add `is_(menu|documentation|ghost_text)_visible` functions ([8d29e0e](https://github.com/Saghen/blink.cmp/commit/8d29e0e708f6655ae4153f96cf843a38377c7faf)), closes [#995](https://github.com/Saghen/blink.cmp/issues/995)
* auto bracket exceptions ([e121ec2](https://github.com/Saghen/blink.cmp/commit/e121ec2ac13bb15a468041c9b9ded9e468bc5222)), closes [#1008](https://github.com/Saghen/blink.cmp/issues/1008)
* fill in snippet detail if missing in LSP resolve ([8f27db5](https://github.com/Saghen/blink.cmp/commit/8f27db520029b793adb5e784f57ca309deb77ca8)), closes [#976](https://github.com/Saghen/blink.cmp/issues/976)
* **ghost_text:** show_on_unselected ([#965](https://github.com/Saghen/blink.cmp/issues/965)) ([4a380c1](https://github.com/Saghen/blink.cmp/commit/4a380c180e00482b52f8e2fb6870197fa03e7091))
* **keymap:** add Up/Down keymaps to default preset ([#1031](https://github.com/Saghen/blink.cmp/issues/1031)) ([44a67b3](https://github.com/Saghen/blink.cmp/commit/44a67b3e2de23941f230736e002bec058bc933ac))
* menu.draw.columns can be function ([#1049](https://github.com/Saghen/blink.cmp/issues/1049)) ([18b4f1a](https://github.com/Saghen/blink.cmp/commit/18b4f1a309b4e60bbb3b716438ae902676bc52c5))
* rename `show_and_select` to `show_and_insert` ([595a6a1](https://github.com/Saghen/blink.cmp/commit/595a6a13b17637e4c4831b2794fbca28a9d908a1))
* resolve cache by context ([4759c4b](https://github.com/Saghen/blink.cmp/commit/4759c4b0ff37f7e4f7174359450248b7ff27baf2))
* resolve timeout ([f91558e](https://github.com/Saghen/blink.cmp/commit/f91558ea7491e3d5dc965ba3fbd43e817dddef37)), closes [#627](https://github.com/Saghen/blink.cmp/issues/627)
* set prefetch on insert to true by default ([c4eafc1](https://github.com/Saghen/blink.cmp/commit/c4eafc1f87380da04eb8b9c5b52395c48edd102e))
* signature commands and more events ([6da1023](https://github.com/Saghen/blink.cmp/commit/6da1023bb30b615c1f82f11d3faf56a80f1dcb38)), closes [#816](https://github.com/Saghen/blink.cmp/issues/816) [#89](https://github.com/Saghen/blink.cmp/issues/89)
* **signature:** add `window.show_documentation` option ([#954](https://github.com/Saghen/blink.cmp/issues/954)) ([59982a5](https://github.com/Saghen/blink.cmp/commit/59982a560f2687bd5335eda83ddd7c5793a43931)), closes [#879](https://github.com/Saghen/blink.cmp/issues/879)
* spellchecking with typos-cli ([#990](https://github.com/Saghen/blink.cmp/issues/990)) ([64cb887](https://github.com/Saghen/blink.cmp/commit/64cb8877e2a6d82592761856220f4811edee4f5f))
* support `should_show_items` from sources ([fc9276d](https://github.com/Saghen/blink.cmp/commit/fc9276d28b40fe1ba6b5c0ac84039e5d3c6c2299)), closes [#972](https://github.com/Saghen/blink.cmp/issues/972)
* support proxy for downloading prebuilt binaries ([#1030](https://github.com/Saghen/blink.cmp/issues/1030)) ([6c296e7](https://github.com/Saghen/blink.cmp/commit/6c296e782a9c44a9b926beada5f53a2c0bea803b))
* use health check for status command ([fe9b851](https://github.com/Saghen/blink.cmp/commit/fe9b851de8a197e627fe162a27235fdce5a3c36a))
* use lossy string for lua -> rust conversion ([3b4fa80](https://github.com/Saghen/blink.cmp/commit/3b4fa804b4a4f99a11f2e7a24cf2d773d94ca4c6)), closes [#1000](https://github.com/Saghen/blink.cmp/issues/1000) [#1051](https://github.com/Saghen/blink.cmp/issues/1051)

### Bug Fixes

* add exclusion for `custom,v:lua` completions ([#1024](https://github.com/Saghen/blink.cmp/issues/1024)) ([cee556e](https://github.com/Saghen/blink.cmp/commit/cee556eba5ff991fbfd6af49c5ef59882d65ea0b))
* add signature commands to types ([c9b52a7](https://github.com/Saghen/blink.cmp/commit/c9b52a72262c91661f9b3c106a16a4cb260ec895))
* apply detail extraction to lua_ls only ([6c87840](https://github.com/Saghen/blink.cmp/commit/6c8784065ae64db7e168d6a4275bd7bd5e41d12e)), closes [#896](https://github.com/Saghen/blink.cmp/issues/896)
* auto_insert undo out of date after cursor movement ([d0cb8e8](https://github.com/Saghen/blink.cmp/commit/d0cb8e83b3ca5bd631e465494000543585c3b2ef)), closes [#810](https://github.com/Saghen/blink.cmp/issues/810)
* call completion handler directly in input mode only ([b19436e](https://github.com/Saghen/blink.cmp/commit/b19436ece61409919b4f719eb7a1201fbbcb03c9)), closes [#1052](https://github.com/Saghen/blink.cmp/issues/1052)
* **ci:** don't persist credentials in actions/checkout ([#991](https://github.com/Saghen/blink.cmp/issues/991)) ([1ddd01b](https://github.com/Saghen/blink.cmp/commit/1ddd01bea96743c21710046a64ef771422194866))
* **cmdline:** make completion work for <sid> and s: viml function ([#925](https://github.com/Saghen/blink.cmp/issues/925)) ([fd8859e](https://github.com/Saghen/blink.cmp/commit/fd8859e520eadd1842e9b70511d9389900092eb6))
* **cmdline:** parse for command name if possible ([#993](https://github.com/Saghen/blink.cmp/issues/993)) ([29c9cf3](https://github.com/Saghen/blink.cmp/commit/29c9cf327fb162ea70db94537c8285a5a9aaad42))
* don't highlight deprecated items with treesitter ([c32eca4](https://github.com/Saghen/blink.cmp/commit/c32eca4f2fbd3d01a0628007797a3121ba9b8673)), closes [#1019](https://github.com/Saghen/blink.cmp/issues/1019)
* **fuzzy:** typo introduced in commit `93541e4` ([#1027](https://github.com/Saghen/blink.cmp/issues/1027)) ([55eeffa](https://github.com/Saghen/blink.cmp/commit/55eeffa22800e25f7a5c95fe8a799f4325424a44))
* get original cursor before applying text edit in preview ([cc490bf](https://github.com/Saghen/blink.cmp/commit/cc490bfb4c315798158c76b42ccfcce2577ea6b0)), closes [#1013](https://github.com/Saghen/blink.cmp/issues/1013)
* **ghost_text:** ensure multiline indent is correct ([#934](https://github.com/Saghen/blink.cmp/issues/934)) ([b8dbec6](https://github.com/Saghen/blink.cmp/commit/b8dbec6f7786bb8c8358730ff8b77c660e0a7cde))
* help detection triggering on first arg ([0632884](https://github.com/Saghen/blink.cmp/commit/06328848567a9e754bec8099a942b32270f4141a)), closes [#1050](https://github.com/Saghen/blink.cmp/issues/1050)
* ignore invalid utf-8 vim.v.char ([3f9b798](https://github.com/Saghen/blink.cmp/commit/3f9b798bce73d13383c600ae940ee20e7bce9576)), closes [#989](https://github.com/Saghen/blink.cmp/issues/989) [#1000](https://github.com/Saghen/blink.cmp/issues/1000)
* ignore prefix for non :lua commands ([9854978](https://github.com/Saghen/blink.cmp/commit/9854978bf9cb871b386c0dc30913bad81d66a33a)), closes [#1075](https://github.com/Saghen/blink.cmp/issues/1075)
* **lsp:** early return on completionItem/resolve ([#1055](https://github.com/Saghen/blink.cmp/issues/1055)) ([80dab4d](https://github.com/Saghen/blink.cmp/commit/80dab4d6d7402cd044fcce5a3baf856b9adcd6e6)), closes [#1048](https://github.com/Saghen/blink.cmp/issues/1048)
* make windows focusable ([a5402a1](https://github.com/Saghen/blink.cmp/commit/a5402a1ae0ef71a3d47e5f82e35cefe7299ba508)), closes [#1001](https://github.com/Saghen/blink.cmp/issues/1001)
* memory leak in cached resolve tasks ([ef9f85c](https://github.com/Saghen/blink.cmp/commit/ef9f85c6ff87747655e8ef37c997ab808a2957c0)), closes [#1039](https://github.com/Saghen/blink.cmp/issues/1039)
* **mini.snippets:** expand function should have body=snippet ([#951](https://github.com/Saghen/blink.cmp/issues/951)) ([a993bd8](https://github.com/Saghen/blink.cmp/commit/a993bd8977f5e7087e4f5b03fa2ce7c3358debf1))
* only override <C-k> if signature is enabled ([ce0629f](https://github.com/Saghen/blink.cmp/commit/ce0629fc52723ea6c601b430f61f0678e3bdedf4))
* prefix slicing using chars instead of bytes ([93541e4](https://github.com/Saghen/blink.cmp/commit/93541e4e45ddd06cd7efa9d65840936dff557fb3)), closes [#936](https://github.com/Saghen/blink.cmp/issues/936)
* schedule cmdline item building ([f74f249](https://github.com/Saghen/blink.cmp/commit/f74f249172cea99370a7dfe9ff8f109135374464)), closes [#1038](https://github.com/Saghen/blink.cmp/issues/1038)
* scrollbar gutter detection with border table ([ecbac4b](https://github.com/Saghen/blink.cmp/commit/ecbac4bac5cbe85d298e5c1c8a79d98a77b2ff9c)), closes [#828](https://github.com/Saghen/blink.cmp/issues/828)
* separate insert/replace ranges for cmdline ([a38c6d8](https://github.com/Saghen/blink.cmp/commit/a38c6d81f21a77d7c5d6204db20b2e38bf5b2af8)), closes [#994](https://github.com/Saghen/blink.cmp/issues/994)
* shallow copy luasnip items ([712af9f](https://github.com/Saghen/blink.cmp/commit/712af9f50bbba4313b6247dedd5a1333391127df)), closes [#1006](https://github.com/Saghen/blink.cmp/issues/1006)
* stringify parsed snippet when ignoring snippet format ([80945db](https://github.com/Saghen/blink.cmp/commit/80945db7a988f8eb5233bb1e4b409bb20177c7ac)), closes [#944](https://github.com/Saghen/blink.cmp/issues/944)

## [0.10.0](https://github.com/Saghen/blink.cmp/compare/v0.9.3...v0.10.0) (2025-01-08)

### BREAKING CHANGES

* mini.snippets and snippets presets (#877)
* support `preselect` with `auto_insert`, set as default

### Features

* add `get_selected_item` public function ([9e1e7e6](https://github.com/Saghen/blink.cmp/commit/9e1e7e604e3419fa0777a2b747ded74d35013c06))
* mini.snippets and snippets presets ([#877](https://github.com/Saghen/blink.cmp/issues/877)) ([854ab87](https://github.com/Saghen/blink.cmp/commit/854ab87aefdac2b757d97595f98673d64f1878bc))
* set default capabilities on 0.11 ([#897](https://github.com/Saghen/blink.cmp/issues/897)) ([af1febb](https://github.com/Saghen/blink.cmp/commit/af1febb17f9ddc87cf73e69d3f61218cdc18ed85))
* support `preselect` with `auto_insert`, set as default ([8126d0e](https://github.com/Saghen/blink.cmp/commit/8126d0e6a2a0e62d3872d718c3d50313f9f7fe3a)), closes [#668](https://github.com/Saghen/blink.cmp/issues/668)

### Bug Fixes

* `get_char_at_cursor` attempting to get char on empty line ([7d6bf9a](https://github.com/Saghen/blink.cmp/commit/7d6bf9adea67a200067effe5ef589515e71230c8)), closes [#926](https://github.com/Saghen/blink.cmp/issues/926)
* `within_query_bounds` including 1 position after bounds ([36ba8eb](https://github.com/Saghen/blink.cmp/commit/36ba8eb9c166c21d6d2a8b5f88f9c55d1966b383)), closes [#890](https://github.com/Saghen/blink.cmp/issues/890) [#875](https://github.com/Saghen/blink.cmp/issues/875)
* assert vim.lsp.config fn exists before calling ([#927](https://github.com/Saghen/blink.cmp/issues/927)) ([47efef8](https://github.com/Saghen/blink.cmp/commit/47efef83802b26bd2ff7193b24af4c7f747dc145))
* buildVimPlugin ([#933](https://github.com/Saghen/blink.cmp/issues/933)) ([3f5dcbc](https://github.com/Saghen/blink.cmp/commit/3f5dcbc1c28edd2ab31b9bac27cc63de4e56b87c))
* clear context on ignored cursor moved when not on keyword ([0f8de3a](https://github.com/Saghen/blink.cmp/commit/0f8de3abd560f38415d71fc6ee9885c2bf53b814)), closes [#937](https://github.com/Saghen/blink.cmp/issues/937)
* ignore cursor moved when cursor equal before vs after ([17eea33](https://github.com/Saghen/blink.cmp/commit/17eea330a5d111f3cd67f59bb3832cc78f55db14))
* **signature:** use `char_under_cursor` in `on_char_added` handler ([#935](https://github.com/Saghen/blink.cmp/issues/935)) ([275d407](https://github.com/Saghen/blink.cmp/commit/275d40713191e6c0012783ecf762a4faa138098b)), closes [#909](https://github.com/Saghen/blink.cmp/issues/909)

## [0.9.3](https://github.com/Saghen/blink.cmp/compare/v0.9.2...v0.9.3) (2025-01-06)

### Features

* add plaintex, tex and context brackets ([9ffdb7b](https://github.com/Saghen/blink.cmp/commit/9ffdb7b71d0ee9abcccb61d3b8fb60defc4d47ff))
* **path:** replace `/` in front of cursor on directory ([d2b411c](https://github.com/Saghen/blink.cmp/commit/d2b411ca2ec894ccab9d7dc0bd506e44920983ef))

### Bug Fixes

* add .repro to gitignore ([0d1e3c3](https://github.com/Saghen/blink.cmp/commit/0d1e3c34b172bf93380f8675ec962c301f2b5aaa))
* cmdline completion new text not including prefix ([bc480aa](https://github.com/Saghen/blink.cmp/commit/bc480aa927ef4afbf5431f566e8aea7458e9f8df)), closes [#883](https://github.com/Saghen/blink.cmp/issues/883)
* ignore buffer local treesitter option ([d704244](https://github.com/Saghen/blink.cmp/commit/d704244327c1bc1fdd9c0218fe4fff04ca78d3c0)), closes [#913](https://github.com/Saghen/blink.cmp/issues/913)
* ignore non-key char in cmdline completion ([cc0e632](https://github.com/Saghen/blink.cmp/commit/cc0e6329e7603b5749c7fe98a76e39ed17bab860)), closes [#893](https://github.com/Saghen/blink.cmp/issues/893)
* **nix:** use native gcc on macos ([3ab6832](https://github.com/Saghen/blink.cmp/commit/3ab6832b2fc3e49aad9c984089cfc0c5ec788531)), closes [#652](https://github.com/Saghen/blink.cmp/issues/652)
* **nix:** use nix gcc and provide libiconv ([#916](https://github.com/Saghen/blink.cmp/issues/916)) ([5d2d601](https://github.com/Saghen/blink.cmp/commit/5d2d6010d9a5376f9073c1182887e547e3c0ec17))

## [0.9.2](https://github.com/Saghen/blink.cmp/compare/v0.9.1...v0.9.2) (2025-01-03)

### Bug Fixes

* unicode range when checking if char is keyword ([100d3c8](https://github.com/Saghen/blink.cmp/commit/100d3c8bfc8059c2fd2347d00ab70ee91c7ff3ca)), closes [#878](https://github.com/Saghen/blink.cmp/issues/878)

## [0.9.1](https://github.com/Saghen/blink.cmp/compare/v0.9.0...v0.9.1) (2025-01-03)

### Features

* ignore global min_keyword_length for manual trigger ([56f5d31](https://github.com/Saghen/blink.cmp/commit/56f5d314f772617b506d92e46b8e946535edc04e)), closes [#643](https://github.com/Saghen/blink.cmp/issues/643)
* **nix:** add formatter ([#867](https://github.com/Saghen/blink.cmp/issues/867)) ([a0274b1](https://github.com/Saghen/blink.cmp/commit/a0274b10f04ea625b602f6383e3cb2fc38dcfd71)), closes [#736](https://github.com/Saghen/blink.cmp/issues/736)
* normalize search paths ([8a64275](https://github.com/Saghen/blink.cmp/commit/8a64275948cead4de55cd78c7dc74b2c6465605e)), closes [#835](https://github.com/Saghen/blink.cmp/issues/835)
* smarter edit/fuzzy range guessing ([768bcc0](https://github.com/Saghen/blink.cmp/commit/768bcc08282919168cd9bdf29aa8fcbf968fc457)), closes [#46](https://github.com/Saghen/blink.cmp/issues/46)
* sort cmdline items starting with special characters last ([ae3bf0d](https://github.com/Saghen/blink.cmp/commit/ae3bf0d51902df20121378da2ee6893bcc92fa63)), closes [#818](https://github.com/Saghen/blink.cmp/issues/818)
* support custom/customlist cmdline completions directly ([7e7deaa](https://github.com/Saghen/blink.cmp/commit/7e7deaa8bfa578d147e2d1f04a3373fac2afd58f)), closes [#849](https://github.com/Saghen/blink.cmp/issues/849)

### Bug Fixes

* column alignment off by 1 when bounds length == 0 ([0d162bd](https://github.com/Saghen/blink.cmp/commit/0d162bd1b0bbd80a1b5a2dc23d98249d4f8c28f6))
* get full unicode char at cursor position ([e831cab](https://github.com/Saghen/blink.cmp/commit/e831cab7a4c31da02c72044190e9afc1a9ed584c)), closes [#864](https://github.com/Saghen/blink.cmp/issues/864)
* hyphen not being considered a keyword ([8ca8ca4](https://github.com/Saghen/blink.cmp/commit/8ca8ca444e0801411e077cdee655e5efa3f77b36)), closes [#866](https://github.com/Saghen/blink.cmp/issues/866)
* ignore non custom/customlist completion types ([f7857fc](https://github.com/Saghen/blink.cmp/commit/f7857fcb98e52899eb06f07ecb972a430d0de6e0)), closes [#849](https://github.com/Saghen/blink.cmp/issues/849)
* keyword range not being respected for fuzzy matching ([4cc4e37](https://github.com/Saghen/blink.cmp/commit/4cc4e37dd39eec683a9e1a82e71cd1791bda7761))
* path provider not respecting trailing_slash=false ([#862](https://github.com/Saghen/blink.cmp/issues/862)) ([0ff2ed5](https://github.com/Saghen/blink.cmp/commit/0ff2ed566e753844825cd8d2483933861cea55ff))
* set undolevels to force undo point ([4c63b4e](https://github.com/Saghen/blink.cmp/commit/4c63b4e29738268950911bb0c70ffaaba26b53d7)), closes [#852](https://github.com/Saghen/blink.cmp/issues/852)
* use tmp file for downloading to prevent crash on mac on update ([84e065b](https://github.com/Saghen/blink.cmp/commit/84e065bef1504076a0cc3f75f9867b9bce6f328b)), closes [#68](https://github.com/Saghen/blink.cmp/issues/68)
* window direction sorting on Windows ([#846](https://github.com/Saghen/blink.cmp/issues/846)) ([00ad008](https://github.com/Saghen/blink.cmp/commit/00ad008cbea4d0d2b5880e7c7386caa9fc4e5e2b))

### Performance Improvements

* use faster 0.11 vim.validate ([#868](https://github.com/Saghen/blink.cmp/issues/868)) ([a8957ba](https://github.com/Saghen/blink.cmp/commit/a8957bab8faad4436e7ad62244c39335b95450a4))

## [0.9.0](https://github.com/Saghen/blink.cmp/compare/v0.8.2...v0.9.0) (2024-12-31)

### BREAKING CHANGES

* rename `BlinkCmpCompletionMenu*` autocmds to `BlinkCmpMenu*`
* set default documentation max_width to 80
* rename `align_to_component` to `align_to`, add `cursor` option

### Features

* add back support for showing when moving onto trigger character ([cf9cc6e](https://github.com/Saghen/blink.cmp/commit/cf9cc6e43edd2718294ef9801a223c463f50a4ce)), closes [#780](https://github.com/Saghen/blink.cmp/issues/780) [#745](https://github.com/Saghen/blink.cmp/issues/745)
* add callback option to cmp.show ([33b82e5](https://github.com/Saghen/blink.cmp/commit/33b82e5832757319c485ab45c0db4ace554e3183)), closes [#806](https://github.com/Saghen/blink.cmp/issues/806)
* add callback to hide/cancel, rework show callback ([73a5f4e](https://github.com/Saghen/blink.cmp/commit/73a5f4e387ade764a833d290dbb5da77b0d84b4c)), closes [#806](https://github.com/Saghen/blink.cmp/issues/806)
* add type annotation for keymap function params ([#829](https://github.com/Saghen/blink.cmp/issues/829)) ([3d7e773](https://github.com/Saghen/blink.cmp/commit/3d7e773d3e8a02720b23f58ffee631a0c1e2e1d1))
* escape filenames in cmdline ([e53db6a](https://github.com/Saghen/blink.cmp/commit/e53db6a53f85b1c0d56eed66811bfbac520abd6c)), closes [#751](https://github.com/Saghen/blink.cmp/issues/751)
* **nix:** use Cargo.lock instead of hash ([#773](https://github.com/Saghen/blink.cmp/issues/773)) ([d9513ee](https://github.com/Saghen/blink.cmp/commit/d9513ee9f8b111a46e262be2b36172ca335051a2))
* **nix:** use filesets ([#772](https://github.com/Saghen/blink.cmp/issues/772)) ([e524347](https://github.com/Saghen/blink.cmp/commit/e524347697b6664870536dfcdd17e3ab56177b99))
* rename `align_to_component` to `align_to`, add `cursor` option ([9387c75](https://github.com/Saghen/blink.cmp/commit/9387c75af7f8ec1495f4ed5a35cd29f054647dfc)), closes [#344](https://github.com/Saghen/blink.cmp/issues/344)
* rename `BlinkCmpCompletionMenu*` autocmds to `BlinkCmpMenu*` ([fa4312c](https://github.com/Saghen/blink.cmp/commit/fa4312c11f9ab102333f5a18f1a30af5ae636c04))
* run callback for cmp.show, even if menu is open ([a1476d3](https://github.com/Saghen/blink.cmp/commit/a1476d3596f032be3f2d77630c8eee3951d3f74c))
* set default documentation max_width to 80 ([1a61625](https://github.com/Saghen/blink.cmp/commit/1a61625ad2a25c4e1ffffacb4bd0826c244af88f))
* support `@` mode for cmdline ([4c2744d](https://github.com/Saghen/blink.cmp/commit/4c2744d99a13c687e4995fe0a050f40c15dbb2d9)), closes [#696](https://github.com/Saghen/blink.cmp/issues/696)
* support configuring clipboard register for snippets ([8f51a4e](https://github.com/Saghen/blink.cmp/commit/8f51a4ec23773cc96ec6b3ca336a5d70eebb2fb2)), closes [#800](https://github.com/Saghen/blink.cmp/issues/800)
* support unsafe no lock for fuzzy matcher ([6f8da35](https://github.com/Saghen/blink.cmp/commit/6f8da35fc8f1f8046d25b88b7708178cb4126abe)), closes [#817](https://github.com/Saghen/blink.cmp/issues/817)
* support windows drives for path source ([98fded2](https://github.com/Saghen/blink.cmp/commit/98fded25d772a749cbf26e569e735ca7a3fb9d12)), closes [#612](https://github.com/Saghen/blink.cmp/issues/612)
* use filter text on non-prefixed test in cmdline ([8c194b6](https://github.com/Saghen/blink.cmp/commit/8c194b6fa34b174b2ab30ff1d005c6b1b03ba523))

### Bug Fixes

* **accept/brackets:** respect `item.kind` when moving cursor ([#779](https://github.com/Saghen/blink.cmp/issues/779)) ([c54dfbf](https://github.com/Saghen/blink.cmp/commit/c54dfbfdfabac3b5a66ba90c89fab86d7651d106))
* add missing regex file for path source ([1118d07](https://github.com/Saghen/blink.cmp/commit/1118d07c1b720873fe3498a662a265ae8a9a7ee4)), closes [#834](https://github.com/Saghen/blink.cmp/issues/834)
* alignment double offset on align_to ([24d6868](https://github.com/Saghen/blink.cmp/commit/24d6868d0a18bb02cbee7fc5cc2a09fa309e3eb7))
* apply non-snippet detection to non-snippet kinds ([434ea2b](https://github.com/Saghen/blink.cmp/commit/434ea2b05c2bae0cff6249893c8324fa3a56d865)), closes [#790](https://github.com/Saghen/blink.cmp/issues/790)
* avoid namespace collision with vim.api.keyset.keymap ([63718e9](https://github.com/Saghen/blink.cmp/commit/63718e93d46f07b869f033fd13b78597ebbde72b)), closes [#767](https://github.com/Saghen/blink.cmp/issues/767)
* check enabled before showing trigger and on mapping ([e670720](https://github.com/Saghen/blink.cmp/commit/e6707202772be974ae2d54239b806707bb72ccdb)), closes [#716](https://github.com/Saghen/blink.cmp/issues/716)
* clamp text edit end character to start character, if lines equal ([6891bcb](https://github.com/Saghen/blink.cmp/commit/6891bcb06b6f21de68278991f29e53452b822d48)), closes [#634](https://github.com/Saghen/blink.cmp/issues/634)
* create target/release dir, if it doesn't exist ([4020c23](https://github.com/Saghen/blink.cmp/commit/4020c2353b906950cb80be2fc1fabee8a9a9c291)), closes [#819](https://github.com/Saghen/blink.cmp/issues/819)
* documentation losing syntax highlighting on doc reopen ([#768](https://github.com/Saghen/blink.cmp/issues/768)) ([ef59763](https://github.com/Saghen/blink.cmp/commit/ef59763c8a58fb1dedfb2d58a2ebd0fbe247f96c)), closes [#703](https://github.com/Saghen/blink.cmp/issues/703)
* don't prevent show() when ghost-text is visible ([#796](https://github.com/Saghen/blink.cmp/issues/796)) ([59d6b4f](https://github.com/Saghen/blink.cmp/commit/59d6b4fbe94cfc350b1392772a61cbcf942619c7))
* filter help tags by arg prefix ([21da714](https://github.com/Saghen/blink.cmp/commit/21da71413bf749f21d2174c1cd7e8efa40809a93)), closes [#818](https://github.com/Saghen/blink.cmp/issues/818)
* flatten leaving empty tables ([#799](https://github.com/Saghen/blink.cmp/issues/799)) ([021216d](https://github.com/Saghen/blink.cmp/commit/021216da4683db5627d4b321dbde075aa771b5e7))
* getcmdcompltype returning empty string ([eb9e651](https://github.com/Saghen/blink.cmp/commit/eb9e651bca40bbfb4de2a77a293a1e18bb373ee8)), closes [#696](https://github.com/Saghen/blink.cmp/issues/696)
* remove redundant is enabled check ([f4add54](https://github.com/Saghen/blink.cmp/commit/f4add54f999962e6385d42bad341366b85184217))
* return incomplete on err/nil from lsp ([1ef9bb9](https://github.com/Saghen/blink.cmp/commit/1ef9bb97740e7b55401e213da5dd6b04b77e56ff)), closes [#719](https://github.com/Saghen/blink.cmp/issues/719)
* set default details to empty array ([0350fee](https://github.com/Saghen/blink.cmp/commit/0350feedfa8adb07b6750f6d9150c26e13eae0d2))
* trigger context initial_kind resetting ([3ef27bc](https://github.com/Saghen/blink.cmp/commit/3ef27bcd7ff2367c6053421d4a8981bedc33d53e)), closes [#803](https://github.com/Saghen/blink.cmp/issues/803)
* use correct regex for filenames ([8df826f](https://github.com/Saghen/blink.cmp/commit/8df826f168f102d0fbea92cbd85995ce66a821c7)), closes [#761](https://github.com/Saghen/blink.cmp/issues/761)
* use existing arg prefix for help filtering in cmdline ([c593e83](https://github.com/Saghen/blink.cmp/commit/c593e8385d9f8f82a6e108fbabcd1f64fce72684))
* wait for all LSPs to respond before showing ([86a13ae](https://github.com/Saghen/blink.cmp/commit/86a13aeb104d6ea782557518ee1a350712df7bd7)), closes [#691](https://github.com/Saghen/blink.cmp/issues/691)

## [0.8.2](https://github.com/Saghen/blink.cmp/compare/v0.8.1...v0.8.2) (2024-12-23)

### Features

* improve auto_show flexibility ([#697](https://github.com/Saghen/blink.cmp/issues/697)) ([a937edd](https://github.com/Saghen/blink.cmp/commit/a937edde979a8ff140779fa0d425af566bc73cb7))
* improve error messages for pre built binaries ([c36b60c](https://github.com/Saghen/blink.cmp/commit/c36b60c22f7357d741c9166e4d509b745cc8b441))
* sort cmdline completions case insensitive ([b68e924](https://github.com/Saghen/blink.cmp/commit/b68e92426af46d60f08a4d2f58ed1e44d4e56087)), closes [#715](https://github.com/Saghen/blink.cmp/issues/715)
* support dynamic selection mode ([c1017f0](https://github.com/Saghen/blink.cmp/commit/c1017f0a827736e3397f9b60dfe8e8ebb4a0ae72))

### Bug Fixes

* add git to nix build dependencies and shell ([ed1d4f5](https://github.com/Saghen/blink.cmp/commit/ed1d4f573f8988353d6e437f5e70ee334ea099fe))
* add java to blocked filetypes for semantic token auto_brackets ([#729](https://github.com/Saghen/blink.cmp/issues/729)) ([140ed36](https://github.com/Saghen/blink.cmp/commit/140ed3633419965e8f2228af0d5fbaa4c1956f78))
* add missing git.lua for downloader ([f7bef25](https://github.com/Saghen/blink.cmp/commit/f7bef25052820d4d7604a296c739ba9d885117f8))
* auto_show function logic ([#707](https://github.com/Saghen/blink.cmp/issues/707)) ([4ef6d1e](https://github.com/Saghen/blink.cmp/commit/4ef6d1ee29e8ae9138a47bba9374b7c0c97452b6)), closes [#697](https://github.com/Saghen/blink.cmp/issues/697)
* check version sha of locally built, better detection ([3ffd31d](https://github.com/Saghen/blink.cmp/commit/3ffd31d0c52a51d064f4761d5c0bfad64129c1e9)), closes [#68](https://github.com/Saghen/blink.cmp/issues/68)
* doc scrollbar render ([#724](https://github.com/Saghen/blink.cmp/issues/724)) ([8f71ccb](https://github.com/Saghen/blink.cmp/commit/8f71ccbe668860a4ebcaed3928d80d2119559ad9))
* inherit package.cpath in worker thread ([#726](https://github.com/Saghen/blink.cmp/issues/726)) ([b6c7762](https://github.com/Saghen/blink.cmp/commit/b6c7762407b6c4521b46244f35fab05cfd1c6863)), closes [#725](https://github.com/Saghen/blink.cmp/issues/725)
* **notifications:** add title to notifications ([#722](https://github.com/Saghen/blink.cmp/issues/722)) ([f93af0f](https://github.com/Saghen/blink.cmp/commit/f93af0f486ada13e8c34f42c911788b9232b811f))
* prebuilt binary error message always firing ([cab0e8e](https://github.com/Saghen/blink.cmp/commit/cab0e8e169a2c595018f9fdb981e056094bd5aeb))

## [0.8.1](https://github.com/Saghen/blink.cmp/compare/v0.8.0...v0.8.1) (2024-12-21)

### Features

* **path:** sort directories first, then by name lowercase ([400de65](https://github.com/Saghen/blink.cmp/commit/400de65da795b5939ace36978de3d1edeb84b0de))

### Bug Fixes

* checkhealth after checksum changes ([d8ffbe9](https://github.com/Saghen/blink.cmp/commit/d8ffbe95190a776c6a28c86650efcbc23c5f6521)), closes [#669](https://github.com/Saghen/blink.cmp/issues/669)
* duplicate cursor moved event firing ([e360828](https://github.com/Saghen/blink.cmp/commit/e360828a188dc30658067eac63feded08857c076))
* get global mapping for fallback in cmdline mode ([92da013](https://github.com/Saghen/blink.cmp/commit/92da0133b240e60100fcb04b32fcd7270f765d94)), closes [#674](https://github.com/Saghen/blink.cmp/issues/674)
* internal types for config not using strict config ([bdece4e](https://github.com/Saghen/blink.cmp/commit/bdece4e90e70baee956e2351220527a619d25052))
* **path:** no items when file fails stat ([4218120](https://github.com/Saghen/blink.cmp/commit/421812086661bba3aa318030eee12719fc5da072)), closes [#688](https://github.com/Saghen/blink.cmp/issues/688)
* type signature for enabled indicating ctx could be passed ([3cb7208](https://github.com/Saghen/blink.cmp/commit/3cb7208546b4e1f0c5e492cbcfccd083a1c89351)), closes [#695](https://github.com/Saghen/blink.cmp/issues/695)
* use context.get_line() when getting preview undo text edit ([0f92fb8](https://github.com/Saghen/blink.cmp/commit/0f92fb8dcff634e880a60e266f041dfe175b82bf)), closes [#702](https://github.com/Saghen/blink.cmp/issues/702)
* wrong key upstreamed by cmdline_events ([4757317](https://github.com/Saghen/blink.cmp/commit/475731741bbd8266767d48ad46b63f715577ac8e)), closes [#700](https://github.com/Saghen/blink.cmp/issues/700)

## [0.8.0](https://github.com/Saghen/blink.cmp/compare/v0.7.6...v0.8.0) (2024-12-20)

> [!IMPORTANT]
> `sources.completion.enabled_providers` has been moved to `sources.default`

### Highlights

* Cmdline completions! ([#323](https://github.com/Saghen/blink.cmp/issues/323))
* Sorting now respects LSP hints more directly and doesn't sort alphabetically or by kind by default 
* Sources v2 ([#465](https://github.com/Saghen/blink.cmp/issues/465)), adds support for async sources, timeouts, smarter fallbacks, adding sources at runtime and more!

### Features

* `extra_curl_args` option for prebuilt binaries download ([4c2e9e7](https://github.com/Saghen/blink.cmp/commit/4c2e9e74905502e3662fbd4af7b0d1b680971a04)), closes [#481](https://github.com/Saghen/blink.cmp/issues/481)
* add [ to show_on_x_blocked_trigger_characters ([#632](https://github.com/Saghen/blink.cmp/issues/632)) ([046a2af](https://github.com/Saghen/blink.cmp/commit/046a2af7580ba90cda9ffebbab3f1fe68ca1fa59))
* add `{` to `show_on_x_blocked_trigger_characters` ([712bd30](https://github.com/Saghen/blink.cmp/commit/712bd301fc2158e6443144ff9c8ce01b8bf5a77b)), closes [#597](https://github.com/Saghen/blink.cmp/issues/597)
* add global transform_items and min_keyword_length ([e07cb27](https://github.com/Saghen/blink.cmp/commit/e07cb2756d5cc339dfa4bf4d9bc91b3779dbb743)), closes [#502](https://github.com/Saghen/blink.cmp/issues/502) [#504](https://github.com/Saghen/blink.cmp/issues/504)
* allow providers customize documentation rendering ([#650](https://github.com/Saghen/blink.cmp/issues/650)) ([bc94c75](https://github.com/Saghen/blink.cmp/commit/bc94c7508379b4828206759562162ce10af82b68))
* cmdline completions ([#323](https://github.com/Saghen/blink.cmp/issues/323)) ([414d615](https://github.com/Saghen/blink.cmp/commit/414d615afcd9268522160dca5855fef8132f6e9e))
* **cmdline:** allow configuring separate cmdline preset ([#532](https://github.com/Saghen/blink.cmp/issues/532)) ([13b3e57](https://github.com/Saghen/blink.cmp/commit/13b3e572e863bafe8fad3a97473271a2c9c700ce))
* **config:** add partial types for each config option ([#549](https://github.com/Saghen/blink.cmp/issues/549)) ([c3bba64](https://github.com/Saghen/blink.cmp/commit/c3bba64d6c32adf4156e9d1273b14494838a3058)), closes [#427](https://github.com/Saghen/blink.cmp/issues/427)
* **config:** allow plugins to disable blink for some buffers ([#556](https://github.com/Saghen/blink.cmp/issues/556)) ([c8e86a3](https://github.com/Saghen/blink.cmp/commit/c8e86a3ed1eff07e2c1108779a720d3b4c6b86a7))
* demote snippets from LSP explicitly ([b7c84ac](https://github.com/Saghen/blink.cmp/commit/b7c84ac4e17f3e160a626a9a89b609e02151a135))
* disable keymaps when no cmdline sources are defined ([88ec601](https://github.com/Saghen/blink.cmp/commit/88ec6010ddbb249257d22265b8a96842f10c7142))
* enable auto-brackets by default ([4d099ee](https://github.com/Saghen/blink.cmp/commit/4d099eeb72cfbd6496376fbb3265a1887a7c85fe))
* enable treesiter highlight in menu per source ([#526](https://github.com/Saghen/blink.cmp/issues/526)) ([f99b03c](https://github.com/Saghen/blink.cmp/commit/f99b03c756b32680eea28e89f95e3c6987cc6c80)), closes [#438](https://github.com/Saghen/blink.cmp/issues/438)
* ensure nvim 0.10+ on startup ([30a4a52](https://github.com/Saghen/blink.cmp/commit/30a4a52d2362e3a272ae1cf28552852ae09b38a9))
* expose `cmp.is_visible()` api ([2c826d9](https://github.com/Saghen/blink.cmp/commit/2c826d9167c7236f6079790bc35bcb024021e683)), closes [#535](https://github.com/Saghen/blink.cmp/issues/535)
* filter out LSP text items by default ([814392a](https://github.com/Saghen/blink.cmp/commit/814392a7164336fe5fbd6d4b97a69dce9eb6e4ef))
* honor extended luasnip filetypes and cache each ([#625](https://github.com/Saghen/blink.cmp/issues/625)) ([c3ef922](https://github.com/Saghen/blink.cmp/commit/c3ef9223a69ededed611b3ef617bac5651b87833))
* ignore when source defining trigger character returns no items ([684950d](https://github.com/Saghen/blink.cmp/commit/684950d3c4027e10a46f4bd478182839760b8fde)), closes [#597](https://github.com/Saghen/blink.cmp/issues/597)
* include ghost text in is_visible ([1006662](https://github.com/Saghen/blink.cmp/commit/1006662ad53c92adf9ae6f2d05cee38f613d08ff))
* increase max length of buffer entry to 512 characters ([4ab0860](https://github.com/Saghen/blink.cmp/commit/4ab0860d361234e714d3beac2828d215f3f481e1)), closes [#478](https://github.com/Saghen/blink.cmp/issues/478)
* merge resolved item with item ([7a83acf](https://github.com/Saghen/blink.cmp/commit/7a83acf5b3cba829b07a05009866548c8e948ac0)), closes [#553](https://github.com/Saghen/blink.cmp/issues/553)
* reset whole luasnip cache on snippets added ([bff6c0f](https://github.com/Saghen/blink.cmp/commit/bff6c0f06bdc1114c5816b0f6b19ad6a7e15a638))
* resolve help tags ourselves in cmdline ([02051bf](https://github.com/Saghen/blink.cmp/commit/02051bf2d9c8f116680659f091b510598a4aea38)), closes [#631](https://github.com/Saghen/blink.cmp/issues/631)
* rework cmdline source ([8f718cc](https://github.com/Saghen/blink.cmp/commit/8f718cc0d845348fd19c964aa6a82b06ea49c210))
* rework download logic with checksums ([#629](https://github.com/Saghen/blink.cmp/issues/629)) ([53d22cb](https://github.com/Saghen/blink.cmp/commit/53d22cbac470b5ed8bfa2c3c195b82e03b501629))
* set cursor position for additional text edits ([f0ab5e5](https://github.com/Saghen/blink.cmp/commit/f0ab5e504b160d4bc60f52a02e8d2453052420d3)), closes [#223](https://github.com/Saghen/blink.cmp/issues/223)
* set path to fallback to buffer by default ([c9594d5](https://github.com/Saghen/blink.cmp/commit/c9594d5682ca421ee1bcb4284329f2d7dde71b50))
* sort on score and sort_text only by default, disable frecency and proximity on no keyword ([76230d5](https://github.com/Saghen/blink.cmp/commit/76230d5a4a02cd1db8dec33b6eed0b4bc2dcbc53)), closes [#570](https://github.com/Saghen/blink.cmp/issues/570)
* sources v2 ([#465](https://github.com/Saghen/blink.cmp/issues/465)) ([533608f](https://github.com/Saghen/blink.cmp/commit/533608f56b912aba98250a3c1501ee687d7cf5eb)), closes [#386](https://github.com/Saghen/blink.cmp/issues/386) [#219](https://github.com/Saghen/blink.cmp/issues/219) [#328](https://github.com/Saghen/blink.cmp/issues/328) [#331](https://github.com/Saghen/blink.cmp/issues/331) [#312](https://github.com/Saghen/blink.cmp/issues/312) [#454](https://github.com/Saghen/blink.cmp/issues/454) [#444](https://github.com/Saghen/blink.cmp/issues/444) [#372](https://github.com/Saghen/blink.cmp/issues/372) [#475](https://github.com/Saghen/blink.cmp/issues/475)
* support callback on `cmp.accept()` ([be3e9cf](https://github.com/Saghen/blink.cmp/commit/be3e9cf435588b3ff4de7abcb04ec90c812f1871))
* support configuring prefetch_on_insert, disable by default ([9d4286f](https://github.com/Saghen/blink.cmp/commit/9d4286f9a410af788ee8406ec45e268aa4b23c9f))
* **trigger:** prefetch on InsertEnter ([#507](https://github.com/Saghen/blink.cmp/issues/507)) ([7e98665](https://github.com/Saghen/blink.cmp/commit/7e9866529768065e0e191e436fc60220bef5185e))
* use block icon for tailwind items ([#544](https://github.com/Saghen/blink.cmp/issues/544)) ([1502c75](https://github.com/Saghen/blink.cmp/commit/1502c754b9c241eecab1393d74a4eb6ccdfe0e64))
* use number[] for ui_cmdline_pos ([80a5198](https://github.com/Saghen/blink.cmp/commit/80a5198a357ddcee97d94ac2be9a3590cd5a63f5))
* validate config doesn't have erroneous fields ([834163e](https://github.com/Saghen/blink.cmp/commit/834163eebdfdb1ca2a4a54b1e8d4c8d2c8184c12)), closes [#501](https://github.com/Saghen/blink.cmp/issues/501)
* **window:** add `filetype` configuration ([#499](https://github.com/Saghen/blink.cmp/issues/499)) ([eb6213b](https://github.com/Saghen/blink.cmp/commit/eb6213b974e604f9ef8560e6c2379d757e81954d))

### Bug Fixes

* **accept:** schecule `fuzzy.access` using uv.new_work ([#522](https://github.com/Saghen/blink.cmp/issues/522)) ([f66f19c](https://github.com/Saghen/blink.cmp/commit/f66f19c864e68ee5e2fb452648b7f6995ddadaa3))
* account for cmdheight in cmdline_position (thanks [@lnrds](https://github.com/lnrds)!) ([6b67d16](https://github.com/Saghen/blink.cmp/commit/6b67d16036b780f49e44d3f5de207d3c7301f3e4)), closes [#538](https://github.com/Saghen/blink.cmp/issues/538)
* add '=' to cmdline trigger characters ([fb03ca7](https://github.com/Saghen/blink.cmp/commit/fb03ca7dd41fc5c234bf5ec089568f4eae584efb)), closes [#541](https://github.com/Saghen/blink.cmp/issues/541)
* add back, skip undo point for snippet kinds ([1563079](https://github.com/Saghen/blink.cmp/commit/15630796fc8c3c45c345d2fe73de6b3a1dc9bb11))
* add gcc to flake.nix ([380bccf](https://github.com/Saghen/blink.cmp/commit/380bccf6eb1e3135fbab986f54aabd9147ff5977)), closes [#581](https://github.com/Saghen/blink.cmp/issues/581)
* add icon gap on ellipsis, remove references to renderer ([793b6ac](https://github.com/Saghen/blink.cmp/commit/793b6ac94efe754d31299b7de2e953244fe0d4ab))
* add mode to context type ([f1afb8c](https://github.com/Saghen/blink.cmp/commit/f1afb8c77686ba6f5159dcb7591bf21efcc5f410))
* allow 'none' preset for keymaps in validation ([bf1fd6a](https://github.com/Saghen/blink.cmp/commit/bf1fd6a690882a9bf5e07ded70fb3bba5d8a5bdf))
* always get latest keyword ([13853d5](https://github.com/Saghen/blink.cmp/commit/13853d5c9cf827fc051fa7adebe701cce2ecd22f)), closes [#539](https://github.com/Saghen/blink.cmp/issues/539)
* check raw key for space in cmdline_events ([7be970e](https://github.com/Saghen/blink.cmp/commit/7be970e278334482710e1f37936c8480b522a751))
* check that scrollbar is not nil ([790369b](https://github.com/Saghen/blink.cmp/commit/790369bb9998d1f9a01f67378e407622b492cf69)), closes [#525](https://github.com/Saghen/blink.cmp/issues/525)
* clear LuaSnip cache on snippet updates ([#664](https://github.com/Saghen/blink.cmp/issues/664)) ([b1b58e7](https://github.com/Saghen/blink.cmp/commit/b1b58e7b9895f43e64891346f76238d697aaadb9))
* cmdline event suppression and scrollbar rendering ([e3b3fde](https://github.com/Saghen/blink.cmp/commit/e3b3fdedbc14afe7361228f7d2c8ce84cee272a6)), closes [#523](https://github.com/Saghen/blink.cmp/issues/523)
* cmdline events firing cursor moved when changed ([97989c8](https://github.com/Saghen/blink.cmp/commit/97989c8ee257239566c4d08264b080703ccc923b)), closes [#520](https://github.com/Saghen/blink.cmp/issues/520)
* cmdline including current arg prefix ([49bff2b](https://github.com/Saghen/blink.cmp/commit/49bff2bf23f15ae31a245e9ffd1b79a9f95bed61)), closes [#609](https://github.com/Saghen/blink.cmp/issues/609)
* **cmdline:** not delete buf when hide scrollbar cause it seems not necessary ([#591](https://github.com/Saghen/blink.cmp/issues/591)) ([0046d0c](https://github.com/Saghen/blink.cmp/commit/0046d0cc3e9bdd2dc36c2ec7a79aee32e76afa73))
* completion auto_insert replace incorrect range ([#621](https://github.com/Saghen/blink.cmp/issues/621)) ([5926869](https://github.com/Saghen/blink.cmp/commit/59268691492bc1abfb0ed91a1cb3ac9fcc01650c)), closes [#460](https://github.com/Saghen/blink.cmp/issues/460)
* **completion:** disable in prompt buffers ([#574](https://github.com/Saghen/blink.cmp/issues/574)) ([1097d4e](https://github.com/Saghen/blink.cmp/commit/1097d4e24909c5b1a15b1ac6907ec26f78f5d22c))
* consider functions as snippet commands ([d065c87](https://github.com/Saghen/blink.cmp/commit/d065c87b59a301065f863134d3a8271bdff6f630))
* disable ghost text in command mode ([ad17735](https://github.com/Saghen/blink.cmp/commit/ad17735a6ddb4255cad6f0af574150761baf5ee4)), closes [#524](https://github.com/Saghen/blink.cmp/issues/524)
* don't block trigger characters in command mode ([0a729ae](https://github.com/Saghen/blink.cmp/commit/0a729ae1c4ab48695fb327161768720a82ed698f)), closes [#541](https://github.com/Saghen/blink.cmp/issues/541)
* don't create undo point when kind equals snippet ([343e89d](https://github.com/Saghen/blink.cmp/commit/343e89d39deb14b5cc6de844ce069ae3d98d7403))
* don't duplicate `.` when completing hidden files in path source ([#557](https://github.com/Saghen/blink.cmp/issues/557)) ([714e2b5](https://github.com/Saghen/blink.cmp/commit/714e2b5f3fdcabd6ad31f98c71f930b260644c72))
* don't show when moving on trigger character, hide on no items after trigger ([7a04612](https://github.com/Saghen/blink.cmp/commit/7a046122de512db8194dae130d691526b5031456)), closes [#545](https://github.com/Saghen/blink.cmp/issues/545)
* duplicate snippets in luasnip when autosnippets are enabled ([12ffc10](https://github.com/Saghen/blink.cmp/commit/12ffc10c6283ac148a89d72b5540d819fc80e2ff))
* fire cursor moved when jumping between tab stops in a snippet ([1e4808e](https://github.com/Saghen/blink.cmp/commit/1e4808e3429bc060fa538728115edcaebbfc5c35)), closes [#545](https://github.com/Saghen/blink.cmp/issues/545)
* **fuzzy:** initialize db only once ([7868d47](https://github.com/Saghen/blink.cmp/commit/7868d477018f73bff6ca60757c1171223084bd12))
* **ghost_text:** correctly disable on cmdline ([54d1a98](https://github.com/Saghen/blink.cmp/commit/54d1a980595e056e7be45a10d1cc8c34159f6d74))
* ignore snippets that only contain text ([284dd37](https://github.com/Saghen/blink.cmp/commit/284dd37f9bbc632f8281d6361e877db5b45e6ff0)), closes [#624](https://github.com/Saghen/blink.cmp/issues/624)
* ignore sort_text if either are nil ([3ba583c](https://github.com/Saghen/blink.cmp/commit/3ba583cedb321291f3145b6e85039ed315b06b17)), closes [#595](https://github.com/Saghen/blink.cmp/issues/595)
* include space for cmdline events ([38b9c4f](https://github.com/Saghen/blink.cmp/commit/38b9c4f36a815fd3d9094e6d5c236a83dbb68ff9))
* incorrect bounds when removing word under cursor in buffer sources ([d682165](https://github.com/Saghen/blink.cmp/commit/d6821651b145c730ca59faee638947a067243b24)), closes [#560](https://github.com/Saghen/blink.cmp/issues/560)
* **keymap:** incorrect merging strategy ([f88bd66](https://github.com/Saghen/blink.cmp/commit/f88bd66d88e9248276996c0f5b5c2b7fa5aa851f)), closes [#599](https://github.com/Saghen/blink.cmp/issues/599)
* **keymap:** normalize mapping capitalization ([#599](https://github.com/Saghen/blink.cmp/issues/599)) ([596a7ab](https://github.com/Saghen/blink.cmp/commit/596a7ab89cca7cdcddc0422e8f5a449042b7ff80))
* **luasnip:** add global_snippets with ft="all" ([#546](https://github.com/Saghen/blink.cmp/issues/546)) ([9f1fb75](https://github.com/Saghen/blink.cmp/commit/9f1fb75b3ec282253ce6392360a584d0234904d0))
* on_key for cmdline events ([89479f3](https://github.com/Saghen/blink.cmp/commit/89479f3f4c9096330a321a6cc438f5bc3f1e596b)), closes [#534](https://github.com/Saghen/blink.cmp/issues/534)
* prefetch first item when selection == 'manual' | 'auto_insert' ([a8222cf](https://github.com/Saghen/blink.cmp/commit/a8222cf1ccbf24818ae926f94779267659809ab0)), closes [#627](https://github.com/Saghen/blink.cmp/issues/627)
* **provider:** add missing validations ([#516](https://github.com/Saghen/blink.cmp/issues/516)) ([1eda2b9](https://github.com/Saghen/blink.cmp/commit/1eda2b989213b54a66589b44236bfcb427c9a5fe))
* **provider:** restore path completion source ([#506](https://github.com/Saghen/blink.cmp/issues/506)) ([b2d13ba](https://github.com/Saghen/blink.cmp/commit/b2d13ba7a0aa6f53d3b0db2cd5ede7827ec72f5b)), closes [#465](https://github.com/Saghen/blink.cmp/issues/465)
* re-enable scrollbar on menu ([d48bb17](https://github.com/Saghen/blink.cmp/commit/d48bb176ae3a8d2f3fa4240f9098b94f1f0947ca)), closes [#519](https://github.com/Saghen/blink.cmp/issues/519)
* remove vim.notify on snippet only containing text ([59ef8a4](https://github.com/Saghen/blink.cmp/commit/59ef8a45eeafef35d8196473d86acbe515116027))
* respect opts.index when checking if cmp.accept can be run ([ea12c51](https://github.com/Saghen/blink.cmp/commit/ea12c516ef43f14683903064bad7612d6e6a6a02)), closes [#633](https://github.com/Saghen/blink.cmp/issues/633)
* revert enabled logic or ([cfd1b7f](https://github.com/Saghen/blink.cmp/commit/cfd1b7f1b24ed77049d978c0a8813097a6e3acc7)), closes [#574](https://github.com/Saghen/blink.cmp/issues/574) [#577](https://github.com/Saghen/blink.cmp/issues/577)
* run callback when LSP client returns nil ([f9b72e3](https://github.com/Saghen/blink.cmp/commit/f9b72e3c1a1b61984b9128fb3e024fdf8a3d07fa)), closes [#543](https://github.com/Saghen/blink.cmp/issues/543)
* schedule get_bufnrs for buffer source ([342c5ed](https://github.com/Saghen/blink.cmp/commit/342c5ed6336d2850c59937747daccb4e880319e0))
* signature help window documentation rendering ([264aea4](https://github.com/Saghen/blink.cmp/commit/264aea42fb2de42a377ae573141cfb61ab849f47))
* sort by sortText/label again ([30705ab](https://github.com/Saghen/blink.cmp/commit/30705aba472b5c67b3a34d84f40d36add75b4c44)), closes [#444](https://github.com/Saghen/blink.cmp/issues/444)
* **sources:** set default item kind to `Property` ([#505](https://github.com/Saghen/blink.cmp/issues/505)) ([08ff824](https://github.com/Saghen/blink.cmp/commit/08ff824de4b76d314f7871e0345f7990b3faccb4))
* **tailwind:** color rendering ([#601](https://github.com/Saghen/blink.cmp/issues/601)) ([02528e8](https://github.com/Saghen/blink.cmp/commit/02528e8ccbe4d0cef5e1df52eda419c5ed557ad3))
* uncomment event emitter autocmd ([e1cf25f](https://github.com/Saghen/blink.cmp/commit/e1cf25fea50593993777865b3cca1db556a4a90b))
* use luasnip get_snippet_filetypes, remove global_snippets option ([c0b5ae9](https://github.com/Saghen/blink.cmp/commit/c0b5ae940d7516eb07ca499f5a46445f216c46d3)), closes [#603](https://github.com/Saghen/blink.cmp/issues/603)
* use transform_items on resolve ([85176f7](https://github.com/Saghen/blink.cmp/commit/85176f7e3264b8ac3b571db12191416a4dce0303)), closes [#614](https://github.com/Saghen/blink.cmp/issues/614)

## [0.7.5](https://github.com/Saghen/blink.cmp/compare/v0.7.4...v0.7.5) (2024-12-10)

### Features

* use `enabled` function instead of blocked_filetypes ([a6636c1](https://github.com/Saghen/blink.cmp/commit/a6636c1c38704c1581750b29abb0addabd198b89)), closes [#440](https://github.com/Saghen/blink.cmp/issues/440)

### Bug Fixes

* **fallback:** make fallback work with buffer-local mappings ([#483](https://github.com/Saghen/blink.cmp/issues/483)) ([8b553f6](https://github.com/Saghen/blink.cmp/commit/8b553f65419d051fe84eeeda3e2071e104c4f272))

## [0.7.4](https://github.com/Saghen/blink.cmp/compare/v0.7.3...v0.7.4) (2024-12-09)

### Features

* support non-latin characters for keyword and buffer source ([51d5f59](https://github.com/Saghen/blink.cmp/commit/51d5f598adf7f1cd1bb188011bb761c1856083a9)), closes [#130](https://github.com/Saghen/blink.cmp/issues/130) [#388](https://github.com/Saghen/blink.cmp/issues/388)

### Bug Fixes

* check response.err instead of response.error ([#473](https://github.com/Saghen/blink.cmp/issues/473)) ([e720477](https://github.com/Saghen/blink.cmp/commit/e7204774a6e99c5e222c930565353c757d2d0ec1))
* completion.trigger.show_in_snippet ([#452](https://github.com/Saghen/blink.cmp/issues/452)) ([a42afb6](https://github.com/Saghen/blink.cmp/commit/a42afb61ad455816aef6baa1992f8de45e9a5eb1)), closes [#443](https://github.com/Saghen/blink.cmp/issues/443)
* documentation window auto show once and for all ([624676e](https://github.com/Saghen/blink.cmp/commit/624676efda13aa78a042aba29ee13e109821fa76)), closes [#430](https://github.com/Saghen/blink.cmp/issues/430)
* fill in cargoHash ([aa70277](https://github.com/Saghen/blink.cmp/commit/aa70277f537c942f7e477fd135531fffc37d81f3))
* **highlight:** fix invalid highlight for doc separator ([#449](https://github.com/Saghen/blink.cmp/issues/449)) ([283a6af](https://github.com/Saghen/blink.cmp/commit/283a6afee44e0aea9b17074d49779558354d3520))
* luasnip resolve documentation ([85f318b](https://github.com/Saghen/blink.cmp/commit/85f318b6db5b48d825d4ef575b405a8d41233753)), closes [#437](https://github.com/Saghen/blink.cmp/issues/437)
* make buffer events options required ([d0b0e16](https://github.com/Saghen/blink.cmp/commit/d0b0e16671733432986953bf4ddff268eb5b2d7c))
* **render:** not render two separator for doc window ([#451](https://github.com/Saghen/blink.cmp/issues/451)) ([fc12fa9](https://github.com/Saghen/blink.cmp/commit/fc12fa99d4e1274d331c2004e777981193f7d6f8))
* revert luasnip source to use current cursor position ([5cfff34](https://github.com/Saghen/blink.cmp/commit/5cfff3433a2afc3f4e29eb4e3caa8f80953f0cfb))

## [0.7.3](https://github.com/Saghen/blink.cmp/compare/v0.7.2...v0.7.3) (2024-12-03)

### Bug Fixes

* revert to original logic for updating menu position ([99129b6](https://github.com/Saghen/blink.cmp/commit/99129b67759c1b78198e527eae9cc91121cded29)), closes [#436](https://github.com/Saghen/blink.cmp/issues/436)

## [0.7.2](https://github.com/Saghen/blink.cmp/compare/v0.7.1...v0.7.2) (2024-12-03)

> [!IMPORTANT]
> A native `luasnip` source has been added, please see the [README](https://github.com/Saghen/blink.cmp#luasnip) for the configuration

### Features

* add `auto_show` property for menu ([29fe017](https://github.com/Saghen/blink.cmp/commit/29fe017624030fa53ee053626762fa385a9adb19)), closes [#402](https://github.com/Saghen/blink.cmp/issues/402)
* clamp text edit range to bounds ([7ceff61](https://github.com/Saghen/blink.cmp/commit/7ceff61595aae682b421a68e208719b1523c7b44)), closes [#257](https://github.com/Saghen/blink.cmp/issues/257)
* expose reload function ([f4e53f2](https://github.com/Saghen/blink.cmp/commit/f4e53f2ac7a3d8c3ef47be0dffa97dca637bf696)), closes [#428](https://github.com/Saghen/blink.cmp/issues/428)
* native luasnip source ([08b59ed](https://github.com/Saghen/blink.cmp/commit/08b59edc59950be279f8c72a20bd7897e9f0d021)), closes [#378](https://github.com/Saghen/blink.cmp/issues/378) [#401](https://github.com/Saghen/blink.cmp/issues/401) [#432](https://github.com/Saghen/blink.cmp/issues/432)

### Bug Fixes

* avoid removing words for current line on out of focus buffers ([2cbb02d](https://github.com/Saghen/blink.cmp/commit/2cbb02da58ab40f2bfd3dd85f80cba76d6279987)), closes [#433](https://github.com/Saghen/blink.cmp/issues/433)
* documentation not updating after manually opened ([8c1fdc9](https://github.com/Saghen/blink.cmp/commit/8c1fdc901cfead1cd88ed3e652d45ca7d75a3d3f)), closes [#430](https://github.com/Saghen/blink.cmp/issues/430)
* handle nil line ([#429](https://github.com/Saghen/blink.cmp/issues/429)) ([38b3ad6](https://github.com/Saghen/blink.cmp/commit/38b3ad6d4af9d392d3e5e0dabcb14e7d8e348314))

## [0.7.1](https://github.com/Saghen/blink.cmp/compare/v0.7.0...v0.7.1) (2024-12-02)

### Bug Fixes

* arguments on curl ([f992b72](https://github.com/Saghen/blink.cmp/commit/f992b72017cac77d4f4e22dc05016e5d79adff68))
* drop retry from curl ([6e9fb62](https://github.com/Saghen/blink.cmp/commit/6e9fb6254bb49eaf014a48049ff511bbfd6a66a3)), closes [#425](https://github.com/Saghen/blink.cmp/issues/425)

## [0.7.0](https://github.com/Saghen/blink.cmp/compare/v0.6.2...v0.7.0) (2024-12-02)

> [!IMPORTANT]
> Most of the configuration has been reworked, please see the README for the new schema

* Includes an enormous refactor in preparation for sources v2, commandline completions, and the v1 release [#389](https://github.com/Saghen/blink.cmp/issues/389)
* Enable experimental Treesitter highlighting on the labels via `completion.menu.draw.treesitter = true`

### BREAKING CHANGES

* nuke the debt ([#389](https://github.com/Saghen/blink.cmp/issues/389)) ([1187172](https://github.com/Saghen/blink.cmp/commit/11871727278381febd05d1ee1a17f98fb2e32b26)), closes [#323](https://github.com/Saghen/blink.cmp/issues/323)

### Features

* add show_on_keyword and show_on_trigger_character trigger options ([69a69dd](https://github.com/Saghen/blink.cmp/commit/69a69dd7c66f2290dea849846402266b2303782c)), closes [#402](https://github.com/Saghen/blink.cmp/issues/402)
* allow completing buffer words with unicode ([#392](https://github.com/Saghen/blink.cmp/issues/392)) ([e1d3e9d](https://github.com/Saghen/blink.cmp/commit/e1d3e9d4a64466b521940b3ccb67c6fd534b0032))
* call execute after accepting, but before applying semantic brackets ([073449a](https://github.com/Saghen/blink.cmp/commit/073449a872d49d0c61cb1cf020232d609b2b3d8c))
* default to empty table for setup ([#412](https://github.com/Saghen/blink.cmp/issues/412)) ([4559ec5](https://github.com/Saghen/blink.cmp/commit/4559ec5cfb91ed8080e2f8df7d4784e12aa27f18))
* error on download failure ([6054da2](https://github.com/Saghen/blink.cmp/commit/6054da23af87117afd1de59bb77df90037e84675))
* nuke the debt ([#389](https://github.com/Saghen/blink.cmp/issues/389)) ([1187172](https://github.com/Saghen/blink.cmp/commit/11871727278381febd05d1ee1a17f98fb2e32b26)), closes [#323](https://github.com/Saghen/blink.cmp/issues/323)
* prebuilt binary retry, disable progress, and docs ([bc67391](https://github.com/Saghen/blink.cmp/commit/bc67391de57ce3e42302b13cccf9dd41207c0860)), closes [#68](https://github.com/Saghen/blink.cmp/issues/68)
* **render:** support `source_id` and `source_name` in menu render ([#400](https://github.com/Saghen/blink.cmp/issues/400)) ([d5f62f9](https://github.com/Saghen/blink.cmp/commit/d5f62f981cde0660944626aaeaab8541c9516346))
* support accepting and drawing by index ([4b1a793](https://github.com/Saghen/blink.cmp/commit/4b1a79305d9acb22171062053a6c942383fefa72)), closes [#382](https://github.com/Saghen/blink.cmp/issues/382)
* support get_bufnrs for the buffer source ([#411](https://github.com/Saghen/blink.cmp/issues/411)) ([4c65dbd](https://github.com/Saghen/blink.cmp/commit/4c65dbde1709bed2cb87483b0ce4eb522098bebc))
* treesitter highlighter ([#404](https://github.com/Saghen/blink.cmp/issues/404)) ([08a0777](https://github.com/Saghen/blink.cmp/commit/08a07776838e205c697a3d05bcf43104a2adacf5))
* use sort_text over label for sorting ([0386120](https://github.com/Saghen/blink.cmp/commit/0386120c3bbe32a6746b73a8e38ec954c58575c9)), closes [#365](https://github.com/Saghen/blink.cmp/issues/365)

### Bug Fixes

* accept grabbing wrong config ([3dcf98d](https://github.com/Saghen/blink.cmp/commit/3dcf98d8a5c1c720d5a3d789ac14a9741dbe70eb))
* allow border to be a table ([52f6387](https://github.com/Saghen/blink.cmp/commit/52f63878c0affef88023cd2a00a103644cb7ccfa)), closes [#398](https://github.com/Saghen/blink.cmp/issues/398)
* auto_insert scheduling and module reference ([1b3cd31](https://github.com/Saghen/blink.cmp/commit/1b3cd31e26066308f97075fee7744cd8694cd75e))
* autocmd called in fast event ([9428983](https://github.com/Saghen/blink.cmp/commit/94289832dc7c148862fdf9326e173df265abe8ad)), closes [#396](https://github.com/Saghen/blink.cmp/issues/396)
* buffer events suppression, auto_insert selection ([96ceb56](https://github.com/Saghen/blink.cmp/commit/96ceb56f7b6e0abeacb01aa2b04abef33121d38b)), closes [#415](https://github.com/Saghen/blink.cmp/issues/415)
* convert additional text edits to utf-8 ([49981f2](https://github.com/Saghen/blink.cmp/commit/49981f2bc8c04967cf868574913f092392a267fe)), closes [#397](https://github.com/Saghen/blink.cmp/issues/397)
* cycling list skipping one item ([07b2ee1](https://github.com/Saghen/blink.cmp/commit/07b2ee14eaae6908f0da44bfa918177d167b12de))
* deduplicate mode changes, dont hide on select mode ([04ff262](https://github.com/Saghen/blink.cmp/commit/04ff262f3590cd9b63dab03e2cecc759d4abdf69)), closes [#393](https://github.com/Saghen/blink.cmp/issues/393)
* default snippet active function not returning ([59add2d](https://github.com/Saghen/blink.cmp/commit/59add2d602d9a13003ed3430232b3689872ea9ac)), closes [#399](https://github.com/Saghen/blink.cmp/issues/399)
* don't set window properties when nil ([cb815af](https://github.com/Saghen/blink.cmp/commit/cb815afca7c32af7feeb3a90d5b450620d4bef2b)), closes [#407](https://github.com/Saghen/blink.cmp/issues/407)
* ensure failed curl doesn't update the version ([933052b](https://github.com/Saghen/blink.cmp/commit/933052b8e9b585c24c493fdc34a66519d4889c1b)), closes [#68](https://github.com/Saghen/blink.cmp/issues/68)
* ensure menu selection index is within bounds ([bb5407d](https://github.com/Saghen/blink.cmp/commit/bb5407d27e93dc71f8572571ab04b3fc02fc8259)), closes [#416](https://github.com/Saghen/blink.cmp/issues/416)
* filter text always being nil ([33f7d8d](https://github.com/Saghen/blink.cmp/commit/33f7d8df8119673b7eca3d7a04ed28b805cae296)), closes [#365](https://github.com/Saghen/blink.cmp/issues/365)
* incorrect context start_col 1 char after beginning of line ([e88da6a](https://github.com/Saghen/blink.cmp/commit/e88da6a123c857ec2da92ff488c3f82cfba718ef)), closes [#405](https://github.com/Saghen/blink.cmp/issues/405)
* invalid configuration and readme after refactor ([56f7cb6](https://github.com/Saghen/blink.cmp/commit/56f7cb679ef9e5c09351bfa67b081c68ad27349f)), closes [#394](https://github.com/Saghen/blink.cmp/issues/394)
* keyword range "full" when covering end of line ([160b687](https://github.com/Saghen/blink.cmp/commit/160b6875095977d49e16c4e33add4b0e6b0c8668)), closes [#268](https://github.com/Saghen/blink.cmp/issues/268)
* misc typing issues ([b94172c](https://github.com/Saghen/blink.cmp/commit/b94172c8b28f6030c0df3f846eec4a129a25c5bb))
* only affect initial show for show_on_keyword and show_on_trigger_character ([ea61b1d](https://github.com/Saghen/blink.cmp/commit/ea61b1dc9ed2c4a092ab1365657bc4220b1b5488)), closes [#402](https://github.com/Saghen/blink.cmp/issues/402)
* signature window highlight ns ([0b9a128](https://github.com/Saghen/blink.cmp/commit/0b9a1282eb4f9e44de66fd689d4e301bb987abf5))
* signature window setup ([cab7576](https://github.com/Saghen/blink.cmp/commit/cab7576350c12de902dc18a85d17f4733f1f9938))
* super-tab preset keymap name ([f569aeb](https://github.com/Saghen/blink.cmp/commit/f569aeb9e684a2b18514077501e98b0f9ef873bd))
* user autocmd called in fast event not being wrapped ([e9baeea](https://github.com/Saghen/blink.cmp/commit/e9baeeac1d05d8cbbbee560380853baeb8b316f3))

### Documentation

* add note about reworked config ([180be7b](https://github.com/Saghen/blink.cmp/commit/180be7ba574033baa30fa8af0db4f59db7353584))

## [0.6.2](https://github.com/Saghen/blink.cmp/compare/v0.6.1...v0.6.2) (2024-11-26)

### Features

* add `cancel` command for use with `auto_insert` ([c58b3a8](https://github.com/Saghen/blink.cmp/commit/c58b3a8ec2cd71b422fbd4b1607e924996dfdebb)), closes [#215](https://github.com/Saghen/blink.cmp/issues/215)
* remove rust from blocked auto brackets filetypes ([8500a62](https://github.com/Saghen/blink.cmp/commit/8500a62e6f07a823b373df91b00c997734b3c664)), closes [#359](https://github.com/Saghen/blink.cmp/issues/359)

### Bug Fixes

* mark all config properties as optional ([e328bde](https://github.com/Saghen/blink.cmp/commit/e328bdedc4d12d01ff5c68bee8ea6ae6f33f42f7)), closes [#370](https://github.com/Saghen/blink.cmp/issues/370)
* path source not handling hidden files correctly ([22c5c0d](https://github.com/Saghen/blink.cmp/commit/22c5c0d2c96d5ab86cd23f8df76f005505138a5d)), closes [#369](https://github.com/Saghen/blink.cmp/issues/369)
* use offset encoding of first client ([0a2abab](https://github.com/Saghen/blink.cmp/commit/0a2ababaa450f50afeb4653c3d40b34344aa80d6)), closes [#380](https://github.com/Saghen/blink.cmp/issues/380)

## [0.6.1](https://github.com/Saghen/blink.cmp/compare/v0.6.0...v0.6.1) (2024-11-24)

### Features

* add prebuilt binaries for android ([#362](https://github.com/Saghen/blink.cmp/issues/362)) ([11a50fe](https://github.com/Saghen/blink.cmp/commit/11a50fe006a4482ab5acb5bcd77efa4fb9f944f8))

## [0.6.0](https://github.com/Saghen/blink.cmp/compare/v0.5.1...v0.6.0) (2024-11-24)

### BREAKING CHANGES

* matched character highlighting, draw rework (#245)
* set default nerd_font_variant to mono

### Features

* add `execute` function for sources ([653b262](https://github.com/Saghen/blink.cmp/commit/653b2629e1dab0c6d0084d90f30a600d601812a1))
* add get_filetype option for snippet source ([#352](https://github.com/Saghen/blink.cmp/issues/352)) ([7c3ad2b](https://github.com/Saghen/blink.cmp/commit/7c3ad2b1fcd0250df69162ad71439cfe547f9608)), closes [#292](https://github.com/Saghen/blink.cmp/issues/292)
* add scrollbar to autocomplete menu ([#259](https://github.com/Saghen/blink.cmp/issues/259)) ([4c2a36c](https://github.com/Saghen/blink.cmp/commit/4c2a36ce8efb2f02d12600b43b3de32898d07433))
* add snippet indicator back to label on render ([6f5ae79](https://github.com/Saghen/blink.cmp/commit/6f5ae79218334e5d1ca783e22847bbc6b4daef16))
* allow disabling keymap by passing an empty table ([e384594](https://github.com/Saghen/blink.cmp/commit/e384594deee2f7be225cb89dbcb72d9b6482fde8))
* avoid taking up space when scrollbar is hidden ([77f037c](https://github.com/Saghen/blink.cmp/commit/77f037cae07358368f3b7548ba39cffceb49349e))
* extract word from completion item for auto-insert preview ([#341](https://github.com/Saghen/blink.cmp/issues/341)) ([285f6f4](https://github.com/Saghen/blink.cmp/commit/285f6f498c8ba3ac0788edb1db2f8d2d3cb20fad))
* matched character highlighting, draw rework ([#245](https://github.com/Saghen/blink.cmp/issues/245)) ([683c47a](https://github.com/Saghen/blink.cmp/commit/683c47ac8c6e538122dc0fe50187b78f8995a549))
* option to disable treesitter highlighting ([1c14f8e](https://github.com/Saghen/blink.cmp/commit/1c14f8e8817015634c593eb3832a73e4993c561e))
* position documentation based on desired size, not max size ([973f06a](https://github.com/Saghen/blink.cmp/commit/973f06a164835b74247f46b3c5b2ae895a1acb1b))
* set default nerd_font_variant to mono ([d3e1c92](https://github.com/Saghen/blink.cmp/commit/d3e1c92e68b74f3d05f6ab7dfff2af8f83769149))
* support editRange, use textEditText when editRange is defined ([db3d1ad](https://github.com/Saghen/blink.cmp/commit/db3d1ad8d6420ce29d548991468cc0107fe9d04b)), closes [#310](https://github.com/Saghen/blink.cmp/issues/310)
* temporarily disable markdown combining ([24b4d35](https://github.com/Saghen/blink.cmp/commit/24b4d350b469595ff39ce48a45ee12b59578aae6))
* use filter_text when available ([12b4f11](https://github.com/Saghen/blink.cmp/commit/12b4f116648d87551a07def740a0375446105bbc))
* validate provider names in enabled_providers ([e9c9b41](https://github.com/Saghen/blink.cmp/commit/e9c9b41ea0f8ae36b7c19c970bf313f1ca93bd1b))

### Bug Fixes

* add ctx.icon_gap in kind_icon component ([ccf02f5](https://github.com/Saghen/blink.cmp/commit/ccf02f5e39e3ed7b4e65dbe667a3329313540eba))
* applying preview text_edit ([#296](https://github.com/Saghen/blink.cmp/issues/296)) ([8372a6b](https://github.com/Saghen/blink.cmp/commit/8372a6bfce9499f3bb8a91a23db8fe1d83f2d625))
* check if source is in `enabled_providers` before calling source:enabled ([#266](https://github.com/Saghen/blink.cmp/issues/266)) ([338d2a6](https://github.com/Saghen/blink.cmp/commit/338d2a6e81b9e0f9e66b691c36c9959a2705085a))
* clear last_char on trigger hide ([1ce30c9](https://github.com/Saghen/blink.cmp/commit/1ce30c9d1aa539f05e99b9ecea0dcc35d4cc33fe)), closes [#228](https://github.com/Saghen/blink.cmp/issues/228)
* completion label details containing newline characters ([#265](https://github.com/Saghen/blink.cmp/issues/265)) ([1628800](https://github.com/Saghen/blink.cmp/commit/1628800e1747ecc767368cab45916177c723da82))
* consider the border when calculating the position of the autocom… ([#325](https://github.com/Saghen/blink.cmp/issues/325)) ([41178d3](https://github.com/Saghen/blink.cmp/commit/41178d39670ce8db5e93a0028a7f23729559a326))
* consider the border when calculating the width of the documentat… ([#326](https://github.com/Saghen/blink.cmp/issues/326)) ([130eb51](https://github.com/Saghen/blink.cmp/commit/130eb512e2849c021d73bd269b77cc3b0ecf8b74))
* convert to utf-8 encoding on text edits ([2e37993](https://github.com/Saghen/blink.cmp/commit/2e379931090f3737b844598a18382241197aaa2a)), closes [#188](https://github.com/Saghen/blink.cmp/issues/188) [#200](https://github.com/Saghen/blink.cmp/issues/200)
* default highlight groups ([#317](https://github.com/Saghen/blink.cmp/issues/317)) ([69a987b](https://github.com/Saghen/blink.cmp/commit/69a987b96cf754a12b6d7dafce1d2d49ade591f2))
* default to item when assigning defaults, only use known defaults ([fb9f374](https://github.com/Saghen/blink.cmp/commit/fb9f3744cbc4c8b0c6792ed1c072009864a1bd6d)), closes [#151](https://github.com/Saghen/blink.cmp/issues/151)
* documentation misplacement due to screenpos returning 0,0 ([cb0baa4](https://github.com/Saghen/blink.cmp/commit/cb0baa4403fe5cf6d5dc3af483176780e44ba071))
* download mechanism works with GIT_DIR and GIT_WORK_TREE set ([#275](https://github.com/Saghen/blink.cmp/issues/275)) ([8c9930c](https://github.com/Saghen/blink.cmp/commit/8c9930c94e17ca0ab9956986b175cd91f4ac3a59))
* drop unnecessary filetype configuration ([bec27d9](https://github.com/Saghen/blink.cmp/commit/bec27d9196fe3c0020b56e49533a8f08cc8ea45f)), closes [#295](https://github.com/Saghen/blink.cmp/issues/295)
* drop vim print ([c3447cc](https://github.com/Saghen/blink.cmp/commit/c3447cc2bd4afec7050230b49a3e889c43084400))
* get the cursor position relative to the window instead of the sc… ([#327](https://github.com/Saghen/blink.cmp/issues/327)) ([5479abf](https://github.com/Saghen/blink.cmp/commit/5479abfbfb47bf4d23220a6e5a3eb11f23e57214))
* **ghost-text:** flickering using autocmds ([#255](https://github.com/Saghen/blink.cmp/issues/255)) ([a94bbaf](https://github.com/Saghen/blink.cmp/commit/a94bbaf9f2c6329f4593233f069b3dea21b4cedc))
* handle gap for empty text ([#301](https://github.com/Saghen/blink.cmp/issues/301)) ([371ad28](https://github.com/Saghen/blink.cmp/commit/371ad288544423531121c1abf0d519dda791e9f1))
* handle not being in a git repository, fix error on flakes ([#281](https://github.com/Saghen/blink.cmp/issues/281)) ([d2a216d](https://github.com/Saghen/blink.cmp/commit/d2a216de72a6b3a741c214b66e70897ff6f16dc2))
* ignore empty doc lines and detail lines ([aeaa2e7](https://github.com/Saghen/blink.cmp/commit/aeaa2e78dad7885e99b5a00a70b9c57c5a5302aa)), closes [#247](https://github.com/Saghen/blink.cmp/issues/247)
* join newlines in `label_description` ([#333](https://github.com/Saghen/blink.cmp/issues/333)) ([8ba2069](https://github.com/Saghen/blink.cmp/commit/8ba2069a57cf6580dea6a50bf71e5b3b2924b284))
* make ghost-text extmark with pcall ([#287](https://github.com/Saghen/blink.cmp/issues/287)) ([a2f6cfb](https://github.com/Saghen/blink.cmp/commit/a2f6cfb2902e1410f5cdbf386b9af337754f1a07))
* offset encoding conversion on nvim 0.11.0 ([#308](https://github.com/Saghen/blink.cmp/issues/308)) ([9822c6b](https://github.com/Saghen/blink.cmp/commit/9822c6b40ad91a14e2c75696db30999ae5cf1fc5)), closes [#307](https://github.com/Saghen/blink.cmp/issues/307)
* offset encoding for text edits ([c2a56e4](https://github.com/Saghen/blink.cmp/commit/c2a56e473ff5952211f7c890de0b831e8df3976d))
* only undo if not snippet ([f4dcebf](https://github.com/Saghen/blink.cmp/commit/f4dcebfd720810b14eb2ad62102028c104bf2205)), closes [#244](https://github.com/Saghen/blink.cmp/issues/244)
* override typing and module ([f1647f7](https://github.com/Saghen/blink.cmp/commit/f1647f7fd97ac7129e1cb8a1ed242ae326f25d6e))
* padded window ([#315](https://github.com/Saghen/blink.cmp/issues/315)) ([7a37c64](https://github.com/Saghen/blink.cmp/commit/7a37c643412f19b04a03ed4c71e94da175efcfb8))
* prevent index out of bounds in get_code_block_range ([#271](https://github.com/Saghen/blink.cmp/issues/271)) ([e6c735b](https://github.com/Saghen/blink.cmp/commit/e6c735be455c90df4aa7c11cfe7542f111234de6))
* remove offset from label detail highlight ([5262586](https://github.com/Saghen/blink.cmp/commit/52625866f5b9a9358313308276dcf110cf1a42ea))
* reset documentation scroll on new item ([cd3aa32](https://github.com/Saghen/blink.cmp/commit/cd3aa32276308d0c1bddf7a14cd13a8776eb5575)), closes [#239](https://github.com/Saghen/blink.cmp/issues/239)
* scrollbar gutter not updating on window resize ([c8cf209](https://github.com/Saghen/blink.cmp/commit/c8cf209dc843c5a42945bb95a4b8598bcab8c6f8))
* **scrollbar:** use cursorline to determine thumb position ([#267](https://github.com/Saghen/blink.cmp/issues/267)) ([28fcf95](https://github.com/Saghen/blink.cmp/commit/28fcf952d14a022cd64f89ff32b3442c6101b873))
* signature help now highlights the right parameter ([#297](https://github.com/Saghen/blink.cmp/issues/297)) ([3fe4c75](https://github.com/Saghen/blink.cmp/commit/3fe4c75c69f208462c4e8957005f6ccb72b1da25))
* **snippets:** fix nullpointer exception ([#355](https://github.com/Saghen/blink.cmp/issues/355)) ([3ac471b](https://github.com/Saghen/blink.cmp/commit/3ac471bbfe614adb77fc8179dd4adaa0d1576542))
* tailwind colors ([#306](https://github.com/Saghen/blink.cmp/issues/306)) ([8e3af0e](https://github.com/Saghen/blink.cmp/commit/8e3af0ec0079b599fb57f97653b2f20f98e2a5bb))
* **types:** allow resolving empty response from blink.cmd.Source ([#254](https://github.com/Saghen/blink.cmp/issues/254)) ([46a5f0b](https://github.com/Saghen/blink.cmp/commit/46a5f0b9fd8e6753d118853d384ae85bfdb70c30))
* use pmenu scrollbar highlights ([5632376](https://github.com/Saghen/blink.cmp/commit/5632376d4f51d777013d5f48414a15f02be854af))

## [0.5.1](https://github.com/Saghen/blink.cmp/compare/v0.5.0...v0.5.1) (2024-11-03)

### BREAKING CHANGES

* set max_width to 80 for documentation

### Features

* 'enter' keymap ([4ec5cea](https://github.com/Saghen/blink.cmp/commit/4ec5cea4858eee31919cc2a5bc1850846073c5ec))
* add label details to all draw functions ([f9c58ab](https://github.com/Saghen/blink.cmp/commit/f9c58ab26a427883965394959276fd347574b11e)), closes [#97](https://github.com/Saghen/blink.cmp/issues/97)
* add winblend option for windows ([#237](https://github.com/Saghen/blink.cmp/issues/237)) ([ca94ee0](https://github.com/Saghen/blink.cmp/commit/ca94ee0b1ec848bac6426811f12f6da39e48d02a))
* align completion window ([#235](https://github.com/Saghen/blink.cmp/issues/235)) ([0c13fbd](https://github.com/Saghen/blink.cmp/commit/0c13fbd3d7bed1d4bab08d3831c95ee3dfb7277f)), closes [#221](https://github.com/Saghen/blink.cmp/issues/221)
* allow merging of keymap preset with custom keymap ([#233](https://github.com/Saghen/blink.cmp/issues/233)) ([6b46164](https://github.com/Saghen/blink.cmp/commit/6b46164eac2feb6dd49e6e8c434cb276f50c8132))
* better extraction of detail from doc ([b0815e4](https://github.com/Saghen/blink.cmp/commit/b0815e461623d9a9ea06fb632167ca25656abcf5))
* only offset window when using preset draw ([75cadbc](https://github.com/Saghen/blink.cmp/commit/75cadbcd2657ed01326ca2b0e5e4d78a77127ca3))
* rework window positioning ([a67adaf](https://github.com/Saghen/blink.cmp/commit/a67adaf623f9c6e1803a693044608b73e02e8da3)), closes [#45](https://github.com/Saghen/blink.cmp/issues/45) [#194](https://github.com/Saghen/blink.cmp/issues/194)
* set max_width to 80 for documentation ([dc1de2b](https://github.com/Saghen/blink.cmp/commit/dc1de2bf962c67e8ba8647710817bbce04f92bdb))
* TailwindCSS highlight support ([#143](https://github.com/Saghen/blink.cmp/issues/143)) ([b2bbef5](https://github.com/Saghen/blink.cmp/commit/b2bbef52f24799f0e79a3adf6038366b26e2451b))

### Bug Fixes

* add "enter" keymap to types ([3ca68ef](https://github.com/Saghen/blink.cmp/commit/3ca68ef008e383a28c760de2d5ee65b35efbb5c5))
* allow to be lazy loaded on InsertEnter ([#243](https://github.com/Saghen/blink.cmp/issues/243)) ([9d50661](https://github.com/Saghen/blink.cmp/commit/9d5066134b339c5e4aa6cec3daa086d3b0671892))
* alpine linux detection ([a078c87](https://github.com/Saghen/blink.cmp/commit/a078c877ac17a912a51aba9d9e0068a0f1ed509b))
* check LSP methods before requesting ([193423c](https://github.com/Saghen/blink.cmp/commit/193423ca584e4e1a9639d6c480a6b952db566c21)), closes [#220](https://github.com/Saghen/blink.cmp/issues/220)
* documentation width ([9bdd828](https://github.com/Saghen/blink.cmp/commit/9bdd828e474e69badb64a305179930cf66acf649))
* **documentation:** better docs ([#234](https://github.com/Saghen/blink.cmp/issues/234)) ([a253b35](https://github.com/Saghen/blink.cmp/commit/a253b356092b8f64ac66200c249afe5978c3fc39))
* enable show_in_snippet by default ([76d11a6](https://github.com/Saghen/blink.cmp/commit/76d11a617075dc53e89e1c9b9ce5c62435abdfba))
* ensure treesitter does not run on windows ([2ac2f43](https://github.com/Saghen/blink.cmp/commit/2ac2f43513cdf63313192271427cc55608f0bedb)), closes [#193](https://github.com/Saghen/blink.cmp/issues/193)
* lazily call fuzzy access ([aeb6195](https://github.com/Saghen/blink.cmp/commit/aeb6195ba870c61e4e0f2d4e8ef1bcc80464af9b))
* make all of source provider config optional ([055b943](https://github.com/Saghen/blink.cmp/commit/055b9435358f68ae26de75d9294749bd69c22ccc))
* only check enabled fallback sources ([#232](https://github.com/Saghen/blink.cmp/issues/232)) ([ecb3520](https://github.com/Saghen/blink.cmp/commit/ecb3520c899eee9dbe738620f3c327b8089fe1f8))
* window direction and autocomplete closing on position update ([4b3fd8f](https://github.com/Saghen/blink.cmp/commit/4b3fd8f5ce6ece4f84d6c6ddfd0a42f43b889574)), closes [#240](https://github.com/Saghen/blink.cmp/issues/240)

## [0.5.0](https://github.com/Saghen/blink.cmp/compare/v0.4.1...v0.5.0) (2024-10-30)

> [!IMPORTANT]  
> The **keymap** configuration has been reworked, please see the README for the new schema

You may now use `nvim-cmp` sources within `blink.cmp` using @stefanboca's compatibility layer: https://github.com/Saghen/blink.compat

### BREAKING CHANGES

* rework keymap config

### Features

* `enabled` function for sources ([c104663](https://github.com/Saghen/blink.cmp/commit/c104663e92c15dd59ee3b299249361cd095206f4)), closes [#208](https://github.com/Saghen/blink.cmp/issues/208)
* accept error handling, expose autocomplete.select ([9cd1236](https://github.com/Saghen/blink.cmp/commit/9cd123657fce6e563a7d24b438f61b012ca1559f))
* cache resolve tasks ([83a8303](https://github.com/Saghen/blink.cmp/commit/83a8303e2744d01249f465f219f0dc5a41104a9e))
* glibc 2.17 and musl prebuilt binaries ([c593835](https://github.com/Saghen/blink.cmp/commit/c593835fe1b0297dfbcabe46edcd1edb9d317b94)), closes [#160](https://github.com/Saghen/blink.cmp/issues/160)
* ignore _*.lua files ([f6eccaf](https://github.com/Saghen/blink.cmp/commit/f6eccaf3f2ef8939ea661ee8384e299a9428999c))
* lsp capabilities ([e0e08cb](https://github.com/Saghen/blink.cmp/commit/e0e08cbfea667ff21b9e6e5acb0389ddd6d2de41))
* output preview with ghost text, including for snippets ([#186](https://github.com/Saghen/blink.cmp/issues/186)) ([6d25187](https://github.com/Saghen/blink.cmp/commit/6d2518745db83da0b15f60e22c15c205fb1ed56f))
* **perf:** call score_offset func once per source ([bd90e00](https://github.com/Saghen/blink.cmp/commit/bd90e007f33c60a3a11bb99ff2e8bfd897fe27b3))
* prefetch resolve on select ([52ec2c9](https://github.com/Saghen/blink.cmp/commit/52ec2c985cb0ef9459b73bb8b08801f35f092f6d))
* resolve item before accept ([3927128](https://github.com/Saghen/blink.cmp/commit/3927128e712806c22c20487ef0a1ed885bfec292))
* rework keymap config ([3fd92f0](https://github.com/Saghen/blink.cmp/commit/3fd92f0bbceb31a3cd32b1d7a9d2a62071c85d91))
* show completion window after accept if on trigger character ([28e0b5a](https://github.com/Saghen/blink.cmp/commit/28e0b5a873c6f4e687260384595a05c55a888ccf)), closes [#198](https://github.com/Saghen/blink.cmp/issues/198)
* support disabling accept on trigger character, block parenthesis ([125d4f1](https://github.com/Saghen/blink.cmp/commit/125d4f1288b3b309d219848559adfca3cc61f8b5)), closes [#212](https://github.com/Saghen/blink.cmp/issues/212)
* switch default keymap to select_and_accept ([f0f2672](https://github.com/Saghen/blink.cmp/commit/f0f26728c3e5c65cf2d27a1b24e4e3fbd26773fb))
* use treesitter for signature help hl ([0271d79](https://github.com/Saghen/blink.cmp/commit/0271d7957324df68bd352fc7aef60606c96c88ca))

### Bug Fixes

* add back cursor move after accept, but use current line ([ceeeb53](https://github.com/Saghen/blink.cmp/commit/ceeeb538b091c43aa6fb6fd6020531a37cef2191))
* always return item in resolve ([6f0fc86](https://github.com/Saghen/blink.cmp/commit/6f0fc86f8fbb94ae23770c01dc2e3cf9e1886e99)), closes [#211](https://github.com/Saghen/blink.cmp/issues/211)
* documentation auto show no longer working ([#202](https://github.com/Saghen/blink.cmp/issues/202)) ([6290abd](https://github.com/Saghen/blink.cmp/commit/6290abd24b14723ba4827c28367a805bcc4773de))
* dont move cursor after accepting ([cab91c5](https://github.com/Saghen/blink.cmp/commit/cab91c5f56eb15394d4cabddcd62eee6963129ec))
* fallback show_documentation when window open ([bc311b7](https://github.com/Saghen/blink.cmp/commit/bc311b756ca89652bfb18b07a99ff52f424d63a2))
* handle failed lsp resolve request gracefully ([4c40bf2](https://github.com/Saghen/blink.cmp/commit/4c40bf25f2371d6b3df6f130e154ebac0b9c3422))
* ignore nil item for resolve prefetching ([b7d1233](https://github.com/Saghen/blink.cmp/commit/b7d1233d826a0406538955b4ef2448dc0e72c536)), closes [#209](https://github.com/Saghen/blink.cmp/issues/209)
* invalid insertTextMode capabilities ([4de7b7e](https://github.com/Saghen/blink.cmp/commit/4de7b7e64100cfdbfc564c475a1713ba2498ba25))
* prevent treesitter from running on windows ([9b9be31](https://github.com/Saghen/blink.cmp/commit/9b9be318773dcce04f5017574fbe5ed638429852))
* schedule non-expr fallback keymaps ([#196](https://github.com/Saghen/blink.cmp/issues/196)) ([1a55fd1](https://github.com/Saghen/blink.cmp/commit/1a55fd1e03193e10cb8bc866cc2bc47c9473061c))
* sending erroneous fields to LSP on resolve ([e82c1b7](https://github.com/Saghen/blink.cmp/commit/e82c1b73607c4905582028e81bc40b10ce9eb8ea))
* set default keymap to use accept ([7d265b4](https://github.com/Saghen/blink.cmp/commit/7d265b4a19f2c198eda06baf031cb0e41cc3095c))
* snippet reload function ([407f2d5](https://github.com/Saghen/blink.cmp/commit/407f2d526fd07b651a8a7330df2c4fd05b32a014))
* snippet resolve ([5d9fa1c](https://github.com/Saghen/blink.cmp/commit/5d9fa1c36cc9e43a9d7cd65ddcc417128a9d41c3))

## [0.4.1](https://github.com/Saghen/blink.cmp/compare/v0.4.0...v0.4.1) (2024-10-24)

### Bug Fixes

* check semantic token type ([0b493ff](https://github.com/Saghen/blink.cmp/commit/0b493ff3ce7fd8d318e7e1024fbadfe2ec3a624a))
* exclude prefix including one char ([70438ac](https://github.com/Saghen/blink.cmp/commit/70438ac5016d3ab609f422d1ef084870cb9ceb29))

## [0.4.0](https://github.com/Saghen/blink.cmp/compare/v0.3.1...v0.4.0) (2024-10-24)

> [!IMPORTANT]  
> The sources configuration has been reworked, please see the README for the new schema

### BREAKING CHANGES

* rework sources config structure and available options
* rework sources system and configuration

### Features

* add extra space to ... on normal nerd font ([9b9647b](https://github.com/Saghen/blink.cmp/commit/9b9647bc23f52270ce43e579dda9b9eb5d00b7b8))
* add nix build-plugin command, update devShell to not require ([32069be](https://github.com/Saghen/blink.cmp/commit/32069be108dda4cf2b0a7316a0be366398187003))
* auto_show on autocomplete window ([#98](https://github.com/Saghen/blink.cmp/issues/98)) ([82e03b1](https://github.com/Saghen/blink.cmp/commit/82e03b1207b14845d8f29041e2f244693708425b))
* **config:** add ignored filetypes option ([#108](https://github.com/Saghen/blink.cmp/issues/108)) ([b56a2b1](https://github.com/Saghen/blink.cmp/commit/b56a2b18804a9e4cce6450b886c33fb6b0a58e39))
* custom documentation highlighting ([90d6394](https://github.com/Saghen/blink.cmp/commit/90d63948368982800ce886e93fc9c7d1c36cf74c)), closes [#113](https://github.com/Saghen/blink.cmp/issues/113)
* default to not showing in snippet ([49b033a](https://github.com/Saghen/blink.cmp/commit/49b033a11830652790603fe9b2a7e6275e626730)), closes [#131](https://github.com/Saghen/blink.cmp/issues/131)
* expose reload function for sources ([ff1f5fa](https://github.com/Saghen/blink.cmp/commit/ff1f5fa525312676f1aaba9b601bd0e13c52644b)), closes [#28](https://github.com/Saghen/blink.cmp/issues/28)
* expose typo resistance, update frizbee ([63b7b22](https://github.com/Saghen/blink.cmp/commit/63b7b2219f4595973225a13e6e664fc836ee305c))
* **fuzzy:** lazy get lua properties ([5cc63f0](https://github.com/Saghen/blink.cmp/commit/5cc63f0f298ad31cab37d7b2a478e61a3601a768))
* ignore empty fallback_for table ([9c9e0cc](https://github.com/Saghen/blink.cmp/commit/9c9e0cc78b0933c66916eaccc6a974608d2426de)), closes [#122](https://github.com/Saghen/blink.cmp/issues/122)
* ignore some characters at prefix of keyword ([569156f](https://github.com/Saghen/blink.cmp/commit/569156f432e67a4bd4dccee4fb9beafbf15a1d30)), closes [#135](https://github.com/Saghen/blink.cmp/issues/135)
* mark buffer completion items as plain text ([0f5f484](https://github.com/Saghen/blink.cmp/commit/0f5f484583b19484599b9dfb524180902d10e5b3)), closes [#148](https://github.com/Saghen/blink.cmp/issues/148)
* more robust preview for auto_insert mode ([6e15864](https://github.com/Saghen/blink.cmp/commit/6e158647bbc0628fe46c0175acf32d954c0c172f)), closes [#117](https://github.com/Saghen/blink.cmp/issues/117)
* notify user on json parsing error for snippets ([c5146a5](https://github.com/Saghen/blink.cmp/commit/c5146a5c23db48824fc7720f1265f3e75fc1c634)), closes [#132](https://github.com/Saghen/blink.cmp/issues/132)
* place cursor at first tab stop on snippet preview ([d3e8701](https://github.com/Saghen/blink.cmp/commit/d3e87015e891022a8fe36f43c60806c21f231cea))
* re-enable typo resistance by default ([b35a559](https://github.com/Saghen/blink.cmp/commit/b35a559abea64a1b77abf69e8252ab5cd063868a))
* reduce build-plugin command to minimal dependencies, add command to docs ([cfaf9fc](https://github.com/Saghen/blink.cmp/commit/cfaf9fc89a4b0ad36bba7a2605ae9b2f15efbf52))
* remove snippet deduplication ([e296d8f](https://github.com/Saghen/blink.cmp/commit/e296d8ffcea78c400210d09c669359af89802618)), closes [#146](https://github.com/Saghen/blink.cmp/issues/146)
* rework sources config structure and available options ([e3a811b](https://github.com/Saghen/blink.cmp/commit/e3a811bc9bc9cf55de8bd7a7bcee84236e015dc2)), closes [#144](https://github.com/Saghen/blink.cmp/issues/144)
* rework sources system and configuration ([7fea65c](https://github.com/Saghen/blink.cmp/commit/7fea65c4e4c83d3b194a4d9e4d813204fd9f0ded)), closes [#144](https://github.com/Saghen/blink.cmp/issues/144)
* select_and_accept keymap ([6394508](https://github.com/Saghen/blink.cmp/commit/6394508b0c3f1f1f95e02c8057ccfc4b746dbd75)), closes [#118](https://github.com/Saghen/blink.cmp/issues/118)
* support detail only in doc window ([#147](https://github.com/Saghen/blink.cmp/issues/147)) ([57abdb8](https://github.com/Saghen/blink.cmp/commit/57abdb838cfcc624a87dba2b10f665c30e604b4e))
* support LSP item defaults ([ffc4282](https://github.com/Saghen/blink.cmp/commit/ffc428208f292fa00cb7cced09d35de6e815ab55))
* support LSPs with only full semantic tokens and cleanup ([0626cb5](https://github.com/Saghen/blink.cmp/commit/0626cb5446fd8d4ccfae53a93b648534ea1c7bf3))
* support using suffix for fuzzy matching ([815f4df](https://github.com/Saghen/blink.cmp/commit/815f4dffa58d89d95c6f6e12133b0c1103fa0bdd)), closes [#88](https://github.com/Saghen/blink.cmp/issues/88)
* switch to mlua ([#105](https://github.com/Saghen/blink.cmp/issues/105)) ([873680d](https://github.com/Saghen/blink.cmp/commit/873680d16459d6747609804b08612f6a11f04591))
* use textEditText as fallback for textEdit ([abcb2a0](https://github.com/Saghen/blink.cmp/commit/abcb2a0dab207e03d382acf62074f639a3572e20))
* **windows:** add support for individual border character highlights ([#175](https://github.com/Saghen/blink.cmp/issues/175)) ([3c1a502](https://github.com/Saghen/blink.cmp/commit/3c1a5020ab9a993e8bc8c5c05d29588747f00b78))

### Bug Fixes

* add back undo text edit for accept ([f62046a](https://github.com/Saghen/blink.cmp/commit/f62046a775605f597f2b370672d05ee0c9123142))
* add missing select_and_accept keymap to config ([d2140dc](https://github.com/Saghen/blink.cmp/commit/d2140dc7615991ea88fa1fd75dd4fccb53a73e25))
* always hide window on accept ([7f5a3d9](https://github.com/Saghen/blink.cmp/commit/7f5a3d9a820125e7da0a1816efaddb84d47a7f18))
* auto insert breaking on single line text edit ([78ac56e](https://github.com/Saghen/blink.cmp/commit/78ac56e96144ed7475bb6d11981d3c8154bfd366)), closes [#169](https://github.com/Saghen/blink.cmp/issues/169)
* check if item contains brackets before deferring to semantic token ([e5f543d](https://github.com/Saghen/blink.cmp/commit/e5f543da2a0ce91c8720b67f0ea6cfa941dc26d6))
* **config:** set correct type def for blink.cmp.WindowBorderChar ([516190b](https://github.com/Saghen/blink.cmp/commit/516190bcdafa387d417cfb235cbcd7385e902089))
* don't show completions when trigger context is nil ([5b39d83](https://github.com/Saghen/blink.cmp/commit/5b39d83ac4fed46c57d8db987ea56cb1c0e68b0e))
* drop prints ([89259f9](https://github.com/Saghen/blink.cmp/commit/89259f936e413e0a324b2ea369eb8ccefc05a14f)), closes [#179](https://github.com/Saghen/blink.cmp/issues/179)
* drop prints ([67fa41f](https://github.com/Saghen/blink.cmp/commit/67fa41f0f0501beb64d4acc8678f8788331a470e))
* frizbee not matching on capital letters ([722b41b](https://github.com/Saghen/blink.cmp/commit/722b41b0a7028581004888623f3f79c1d9eab8b8)), closes [#162](https://github.com/Saghen/blink.cmp/issues/162) [#173](https://github.com/Saghen/blink.cmp/issues/173)
* fuzzy get query returning extra characters ([b2380a0](https://github.com/Saghen/blink.cmp/commit/b2380a0301e4385e4964cd57e790d6ce169b2b71)), closes [#170](https://github.com/Saghen/blink.cmp/issues/170) [#172](https://github.com/Saghen/blink.cmp/issues/172) [#176](https://github.com/Saghen/blink.cmp/issues/176)
* fuzzy panic on too many items ([1e6dcbf](https://github.com/Saghen/blink.cmp/commit/1e6dcbffbe224fa10ef9fab490ad07dbd9dd19b0))
* handle treesitter get_parser failure ([fe68c28](https://github.com/Saghen/blink.cmp/commit/fe68c288268f01d1e3b7e692abac2e1fb2093d78)), closes [#171](https://github.com/Saghen/blink.cmp/issues/171)
* item defaults not being applied ([42f8efb](https://github.com/Saghen/blink.cmp/commit/42f8efb43bed968050fcb8feb5fad4b6b27a9b05)), closes [#158](https://github.com/Saghen/blink.cmp/issues/158)
* missing access function ([d11f271](https://github.com/Saghen/blink.cmp/commit/d11f271ddd980e05545627093924e8359c5416b3))
* only show autocomplete window on select if auto_show is disabled ([fa64556](https://github.com/Saghen/blink.cmp/commit/fa6455635b8f12504e2e892fd8ce8926e679cf68))
* re-enable memory check for now ([6b24f48](https://github.com/Saghen/blink.cmp/commit/6b24f484d56eeb9b48cb4ce6b58481cdfc50a3bd))
* remove debug prints ([9846c2d](https://github.com/Saghen/blink.cmp/commit/9846c2d2bfdeaa3088c9c0143030524402fffdf9))
* select always triggering when auto_show enabled ([db635f2](https://github.com/Saghen/blink.cmp/commit/db635f201f5ac5f48e7e33cc268f23e7646fd946))
* select_and_accept not working with auto_insert ([65eb336](https://github.com/Saghen/blink.cmp/commit/65eb336f6c33964becacfbfc850f18d6e3cd5581)), closes [#118](https://github.com/Saghen/blink.cmp/issues/118)
* signature window no longer overlaps cursor ([#149](https://github.com/Saghen/blink.cmp/issues/149)) ([7d6b50b](https://github.com/Saghen/blink.cmp/commit/7d6b50b140eadb51d1bf59b93a02293333a59519))
* single char non-matching keyword ([3cb084c](https://github.com/Saghen/blink.cmp/commit/3cb084cc4e3cc989895d0eabf0ccc690c15d19ed)), closes [#141](https://github.com/Saghen/blink.cmp/issues/141)
* skip treesitter hl on nil lang ([cb9397c](https://github.com/Saghen/blink.cmp/commit/cb9397c89104ab09d85ba5ce1b40852635f9b142))
* temporary workaround for insertReplaceEdit ([c218faf](https://github.com/Saghen/blink.cmp/commit/c218fafbf275725532f3cf2eaebdf863b958d48e)), closes [#178](https://github.com/Saghen/blink.cmp/issues/178)
* typo in signature.win ([#125](https://github.com/Saghen/blink.cmp/issues/125)) ([69ad25f](https://github.com/Saghen/blink.cmp/commit/69ad25f38e1eb833b7aa5a0efb2d6c485e191149))
* use treesitter.language.get_lang when choosing parser ([213fd94](https://github.com/Saghen/blink.cmp/commit/213fd94de2ab83ff409e1fd240625959bf61624e)), closes [#133](https://github.com/Saghen/blink.cmp/issues/133)
* window positioning with folds ([819b978](https://github.com/Saghen/blink.cmp/commit/819b978328b244fc124cfcd74661b2a7f4259f4f)), closes [#95](https://github.com/Saghen/blink.cmp/issues/95)

## [0.3.1](https://github.com/Saghen/blink.cmp/compare/v0.3.0...v0.3.1) (2024-10-14)

### Bug Fixes

* **ci:** use correct file ext for windows ([af68874](https://github.com/Saghen/blink.cmp/commit/af68874f1b2e628e0c72ec27f5225d0c6b2d6820))

## [0.3.0](https://github.com/Saghen/blink.cmp/compare/v0.2.1...v0.3.0) (2024-10-14)

### BREAKING CHANGES

* implement auto-insert option (#65)
* autocompletion window components alignment (#51)
* disable auto_show documentation by default, use <C-space> to toggle

### Features

* add back min_width to autocomplete ([9a008c9](https://github.com/Saghen/blink.cmp/commit/9a008c942f180a23671f598ed9680770b254a599))
* add basic event trigger API ([#31](https://github.com/Saghen/blink.cmp/issues/31)) ([127f518](https://github.com/Saghen/blink.cmp/commit/127f51827cc038aab402abc6bacf9862dd2d72ad))
* add detail to documentation window ([#33](https://github.com/Saghen/blink.cmp/issues/33)) ([588e4d4](https://github.com/Saghen/blink.cmp/commit/588e4d4a7e42bae0e26c82ebc1ea3c68fa4e7cf0))
* add health.lua and basic healthchecks ([#101](https://github.com/Saghen/blink.cmp/issues/101)) ([a12617d](https://github.com/Saghen/blink.cmp/commit/a12617d1eb69484d2656ccc40c40e8254b1ea3ec))
* add minimal render style ([#85](https://github.com/Saghen/blink.cmp/issues/85)) ([b4bbad1](https://github.com/Saghen/blink.cmp/commit/b4bbad181b0e1b9cdf1025b790cf720d707a8c26))
* added a preselect option to the cmp menu ([#24](https://github.com/Saghen/blink.cmp/issues/24)) ([1749e32](https://github.com/Saghen/blink.cmp/commit/1749e32c524dc1815fe4abbad0b33439316c4596))
* apply keymap on InsertEnter ([340370d](https://github.com/Saghen/blink.cmp/commit/340370d526996b99ff75c1858294f15502af0179)), closes [#37](https://github.com/Saghen/blink.cmp/issues/37)
* **ci:** support windows pre-built binaries ([#100](https://github.com/Saghen/blink.cmp/issues/100)) ([b378d50](https://github.com/Saghen/blink.cmp/commit/b378d5022743e56dc450ab1b6a75ab03de36f86b))
* disable auto_show documentation by default, use <C-space> to toggle ([84361bd](https://github.com/Saghen/blink.cmp/commit/84361bdbd9e9ab2a7c06b0f458c2829cef46348d))
* don't search forward when guessing text edit ([a7e1acc](https://github.com/Saghen/blink.cmp/commit/a7e1acc1ed9b0ad004af124bcb6c7d71a7eb5378)), closes [#58](https://github.com/Saghen/blink.cmp/issues/58)
* drop source groups in favor of fallback_for ([#83](https://github.com/Saghen/blink.cmp/issues/83)) ([1f0c0f3](https://github.com/Saghen/blink.cmp/commit/1f0c0f349488f5138757abec2d327ac6c143a4f0))
* expose source provider config to sources ([deba523](https://github.com/Saghen/blink.cmp/commit/deba523406f45eb0a227c33d57a8d75a79abb4cf))
* ignore repeated call at cursor position in trigger ([4883420](https://github.com/Saghen/blink.cmp/commit/48834207c143f5e84d7a71cd250b2049ec0a6d8c))
* implement auto-insert option ([#65](https://github.com/Saghen/blink.cmp/issues/65)) ([1df7d33](https://github.com/Saghen/blink.cmp/commit/1df7d33e930c042dc91287a02a97e1ccf8a92d5d))
* make fuzzy secondary min_score more lenient ([b330b61](https://github.com/Saghen/blink.cmp/commit/b330b61ffac753be3f1257eda92e1596c0ab3174))
* stylize markdown in documentation window ([05229dd](https://github.com/Saghen/blink.cmp/commit/05229ddc2fd1695c979e2807aa96842978dd4779))
* use faster shallow_copy for context ([98575f0](https://github.com/Saghen/blink.cmp/commit/98575f054db18bc763100b8d14a9eae0417209d5))

### Bug Fixes

* accept replacing first char in line ([655d2ee](https://github.com/Saghen/blink.cmp/commit/655d2ee2673950451a491294fd3ce7e17cfb0a24)), closes [#38](https://github.com/Saghen/blink.cmp/issues/38)
* add union to utils ([88f71b1](https://github.com/Saghen/blink.cmp/commit/88f71b16ecd650775516bd2b30ab808283b7242c))
* autocomplete positioning on first char in line ([7afb06c](https://github.com/Saghen/blink.cmp/commit/7afb06ca9962e3670b5ed01e7301709a53917edd))
* autocompletion window components alignment ([#51](https://github.com/Saghen/blink.cmp/issues/51)) ([a4f5f8e](https://github.com/Saghen/blink.cmp/commit/a4f5f8eef9182515050d94d54f4c2bb97767987b))
* binary symlink in flake only working on Linux ([#93](https://github.com/Saghen/blink.cmp/issues/93)) ([fc5feb8](https://github.com/Saghen/blink.cmp/commit/fc5feb887f3f379fff0756b2be2a35c8aa841a44))
* check if LSP supports resolve provider ([957a57a](https://github.com/Saghen/blink.cmp/commit/957a57a9d3d90c1a9974b9af66f4a9a1f80fdb5f)), closes [#48](https://github.com/Saghen/blink.cmp/issues/48)
* close completion if the accepted item matches the current word ([2f1b85b](https://github.com/Saghen/blink.cmp/commit/2f1b85bc4f15e2f3660550ef92161a93482f2fd8)), closes [#41](https://github.com/Saghen/blink.cmp/issues/41)
* close completion window on ctrl+c in insert mode ([#63](https://github.com/Saghen/blink.cmp/issues/63)) ([e695c79](https://github.com/Saghen/blink.cmp/commit/e695c798b2d53a429f2f3ba1551a21ae2c4dc11a))
* **config:** make blink lua config fields optional ([#18](https://github.com/Saghen/blink.cmp/issues/18)) ([9c73b0d](https://github.com/Saghen/blink.cmp/commit/9c73b0dc8c158c7162092258177ff8a03aa2919b))
* context not clearing on trigger character, path regexes ([15cb871](https://github.com/Saghen/blink.cmp/commit/15cb871d1f8c52050a0fcd07d31115f3a63cf20c)), closes [#16](https://github.com/Saghen/blink.cmp/issues/16)
* correctly handle non-blink keymaps with string rhs ([#78](https://github.com/Saghen/blink.cmp/issues/78)) ([1ad59aa](https://github.com/Saghen/blink.cmp/commit/1ad59aa6ab142c19508ee6ed222b73a3ffd13521))
* disable blink.cmp remaps when telescope prompt is open ([#104](https://github.com/Saghen/blink.cmp/issues/104)) ([7f2f74f](https://github.com/Saghen/blink.cmp/commit/7f2f74fe037ccad1a573e3d42f114d0d23b954d8)), closes [#102](https://github.com/Saghen/blink.cmp/issues/102)
* documentation manual trigger not updating on scroll ([cd15078](https://github.com/Saghen/blink.cmp/commit/cd15078763946522dddbb818803e99b2b321e742))
* documentation of snippet cannot be shown when description is list ([#92](https://github.com/Saghen/blink.cmp/issues/92)) ([f99bf6b](https://github.com/Saghen/blink.cmp/commit/f99bf6bdabadc2b47fd7355ae2af912a30b9c3cc))
* don't initialize first_fill with 1 ([#87](https://github.com/Saghen/blink.cmp/issues/87)) ([526f786](https://github.com/Saghen/blink.cmp/commit/526f786a8658f99dff36013b4e31d1f7e6b0a56b))
* double send on append on trigger character ([ebbce90](https://github.com/Saghen/blink.cmp/commit/ebbce90400ea1ed3e14fdec88fdef59c0185ad46)), closes [#25](https://github.com/Saghen/blink.cmp/issues/25)
* enable kind auto brackets for TS/JS ([808f628](https://github.com/Saghen/blink.cmp/commit/808f628713ae78665511be42b2c054c92208a00e))
* expand vars in snippets for insertText ([ce337cb](https://github.com/Saghen/blink.cmp/commit/ce337cb95f2172070c0e9333e3439eb20ae4c72a)), closes [#27](https://github.com/Saghen/blink.cmp/issues/27)
* **ffi:** handle cargo library naming conventions for windows binaries ([#74](https://github.com/Saghen/blink.cmp/issues/74)) ([e9493c6](https://github.com/Saghen/blink.cmp/commit/e9493c6aa4942da7e3a62c118195ea07df815dc2))
* guess text edit once and for all ([fc348da](https://github.com/Saghen/blink.cmp/commit/fc348dac16f190042d20aee62ea61b66c7c1380a))
* handle empty table in additionalTextEdits ([#99](https://github.com/Saghen/blink.cmp/issues/99)) ([65e9605](https://github.com/Saghen/blink.cmp/commit/65e9605924ff774fb3612441a1d18737b5c9f58a))
* handle newlines in autocomplete suggestions ([#110](https://github.com/Saghen/blink.cmp/issues/110)) ([c39227a](https://github.com/Saghen/blink.cmp/commit/c39227adfaf66939b6a319bb1ed43d9ade5bbd9b))
* passthrough bind on show/hide when shown/hidden ([a5145ae](https://github.com/Saghen/blink.cmp/commit/a5145ae69ef2d4193574a09fcd50bea20481f516)), closes [#49](https://github.com/Saghen/blink.cmp/issues/49)
* re-enable preselect by default ([64673ea](https://github.com/Saghen/blink.cmp/commit/64673ea454f46664ac6f6545f5d3577fd27421e9))
* replace keycodes on callback alternate mappings ([df5c0de](https://github.com/Saghen/blink.cmp/commit/df5c0de57b443545d4fe04cff9cd97ca3d20bbbf)), closes [#47](https://github.com/Saghen/blink.cmp/issues/47)
* respect autocomplete min_width ([#86](https://github.com/Saghen/blink.cmp/issues/86)) ([c15aefe](https://github.com/Saghen/blink.cmp/commit/c15aefeea77345b21ed79cb9defc322ae19f7eda))
* signature window failing when trigger context empty ([6a21d7c](https://github.com/Saghen/blink.cmp/commit/6a21d7c12d7186313e0dea2c04d0dd63b6534115))
* snippet keymaps not applying in insert ([a89ae20](https://github.com/Saghen/blink.cmp/commit/a89ae200840de7661eb92d8ae202b279ecc56da9)), closes [#70](https://github.com/Saghen/blink.cmp/issues/70)
* snippet source markdown generation ([a6cf72a](https://github.com/Saghen/blink.cmp/commit/a6cf72ae58362c126f91993326b5c8b43366eb7f))
* snippets source expanding vars ([5ffd608](https://github.com/Saghen/blink.cmp/commit/5ffd608dc4cd4df8fcfe43b366c5960f05056e45))
* strip blink fields from lsp items for resolve ([ab99b02](https://github.com/Saghen/blink.cmp/commit/ab99b02f4b5c378c7c79e5d24954d00450e78f1b))
* union_keys not using pairs ([8c2cb2e](https://github.com/Saghen/blink.cmp/commit/8c2cb2efb63411499f6746ae7be34e2b0a581bad))
* update ffi.lua ([27903be](https://github.com/Saghen/blink.cmp/commit/27903bef41bc745c4d5419e86ca5bf09ed538f2b))
* use correct prev/next keymap ([#53](https://github.com/Saghen/blink.cmp/issues/53)) ([f456c2a](https://github.com/Saghen/blink.cmp/commit/f456c2aa0994f709f9aec991ed2b4b705f787e48)), closes [/github.com/Saghen/blink.cmp/pull/23#issuecomment-2399876619](https://github.com/Saghen//github.com/Saghen/blink.cmp/pull/23/issues/issuecomment-2399876619)
* use empty separator for joining snippet description ([28f3a31](https://github.com/Saghen/blink.cmp/commit/28f3a316de01fc4a14c67689b0547428499e933d))
* use internal CompletionItemKind table ([4daf96d](https://github.com/Saghen/blink.cmp/commit/4daf96d76e06d6c248587f860ddb5717ced9bbd3)), closes [#17](https://github.com/Saghen/blink.cmp/issues/17)

## [0.2.1](https://github.com/Saghen/blink.cmp/compare/v0.2.0...v0.2.1) (2024-10-08)

### Features

* cycle completions ([#12](https://github.com/Saghen/blink.cmp/issues/12)) ([d20e34d](https://github.com/Saghen/blink.cmp/commit/d20e34d8c87925bd27dff12961588459f649cd92))

### Bug Fixes

* autocomplete window positioning with borders ([ba62bda](https://github.com/Saghen/blink.cmp/commit/ba62bda5af9b5f2a8accb102eb4791fab94e2a90)), closes [#29](https://github.com/Saghen/blink.cmp/issues/29)
* check server capabilities ([#5](https://github.com/Saghen/blink.cmp/issues/5)) ([8d2615d](https://github.com/Saghen/blink.cmp/commit/8d2615d00a9892647a6d0e0e564b781a4e6afabe))
* keymaps not replacing keycodes ([5dd7d66](https://github.com/Saghen/blink.cmp/commit/5dd7d667228e3a98d01146db7c4461f42644d0c1))
* keymaps replacing buffer local bindings ([506ea74](https://github.com/Saghen/blink.cmp/commit/506ea74e53a825cc6efd40a46c4129576409e440)), closes [#39](https://github.com/Saghen/blink.cmp/issues/39)
* use buffer-local keymaps ([ecb3510](https://github.com/Saghen/blink.cmp/commit/ecb3510ef2132956fb2df3dcc927e0f84d1a1c1d)), closes [#20](https://github.com/Saghen/blink.cmp/issues/20)
* use correct prev/next keymap for k and j ([#23](https://github.com/Saghen/blink.cmp/issues/23)) ([43e7532](https://github.com/Saghen/blink.cmp/commit/43e753228fe4a722e29d4953cad74a61728183cb))

## [0.2.0](https://github.com/Saghen/blink.cmp/compare/v0.1.0...v0.2.0) (2024-10-07)

### Features

* blink cmp specific winhighlights and highlights ([a034865](https://github.com/Saghen/blink.cmp/commit/a034865d585800503a61995a850ecb622a3d36cc))
* check for brackets in front of item ([2c6ee0d](https://github.com/Saghen/blink.cmp/commit/2c6ee0d5fa32e286255a4ca119ff74713676bf60))
* custom drawing support ([3e55028](https://github.com/Saghen/blink.cmp/commit/3e550286534e68cff42f96747e58db0610f7b4b5))
* customizable undo point ([876707f](https://github.com/Saghen/blink.cmp/commit/876707f214e7ca0875e05eae45b876396b6c33fb))
* introduce customizable winhighlight for autocomplete and documentation windows ([1a9cb7a](https://github.com/Saghen/blink.cmp/commit/1a9cb7ac70a912689ab09b96c6f9e75c888faed6))
* support keyword_length on sources ([77080a5](https://github.com/Saghen/blink.cmp/commit/77080a529f88064e0ff04ef69b08fbe7445bcd0d))

### Bug Fixes

* autocomplete window placement ([4e9d7ca](https://github.com/Saghen/blink.cmp/commit/4e9d7ca62c83c3ff2d64e925aab4dac10266f33b))
* frecency access scoring ([e736972](https://github.com/Saghen/blink.cmp/commit/e73697265ff9091c9cca3db060be60d8e3962c5e))
* misc ([5f4db7a](https://github.com/Saghen/blink.cmp/commit/5f4db7a1507dcca3b0f4d4fbeaef1f42262aea8f))
* path completions ([6a5cf05](https://github.com/Saghen/blink.cmp/commit/6a5cf05c704a42cfbfa3009d3ac8e727637567b8))
* respect min/max width for autocomplete window rendering ([0843884](https://github.com/Saghen/blink.cmp/commit/08438846b8016a9457c3234f4066655dc62b97a0))
* signature trigger config ([cf9e4aa](https://github.com/Saghen/blink.cmp/commit/cf9e4aaf778f56d2dda8f43c30cb68762aecc425))
* signature window showing up after context deleted ([857b336](https://github.com/Saghen/blink.cmp/commit/857b336ccdc5a389564e6e2b58571bc07c5cce32))
* window placement with border ([d6a81d3](https://github.com/Saghen/blink.cmp/commit/d6a81d320f8880e219a3f937ecea1f78aca680e3))

## [0.1.0](https://github.com/Saghen/blink.cmp/compare/1b282880e699be37c3719308d6660a68d9081b14...v0.1.0) (2024-10-05)

### Features

* .local/state db location and misc ([bf76a01](https://github.com/Saghen/blink.cmp/commit/bf76a01482f6a3f7e019d0050df73ccf8ad93cf6))
* accept and auto brackets config ([fd32689](https://github.com/Saghen/blink.cmp/commit/fd32689fbd07b953a54b61cc871f714c9dd004d5))
* add back to repo ([24422f2](https://github.com/Saghen/blink.cmp/commit/24422f2341acf6ebdf7c9bc798cd81fbf5029d03))
* add documentation keymaps ([e248579](https://github.com/Saghen/blink.cmp/commit/e248579b5cfe939048b613de7a7cdfcb884cd078))
* auto brackets support ([7203d51](https://github.com/Saghen/blink.cmp/commit/7203d5195970f300ee5529a8427060ee1db9ae41))
* basic snippet expansion and text edit support ([451dd9e](https://github.com/Saghen/blink.cmp/commit/451dd9eeaa37f6c5598bf7293b8da2bfdfe9162e))
* better documentation window positioning ([a7ee523](https://github.com/Saghen/blink.cmp/commit/a7ee523978ba653b6eb4d9bac2af1d70f6e89f7b))
* complete rework ([1efdc8a](https://github.com/Saghen/blink.cmp/commit/1efdc8a0ff38d3f1ff89acd9b04aa14844f50e42))
* consolidate context table ([ad9ba28](https://github.com/Saghen/blink.cmp/commit/ad9ba28d0a8c1fda91e24e33d29b8013dd4c760a))
* drop performance logging ([2974bc0](https://github.com/Saghen/blink.cmp/commit/2974bc0569b2d611ce399a733753c90f6ab61a9d))
* dynamic cmp and doc window width ([6b78c89](https://github.com/Saghen/blink.cmp/commit/6b78c89276f8a520b4b802c8893f30e0ee7a5c82))
* enable path source by default ([e7362c0](https://github.com/Saghen/blink.cmp/commit/e7362c0786ae889b738c9f1f34a312d834005d37))
* hack around LSPs returning filtered items ([b58a382](https://github.com/Saghen/blink.cmp/commit/b58a382640f2ddfe0b07ce70439e935e49e39e36))
* handle no items in source provider ([82106a4](https://github.com/Saghen/blink.cmp/commit/82106a482e899c27d3fa830aa7f65c020848fc68))
* immediate fuzzy on keystroke ([1d3d54f](https://github.com/Saghen/blink.cmp/commit/1d3d54f20f2412e33975db88a60c6f2c148e7903))
* implement snippets without deps ([37dbee4](https://github.com/Saghen/blink.cmp/commit/37dbee453dc2655a0a0e74d9b95ee00c08a8cf32))
* init flake ([87e0416](https://github.com/Saghen/blink.cmp/commit/87e041699169d4f837c5f430e26756f0c2f76623))
* initial ([1b28288](https://github.com/Saghen/blink.cmp/commit/1b282880e699be37c3719308d6660a68d9081b14))
* initial configuration support ([b101fc1](https://github.com/Saghen/blink.cmp/commit/b101fc117c4f161f78c1783391f8719c619d15a5))
* keymaps in config ([d6bad7b](https://github.com/Saghen/blink.cmp/commit/d6bad7bca485ffe6c254daf1e3d2df581b37eebc))
* lock position to context start ([6ee55d4](https://github.com/Saghen/blink.cmp/commit/6ee55d4e2d938b138246e6ab11adbb320b19f7e7))
* maintain window on immediate new context while deleting ([4d1b785](https://github.com/Saghen/blink.cmp/commit/4d1b7854c2d4c373cfdc027074aa305927c5414a))
* min score on fuzzy results, avoid trimming valid items ([14a014d](https://github.com/Saghen/blink.cmp/commit/14a014dce49e658f5eed32853c9241d7869bc5dd))
* misc ([e8372ab](https://github.com/Saghen/blink.cmp/commit/e8372abf86861a8fde4612257a4f9586626ad05f))
* multi-repo setup based on mini.nvim ([15e808b](https://github.com/Saghen/blink.cmp/commit/15e808b70704e5f909305c487cb7fbfd5a95fc46))
* nerd font variant and misc cleanup ([6571c96](https://github.com/Saghen/blink.cmp/commit/6571c96b3aede5ae4f37b3d4999a4ac374593910))
* nvim cmp as default highlight ([b93a5e3](https://github.com/Saghen/blink.cmp/commit/b93a5e3476b42fc8f79bdeb6fc0f5e0ca8b4bc68))
* pre-built binary download support, misc refactors ([b1004ab](https://github.com/Saghen/blink.cmp/commit/b1004ab8c23656a5cb3d20b67bc3e5485f818ade))
* put context via wrapper ([f5d4dae](https://github.com/Saghen/blink.cmp/commit/f5d4dae67c31c2239805187f6351a4dc99259e26))
* reenable auto_show for documentation ([f1f7de4](https://github.com/Saghen/blink.cmp/commit/f1f7de496fa653518dea34bfe0446d0babac7d4e))
* rework path source ([5787816](https://github.com/Saghen/blink.cmp/commit/5787816e5e28d1c61803552008545abc851505eb))
* rework sources again ([7568de9](https://github.com/Saghen/blink.cmp/commit/7568de938a49a26cebf39369e39211f1c959cd9c))
* rework sources system ([3ee91b5](https://github.com/Saghen/blink.cmp/commit/3ee91b50e7dfc0340b723ae06c4a06f9c8e1e437))
* show on insert on trigger character ([a9ff243](https://github.com/Saghen/blink.cmp/commit/a9ff243cf0271904708b8a6ef6bf3150238cbc2d))
* signature help and misc ([fbfdf29](https://github.com/Saghen/blink.cmp/commit/fbfdf2906ea145f4faaf94865eeb40bb30dd8db2))
* smarter caching, misc fixes ([3f1c8bd](https://github.com/Saghen/blink.cmp/commit/3f1c8bd81b9499345fa50e3707fa127a58160062))
* smarter fuzzy, drop logging ([6b09eaa](https://github.com/Saghen/blink.cmp/commit/6b09eaa8f47d9bba971a0fd1e8a9e93263bb69e1))
* sort _ items last ([210f21f](https://github.com/Saghen/blink.cmp/commit/210f21fe73c150253b3dd1529852522ee47b23d3))
* source should_show, windowing config/fixes, misc ([3d1c168](https://github.com/Saghen/blink.cmp/commit/3d1c1688c6888df50069d50b07e9641f53394ce0))
* update flake to reflect merge with mono-repo ([aa80347](https://github.com/Saghen/blink.cmp/commit/aa80347f93fb95df2ca98be2c03116a27c554e04))
* use naersk to simplify build, remove unused inputs ([5579688](https://github.com/Saghen/blink.cmp/commit/55796882a7354f9dbbea5997285e1cd4e92df905))
* use remote fzrs for build ([04d5647](https://github.com/Saghen/blink.cmp/commit/04d5647009d74e6c14050d094e9d66cd1ace0b5a))
* WIP sources rework ([ad347a1](https://github.com/Saghen/blink.cmp/commit/ad347a165d2f7e3030b0fe44261e4624d9826134))

### Bug Fixes

* a lot ([8a599ba](https://github.com/Saghen/blink.cmp/commit/8a599ba6725cc0892f6d0155fbbb4bd51a02c9d5))
* accept auto brackets ([3927e23](https://github.com/Saghen/blink.cmp/commit/3927e23926ef05fc729b065c771de6ee293a587f))
* add version to pkg ([8983597](https://github.com/Saghen/blink.cmp/commit/89835978d6f6d820abb398ed01a32fcb69a10232))
* avoid immediately showing on context change ([632e6ac](https://github.com/Saghen/blink.cmp/commit/632e6ac9f3ca7ad2f78fd5f5c100e9437fccf845))
* avoid setting filetype for preview for now ([32ef1b9](https://github.com/Saghen/blink.cmp/commit/32ef1b9e79a85e9cccee274171c07034ac1a3fc3))
* buffer response context ([4650a35](https://github.com/Saghen/blink.cmp/commit/4650a35d058aba78c8c59b0aad44f0a13a08a287))
* cancel signature help request on hide ([b1fdee5](https://github.com/Saghen/blink.cmp/commit/b1fdee5277aba73791a1c991a51df7ac940d4321))
* documentation delays ([01d5fd0](https://github.com/Saghen/blink.cmp/commit/01d5fd0fc3863e0cd2c9eb53739a369ed1ca4a4e))
* keymap and simplify ([0924c8a](https://github.com/Saghen/blink.cmp/commit/0924c8a9d64121677f4ed165d4fe65b3ccb8a3ff))
* keymaps ([863bad7](https://github.com/Saghen/blink.cmp/commit/863bad7d66d616b6498c7d9ba59249138517689a))
* lazy.nvim loading ([9115fc2](https://github.com/Saghen/blink.cmp/commit/9115fc2e1dfa64d9ed974d11bc3562e8fdf67449))
* maintain autocomplete pos when scrolling/resizing ([a720117](https://github.com/Saghen/blink.cmp/commit/a720117e49c47e9c45981b419427f5d636118338))
* plugin paths ([ae4aeae](https://github.com/Saghen/blink.cmp/commit/ae4aeae0a32fde09ce64b2bb9b056ef2f1f50ad2))
* proximity and frecency bonus ([7bb4000](https://github.com/Saghen/blink.cmp/commit/7bb40005fcfc713d04db1e33461170bc012344ed))
* reference correct signature window ([30855cd](https://github.com/Saghen/blink.cmp/commit/30855cde1e9b76c351133411fad15c0f13d1dcd8))
* remove debug prints ([013dc02](https://github.com/Saghen/blink.cmp/commit/013dc0276677741f7f8c1b436303355b975a0e73))
* remove references to removed inputs ([d69b4d1](https://github.com/Saghen/blink.cmp/commit/d69b4d1c6866455d443bb9ca9dac45b1235d0757))
* set pname instead of name ([addf204](https://github.com/Saghen/blink.cmp/commit/addf204b58014cd8a87b9af57e38406b896128ce))
* snippets items ([d8a593d](https://github.com/Saghen/blink.cmp/commit/d8a593db311d83e5d8cf8db0a5ada01e92e88b16))
* sources trigger character blocklist ([69d3854](https://github.com/Saghen/blink.cmp/commit/69d38546f166fff074d3e5458b0625653d7e2e91))
* trigger, docs, so much stuff ([fae11d1](https://github.com/Saghen/blink.cmp/commit/fae11d16bb4efac3b74f84040b1f50776e4d55cb))
* update package build dir to cmp/fuzzy ([13203e3](https://github.com/Saghen/blink.cmp/commit/13203e3cb0a9196635243d0b47c33a9cb7c1326c))
