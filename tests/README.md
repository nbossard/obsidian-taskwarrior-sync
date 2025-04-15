# README

This is folder for tests.

List of tests written :

## on taskwarrior to md :

- [test_taskwarrior_to_md](./test_taskwarrior_to_md/README.md) modification of a task description in TW being synced back to original file.
- [test_taskwarrior_to_md_2_non_existing_source_file](./test_taskwarrior_to_md_2_non_existing_source_file/README.md) modification of a task description in TW being synced back to a file that non longer exists.
- [test_taskwarrior_to_md_3_with_dependency](./test_taskwarrior_to_md_3_with_dependency/README.md) modification of a task completion in TW synced back to original file.
- [test_taskwarrior_to_md_4_deleted](./test_taskwarrior_to_md_4_deleted/README.md) modification of a task to deleted in TW synced back to original file.
- [test_taskwarrior_to_md_5_with_priority](./test_taskwarrior_to_md_5_with_priority/README.md) modification of a task completion in TW that has priority

## on md to taskwarrior

- [test_md_to_taskwarrior_1](./test_md_to_taskwarrior_1/README.md)
- [test_md_to_taskwarrior_2_with_priority](./test_md_to_taskwarrior_2_with_priority/README.md-

## on add uuid :

- [test_add_uuids_1](./test_add_uuids_1/README.md) adding uuid on one existing task in one markdown file
- [test_add_uuids_2_multiple_tasks](./test_add_uuids_2_multiple_tasks/README.md) adding uuid on multiple existing task in one markdown file
- [test_add_uuids_3_multiple_files](./test_add_uuids_3_multiple_files/README.md) adding uuid on multiple existing task in multiple files
- [test_add_uuids_4_dependencies_single_file](./test_add_uuids_4_dependencies_single_file/README.md) replace dependency by UUIDs
- [test_add_uuids_5_dependencies_multiple_files](./test_add_uuids_5_dependencies_multiple_files/README.md) replace dependency by UUIDs across multiple files

## on check requirements

[test_check_requirements](./test_check_requirements/README.md)

## To launch tests

```bash
make test
```

