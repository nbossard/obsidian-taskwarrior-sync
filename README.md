# README

This set of scripts is to synchronise the tasks between obsidian and taskwarrior.

Technically : it is written in bash and parses directly the markdown files.



External dependencies :

- ripgrep
- sed
- awk

## installation

Git clone this repo and add aliases to bash scripts like following:
```bash
alias obsidian_export="~/perso/obsidian-taskwarrior-sync/obsidian_export.sh"
alias add_uuids="~/perso/obsidian-taskwarrior-sync/add_uuids.sh"
```


## usage

### import obsidian tasks into taskwarrior

steps:

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

Using hooks, WIP.

## reference documentations

taskwarrior import format : <https://github.com/GothenburgBitFactory/taskwarrior/blob/develop/doc/devel/rfcs/task.md>

taskwarrior hooks: <https://taskwarrior.org/docs/hooks/>s

