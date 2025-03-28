# README

This set of scripts is to synchronise the tasks between obsidian and taskwarrior.

Technically : it is written in bash and parses directly the markdown files.



External dependencies :

- ripgrep
- sed
- awk

## installation

### create aliases

Git clone this repo and add aliases to bash scripts like following:

```bash
alias obsidian_import="~/folder-you-cloned/obsidian-taskwarrior-sync/obsidian_import.sh"
alias obsidian_export="~/folder-you-cloned/obsidian-taskwarrior-sync/obsidian_export.sh"
alias add_uuids="~/folder-you-cloned/obsidian-taskwarrior-sync/add_uuids.sh"
```

### hooks

Create  a file named "on-modify.obsidian-sync" in folder "~/.task/hooks"
```
#!/bin/bash

read -r NEW
~/folder-you-cloned/obsidian-taskwarrior-sync/obsidian_import.sh --task "$NEW"
```

## usage

### import obsidian tasks into taskwarrior

typical usage steps:

- adding uuids to obsidian tasks
- generating import file
- import file into taskwarrior

```bash
## Add uuids to all tasks
## This will modify your markdown files.
add_uuids
# generate a file tasks.ndjson
obsidian_export
task import tasks.ndjson
```

### automatically update obsidian when taskwarrior tasks are updated

Using obsidian hooks, script obsidian_import.sh is called automatically.

## reference documentations

taskwarrior import format : <https://github.com/GothenburgBitFactory/taskwarrior/blob/develop/doc/devel/rfcs/task.md>

taskwarrior hooks: <https://taskwarrior.org/docs/hooks/>s

