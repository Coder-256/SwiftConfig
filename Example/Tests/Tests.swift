import XCTest
import SwiftConfig

class Tests: XCTestCase {
    func testComputerName() {
        if let computerName = DynamicStore(name: "SwiftConfig")?.computerInfo.name as String? {
            print("Computer name: \(computerName)")
            return
        }
        XCTFail()
    }
    
    func testActiveServices() {
        if let firstActive = ConfigPreferences(name: "SwiftConfig")?
            .currentNetworkSet?
            .services?
            .first(where: { $0.enabled && ($0.interface?.active ?? false) })?
            .name {
            print("First active service: \(firstActive)")
            return
        }
        XCTFail()
    }
}

