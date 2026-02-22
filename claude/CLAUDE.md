# ~/.claude/CLAUDE.md

## Zig

- I normally use [`anyzig`][1], so in projects where there is no `build.zig.zon` you have to specify
  the version (e.g. `zig 0.15.2 env`).
- Where a style is not specified, use the [TigerStyle coding conventions][2].

- [1]: https://marler8997.github.io/anyzig/
- [2]: https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md

### TigerStyle Exceptions

#### No Abreviations

Accept `freq` because it aligns with `time`: `time_domain_power_sum`, `freq_domain_power_sum`.
