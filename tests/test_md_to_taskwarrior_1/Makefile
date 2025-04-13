# generate the markdown file modified by mtt_taskwarrior_to_md
tmp/tasks.ndjson: existing_markdown_file.md \
	Makefile
	../../mtt_md_to_taskwarrior.sh
	mv tasks.ndjson tmp/tasks.ndjson

# remove the path in annotation.description, keep only the filename for easy comparison
tmp/tasks_removed_path.ndjson: tmp/tasks.ndjson
	jq 'if .annotations then .annotations |= map(.description |= (if startswith("Source: ") then "Source: " + (.[8:] | split("/")[-1]) else . end)) else . end' $< > $@


clean:
	rm -f tmp/*

test: tmp/tasks_removed_path.ndjson
	$(call .cecho,"Comparing files with cmp and diff")
	@if cmp -s expected_tasks.ndjson $<; then \
		echo "✅ TEST PASSED : Files are identical"; \
	else \
		echo "❌ Files are different:"; \
		DIFF_OUTPUT=$$(diff -u expected_markdown_file.md tmp/modified_markdown_file.md); \
		echo "$$DIFF_OUTPUT"; \
		exit 1; \
	fi

