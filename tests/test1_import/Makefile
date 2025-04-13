# generated the markdown file modified by mtt_md_import
tmp/modified_markdown_file.md: existing_markdown_file.md \
	Makefile \
	task_to_be_imported.json \
	../../mtt_md_import.sh
	cp ./existing_markdown_file.md tmp/modified_markdown_file.md
	../../mtt_md_import.sh --task '$(shell cat task_to_be_imported.json)'

clean:
	rm -f tmp/*

test: tmp/modified_markdown_file.md
	$(call .cecho,"Comparing files with cmp and diff")
	@if cmp -s expected_markdown_file.md tmp/modified_markdown_file.md; then \
		echo "✅ TEST PASSED : Files are identical"; \
	else \
		echo "❌ Files are different:"; \
		DIFF_OUTPUT=$$(diff -u expected_markdown_file.md tmp/modified_markdown_file.md); \
		echo "$$DIFF_OUTPUT"; \
		exit 1; \
	fi

