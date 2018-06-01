//
//  NetworkConnection.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

fileprivate func connectionCallout(conn: SCNetworkConnection, status: SCNetworkConnectionStatus, info: UnsafeMutableRawPointer?) {
    if let info = info {
        ConfigHelper<NetworkConnection, SCNetworkConnectionContext>.decodeContext(info).callout?(status)
    }
}

open class NetworkConnection {
    private var _conn: SCNetworkConnection?
    open var conn: SCNetworkConnection { return self._conn! }
    open var callout: ((SCNetworkConnectionStatus) -> ())?
    public init(_ conn: SCNetworkConnection) {
        self._conn = conn
    }
    
    public init?(serviceID: CFString) {
        var context = ConfigHelper<NetworkConnection, SCNetworkConnectionContext>.makeContext(self)
        guard let conn = SCNetworkConnectionCreateWithServiceID(nil, serviceID, connectionCallout(conn:status:info:), &context) else { return nil }
        self._conn = conn
    }
    
    open func userPreferences(selectionOptions: [CFString: CFPropertyList]? = nil) throws -> (serviceID: CFString, userOptions: [CFString: CFPropertyList]) {
        var serviceID = Unmanaged<CFString>.passUnretained("" as CFString)
        var userOptions = Unmanaged<CFDictionary>.passUnretained([:] as CFDictionary)
        
        try SCNetworkConnectionCopyUserPreferences(selectionOptions as CFDictionary?, &serviceID, &userOptions)~
        
        return try (serviceID: serviceID.takeRetainedValue(),
                    userOptions: userOptions.takeRetainedValue()%)
    }
    
    open func serviceID() -> CFString? {
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
}
