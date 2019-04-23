# Simple XCTest Log Formatter in Swift

This is the repo with the sample code for the blog post **"Simple XCTest Log Formatter in Swift"**.

For more information visit https://vojtastavik.com/2019/04/23/xctest-log-formatter/.

## Example

#### All tests passed

![Custom XCTest Log Formatter example](/images/xctest-log-formatter-final.gif)

#### Some of the tests failed

![Custom XCTest Log Formatter fail example](/images/xctest-log-formatter-final-fail.gif)

## Usage

1. Clone this repository
```sh
$ git clone https://github.com/VojtaStavik/XCTest-Log-Formatter.git
```

2. Make sure the formatter file is executable:
```sh
$ cd XCTest-Log-Formatter
$ chmod +x format_xctest_log.swift
```

3. Copy the formatter file to the repo you want to use it in **or** simply copy it to `/usr/local/bin` to make it accessible from everywhere:
```sh
cp format_xctest_log.swift /usr/local/bin
```

4. Because the formatter formats only the test logs, **you need to separate the build and test steps.**

Here are the example commands for [Alamofire](https://github.com/Alamofire/Alamofire):
```sh
# The build step still uses xcpretty :
$ xcodebuild build-for-testing \
-workspace Alamofire.xcworkspace \
-scheme "Alamofire iOS" \
-sdk iphonesimulator \
ENABLE_TESTABILITY=YES \
| xcpretty

# The test step uses the new formatter:
$ xcodebuild test-without-building \
-workspace Alamofire.xcworkspace \
-scheme "Alamofire iOS" \
-destination "id=FE78C58A-0776-41C0-BE1C-FC7C3A07853A" \
| format_xctest_log.swift
```
