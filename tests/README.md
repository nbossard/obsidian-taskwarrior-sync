# README

This is folder for tests.

List of tests written, on import :

- [test1_import](./test1_import/README.md) modification of a task description in TW being synced back to original file.
- [test2_import_non_existing_source_file](./test2_import_non_existing_source_file/README.md) modification of a task description in TW being synced back to a file that non longer exists.
- [test3_import_task_with_dependency](./test3_import_with_dependency/README.md) modification of a task completion in TW synced back to original file.
- [test4_import_deleted](./test4_import_deleted/README.md) modification of a task to deleted in TW synced back to original file.

on add uuid :
- [test_add_uuids_1](./test_add_uuids_1/README.md) adding uuid on one existing task in one markdown file
- [test_add_uuids_2_multiple_tasks](./test_add_uuids_2_multiple_tasks/README.md) adding uuid on multiple existing task in one markdown file
- [test_add_uuids_3_multiple_files](./test_add_uuids_3_multiple_files/README.md) adding uuid on multiple existing task in multiple files
- [test_add_uuids_4_dependencies_single_file](./test_add_uuids_4_dependencies_single_file/README.md) replace dependency by UUIDs
- [test_add_uuids_5_dependencies_multiple_files](./test_add_uuids_5_dependencies_multiple_files/README.md) replace dependency by UUIDs across multiple files

## To launch tests

```bash
make test
```

