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
            print("Computer name: \(try DynamicStore(name: "SwiftConfig").computerInfo().name)")
        }
    }

    func testActiveServices() {
        noError {
            guard let firstActive = try ConfigPreferences(name: "SwiftConfig")
                .currentNetworkSet()?
                .services()
                .first(where: { try $0.enabled() && $0.interface().active() })?
                .name() else { XCTFail("No active service found. Are you connected to the internet?"); return }

            print("First active service: \(firstActive)")
        }
    }
}
