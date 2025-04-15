test:
	@# make test fail if return code is not 0
	@if ../../mtt_check_requirements.sh > /dev/null 2>&1; then \
		echo "✅ TEST PASSED : All requirements are met"; \
	else \
		echo "❌ TEST FAILED : Missing requirements"; \
		../../mtt_check_requirements.sh; \
		exit 1; \
	fi
