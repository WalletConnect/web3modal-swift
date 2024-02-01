unit_tests:
	./run_tests.sh --scheme swift-web3modal-Package

release:
	fastlane release_testflight token:$(TOKEN) project_id:$(PROJECT_ID)