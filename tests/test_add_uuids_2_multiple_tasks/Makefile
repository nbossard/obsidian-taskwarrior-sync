.PRECIOUS: tmp/modified_markdown_file.md
tmp/modified_markdown_file.md: existing_markdown_file.md \
	Makefile \
	../../mtt_md_add_uuids.sh

	cp $< $@
	../../mtt_md_add_uuids.sh --mask "$@"

tmp/modified_markdown_file_uuid_changed.md: tmp/modified_markdown_file.md
	sed 's/[a-f0-9]\{8\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{12\}/11111111-1111-1111-1111-111111111111/g' $< > $@

clean:
	rm -f  tmp/*

test: tmp/modified_markdown_file_uuid_changed.md
	$(call .cecho,"Comparing files with cmp and diff")
	@if cmp -s expected_markdown_file.md $<; then \
		echo "✅ TEST PASSED : Files are identical"; \
	else \
		echo "❌ Files are different:"; \
		DIFF_OUTPUT=$$(diff -u expected_markdown_file.md $<); \
		echo "$$DIFF_OUTPUT"; \
		exit 1; \
	fi

