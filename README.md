# README

This set of scripts is to synchronise the tasks between obsidian and taskwarrior.

Technically : it is written in bash and parses directly the markdown files.

External dependencies :

- ripgrep
- sed
- awk

## usage

```bash
alias tw_export="~/perso/obsidian-taskwarrior-sync/tw_export.sh"
alias add_uuids="~/perso/obsidian-taskwarrior-sync/add_uuids.sh"
add_uuids
tw_export
task import tasks.ndjson
```

## reference documentations

taskwarrior import format : <https://github.com/GothenburgBitFactory/taskwarrior/blob/develop/doc/devel/rfcs/task.md>


