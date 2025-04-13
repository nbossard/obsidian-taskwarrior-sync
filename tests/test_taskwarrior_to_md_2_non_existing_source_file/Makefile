
clean:
	@echo "Nothing to be cleaned"

test: ../../mtt_taskwarrior_to_md.sh
	@echo "Testing import with non-existing markdown file..."
	@if ../../mtt_taskwarrior_to_md.sh --task '$(shell cat task_to_be_imported.json)' 2>/dev/null; then \
		echo "❌ TEST FAILED: Command succeeded but should have failed"; \
		exit 1; \
	else \
		EXIT_CODE=$$?; \
		if [ $$EXIT_CODE -eq 2 ]; then \
			echo "✅ TEST PASSED: Command failed with expected exit code 2"; \
		else \
			echo "❌ TEST FAILED: Expected exit code 2 but got $$EXIT_CODE"; \
			exit 1; \
		fi \
	fi

