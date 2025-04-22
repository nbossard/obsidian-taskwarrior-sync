test:
	$(MAKE) -C test_md_to_taskwarrior_1 $@
	$(MAKE) -C test_md_to_taskwarrior_2_with_priority $@
	$(MAKE) -C test_md_to_taskwarrior_3_with_dates $@
	$(MAKE) -C test_taskwarrior_to_md_1 $@
	$(MAKE) -C test_taskwarrior_to_md_2_non_existing_source_file $@
	$(MAKE) -C test_taskwarrior_to_md_3_with_dependency $@
	$(MAKE) -C test_taskwarrior_to_md_4_deleted $@
	$(MAKE) -C test_taskwarrior_to_md_5_with_priority $@
    $(MAKE) -C test_taskwarrior_to_md_6_desc_with_quote $@
	$(MAKE) -C test_add_uuids_1 $@
	$(MAKE) -C test_add_uuids_2_multiple_tasks $@
	$(MAKE) -C test_add_uuids_3_multiple_files $@
	$(MAKE) -C test_add_uuids_4_dependencies_single_file $@
	$(MAKE) -C test_add_uuids_5_dependencies_multiple_files $@
	$(MAKE) -C test_check_requirements $@

clean:
	$(MAKE) -C test_add_uuids_1 $@
	$(MAKE) -C test_add_uuids_2_multiple_tasks $@
	$(MAKE) -C test_add_uuids_3_multiple_files $@
	$(MAKE) -C test_add_uuids_4_dependencies_single_file $@
	$(MAKE) -C test_add_uuids_5_dependencies_multiple_files $@
	$(MAKE) -C test_check_requirements $@
	$(MAKE) -C test_md_to_taskwarrior_1 $@
	$(MAKE) -C test_md_to_taskwarrior_2_with_priority $@
	$(MAKE) -C test_md_to_taskwarrior_3_with_dates $@
	$(MAKE) -C test_taskwarrior_to_md_2_non_existing_source_file $@
	$(MAKE) -C test_taskwarrior_to_md_3_with_dependency $@
	$(MAKE) -C test_taskwarrior_to_md_4_deleted $@
	$(MAKE) -C test_taskwarrior_to_md_5_with_priority $@
    $(MAKE) -C test_taskwarrior_to_md_6_desc_with_quote $@

