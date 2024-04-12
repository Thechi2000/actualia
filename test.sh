#!/bin/sh
sh scripts/import_files_coverage.sh actualia

echo Running tests
flutter test --coverage test/widgets/*.dart test/unit/*.dart test/coverage_helper_test.dart || exit 1

echo Generating coverage report
genhtml coverage/lcov.info -o coverage/html

echo Report created at coverage/html/index.html
