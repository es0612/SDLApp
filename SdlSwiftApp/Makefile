unit-tests:
	@/usr/bin/time xcodebuild \
	-project "SdlSwiftApp.xcodeproj" \
	-scheme "SdlSwiftApp" \
	-destination "platform=iOS Simulator,name=iPhone Xʀ,OS=latest" \
	build test

sort:
	@perl ./bin/sortXcodeProject "SdlSwiftApp.xcodeproj/project.pbxproj"

tests: sort unit-tests

bootstrap:
	@carthage bootstrap --platform iOS --no-use-binaries --cache-builds

update:
	@carthage update --platform iOS --no-use-binaries --cache-builds

ci:
	bootstrap unit-tests

beta:
	@/usr/bin/time fastlane beta
