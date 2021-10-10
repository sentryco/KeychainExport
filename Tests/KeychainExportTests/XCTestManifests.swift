import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(KeychainExportTests.allTests)
    ]
}
#endif
