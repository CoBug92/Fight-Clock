.PHONY: bootstrap generate lint test build sounds

bootstrap:
	./scripts/bootstrap.sh

generate:
	./scripts/generate.sh

lint:
	./scripts/swiftlint/swiftlint.sh

test:
	@set -eu; \
	. ./scripts/.env; \
	if [ ! -d "$$PROJECT_NAME.xcodeproj" ]; then $(MAKE) generate; fi; \
	destination="$${CI_XCODE_DESTINATION:-}"; \
	if [ -z "$$destination" ]; then \
		if ! simulator_json="$$(xcrun simctl list devices available -j 2>/dev/null)"; then \
			echo "Unable to query available iPhone simulators. Check CoreSimulatorService." >&2; \
			exit 1; \
		fi; \
		destination="$$(printf '%s' "$$simulator_json" | ruby -rjson -e 'devices = JSON.parse(STDIN.read).fetch("devices"); candidates = devices.flat_map { |runtime, entries| runtime.include?("iOS") ? entries.filter_map { |device| [runtime, device] if device["isAvailable"] && device["name"].start_with?("iPhone") } : [] }; selected = candidates.max_by { |runtime, device| [runtime.scan(/\d+/).map(&:to_i), device["name"]] }; abort "No available iPhone simulator was found" unless selected; puts "platform=iOS Simulator,id=#{selected.last.fetch("udid")}"')"; \
	fi; \
	printf 'Testing on %s\n' "$$destination"; \
	xcodebuild -project "$$PROJECT_NAME.xcodeproj" -scheme "$$TARGET_NAME" -destination "$$destination" -derivedDataPath .DerivedData CODE_SIGNING_ALLOWED=NO test

build:
	@set -eu; \
	. ./scripts/.env; \
	if [ ! -d "$$PROJECT_NAME.xcodeproj" ]; then $(MAKE) generate; fi; \
	xcodebuild -project "$$PROJECT_NAME.xcodeproj" -scheme "$$TARGET_NAME" -configuration Debug -destination "$${CI_BUILD_DESTINATION:-generic/platform=iOS Simulator}" -derivedDataPath .DerivedData CODE_SIGNING_ALLOWED=NO build

sounds:
	./scripts/sounds/generate.sh
