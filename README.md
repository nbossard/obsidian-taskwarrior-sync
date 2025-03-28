# README

This set of scripts is to synchronise the tasks between tasks in your markdown files (added using obsidian tasks typically) and taskwarrior.
It will extract tasks in markdown files, import them in taskwarrior, and later keep markdown files up-to-date when modified in taskwarrior.

Technically : it is written in bash and parses or modifies directly the markdown files without requiring obsidian. To keep track between original file and taskwarrior it relies on UUID that are added to tasks.

For example in your markdown file a task like following is modified from :
```markdown
- [ ] feed the cat
```
to

```markdown
- [ ] feed the cat [id:: eb48e204-e8be-416b-857d-8154edbbd7ad]
```

and then when you mark it completed in taskwarrior, it is updated to

```markdown
- [x] feed the cat [id:: eb48e204-e8be-416b-857d-8154edbbd7ad]
```

## External dependencies :

To work correctly it requires following external program to be available on your computer :

- [ripgrep](https://github.com/BurntSushi/ripgrep), for speed
- sed
- awk
- and of course [taskwarrior](https://taskwarrior.org/) v3 or more

## installation

### create aliases

Git clone this repo and add aliases to bash scripts like following:

```bash
alias mtt_md_import="~/folder-you-cloned/obsidian-taskwarrior-sync/mtt_md_import.sh"
alias mtt_md_export="~/folder-you-cloned/obsidian-taskwarrior-sync/mtt_md_export.sh"
alias mtt_md_add_uuids="~/folder-you-cloned/obsidian-taskwarrior-sync/mtt_md_add_uuids.sh"
```

### hooks

Hooks are used when tasks are modified in taskwarrior to modify original markdown files they were extracted from.
Create a file named "on-modify.obsidian-sync" in folder "~/.task/hooks"
```
#!/bin/bash
read -r OLD
read -r NEW
~/folder-you-cloned/obsidian-taskwarrior-sync/mtt_md_import.sh --task "$NEW"
echo "$NEW"
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
mtt_md_uuids
# generate a file tasks.ndjson
mtt_md_export
task import tasks.ndjson
```

### automatically update obsidian when taskwarrior tasks are updated

Using obsidian hooks, script mtt_md_import.sh is called automatically.

## reference documentations

taskwarrior import format : <https://github.com/GothenburgBitFactory/taskwarrior/blob/develop/doc/devel/rfcs/task.md>

taskwarrior hooks: <https://taskwarrior.org/docs/hooks/>s

