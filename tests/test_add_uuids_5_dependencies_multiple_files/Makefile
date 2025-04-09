.PRECIOUS: tmp/modified_markdown_file%.md
tmp/modified_markdown_file1.md: existing_markdown_file1.md \
	Makefile
	cp existing_markdown_file1.md tmp/modified_markdown_file1.md
	cp existing_markdown_file2.md tmp/modified_markdown_file2.md
	../../mtt_md_add_uuids.sh --mask "tmp/*.md"

tmp/modified_markdown_file2.md: tmp/modified_markdown_file1.md

tmp/modified_markdown_file%_uuid_changed.md: tmp/modified_markdown_file%.md
	sed 's/[a-f0-9]\{8\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{12\}/11111111-1111-1111-1111-111111111111/g' $< > $@

clean:
	rm -f  tmp/*

test: tmp/modified_markdown_file1_uuid_changed.md \
      tmp/modified_markdown_file2_uuid_changed.md
	$(call .cecho,"Comparing files with cmp and diff")
	$(call compare_files,expected_markdown_file1.md,tmp/modified_markdown_file1_uuid_changed.md)
	$(call compare_files,expected_markdown_file2.md,tmp/modified_markdown_file2_uuid_changed.md)

define compare_files
	@if cmp -s $(1) $(2); then \
		echo "✅ TEST PASSED : Files are identical"; \
	else \
		echo "❌ Files are different:"; \
		DIFF_OUTPUT=$$(diff -u $(1) $(2)); \
		echo "$$DIFF_OUTPUT"; \
		exit 1; \
	fi
endef
