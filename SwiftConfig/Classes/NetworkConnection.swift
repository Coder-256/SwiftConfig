//
//  NetworkConnection.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

private func connectionCallout(conn: SCNetworkConnection,
                               status: SCNetworkConnectionStatus,
                               info: UnsafeMutableRawPointer?) {
    if let info = info {
        ConfigHelper<NetworkConnection, SCNetworkConnectionContext>.decodeContext(info).callout?(status)
    }
}

open class NetworkConnection: Hashable, Equatable, CustomStringConvertible {
    private var _conn: SCNetworkConnection?
    // swiftlint:disable:next force_unwrapping
    public var conn: SCNetworkConnection { return self._conn! }
    public var callout: ((SCNetworkConnectionStatus) -> Void)?

    public init(_ conn: SCNetworkConnection) {
        self._conn = conn
    }

    public init(serviceID: CFString) throws {
        var context = ConfigHelper<NetworkConnection, SCNetworkConnectionContext>.makeContext(self)
        self._conn = try SCNetworkConnectionCreateWithServiceID(nil,
                                                                serviceID,
                                                                connectionCallout(conn:status:info:),
                                                                &context)~
    }

    open func userPreferences(selectionOptions: [CFString: CFPropertyList]? = nil) throws -> (serviceID: CFString,
        userOptions: [CFString: CFPropertyList]) {
            var serviceID = Unmanaged<CFString>.passUnretained("" as CFString)
            var userOptions = Unmanaged<CFDictionary>.passUnretained([:] as CFDictionary)

            try SCNetworkConnectionCopyUserPreferences(selectionOptions as CFDictionary?, &serviceID, &userOptions)~

            return try (serviceID: serviceID.takeRetainedValue(),
                        userOptions: userOptions.takeRetainedValue()%)
    }

    open func serviceID() -> CFString! {
        return SCNetworkConnectionCopyServiceID(self.conn)
    }

    open func status() -> SCNetworkConnectionStatus {
        return SCNetworkConnectionGetStatus(self.conn)
    }

    open func extendedStatus() throws -> [CFString: CFPropertyList] {
        return try SCNetworkConnectionCopyExtendedStatus(self.conn)%
    }

    open func statistics() throws -> [CFString: CFPropertyList] {
        return try SCNetworkConnectionCopyStatistics(self.conn)%
    }

    open func start(userOptions: [CFString: CFPropertyList]?, linger: Bool) throws {
        try SCNetworkConnectionStart(self.conn, userOptions as CFDictionary?, linger)~
    }

    open func stop(forceDisconnect: Bool) throws {
        try SCNetworkConnectionStop(self.conn, forceDisconnect)~
    }

    open func userOptions() throws -> [CFString: CFPropertyList] {
        return try SCNetworkConnectionCopyUserOptions(self.conn)%
    }

    open var hashValue: Int {
        return self.conn.hashValue
    }

    public static func == (lhs: NetworkConnection, rhs: NetworkConnection) -> Bool {
        return lhs.conn == rhs.conn
    }

    open var description: String {
        return CFCopyDescription(self.conn) as String? ?? String(describing: self.conn)
    }
}
