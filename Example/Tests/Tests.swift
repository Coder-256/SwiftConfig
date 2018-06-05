import SwiftConfig
import XCTest

func noError(_ block: () throws -> Void) {
    do {
        try block()
    } catch {
        XCTFail(error.localizedDescription)
    }
}

class Tests: XCTestCase {
    func testComputerName() {
        noError {
            print("\nComputer name: \(try DynamicStore(name: "SwiftConfig").computerInfo().name)\n")
        }
    }

    func testActiveServices() {
        noError {
            guard let services = try ConfigPreferences(name: "SwiftConfig")
                .currentNetworkSet()?
                .services()
                .filter({ try $0.enabled() && $0.interface().active() })
                .map({ "  - \($0.name() ?? "unknown"): \($0.description)" })
                else { XCTFail("Unable to get active services"); return }

            XCTAssertFalse(services.isEmpty, "No active services found. Are you connected to the internet?")
            print("\nActive services:\n\(services.joined(separator: "\n"))\n")
        }
    }
}
