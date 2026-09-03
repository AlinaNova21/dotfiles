## Filesystem search guard

Never run `find /` (or `find / ...`, `find /var`, any unbounded whole-disk search, `grep -R /`, or `rg /`). It scans the entire filesystem, is extremely slow, hangs the agent, raises countless permission errors, and is almost never what you actually need.

Before any broad search, narrow to where the answer plausibly lives:

- Project-scoped: `rg` / `fd` / `find` rooted at the current project (e.g. `rg pattern .`).
- Home-scoped (when relevant): `find ~ ...`, or use `locate` / `mlocate` if available.
- Confined scans: `find <specific dir>` for a known subsystem (e.g. `find /home/alina/.pi`).

When you don't know where something is, ask the user where to look rather than scanning the whole disk.
