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
    
    open var userPreferences: (serviceID: CFString, userOptions: CFDictionary)? {
        var serviceID = Unmanaged<CFString>.passUnretained("" as CFString)
        var userOptions = Unmanaged<CFDictionary>.passUnretained([:] as CFDictionary)

        guard SCNetworkConnectionCopyUserPreferences(nil, &serviceID, &userOptions) else { return nil }
        
        return (serviceID: serviceID.takeRetainedValue(), userOptions: userOptions.takeRetainedValue())
    }
    
    open var serviceID: CFString? {
        return SCNetworkConnectionCopyServiceID(self.conn)
    }
    
    open var status: SCNetworkConnectionStatus {
        return SCNetworkConnectionGetStatus(self.conn)
    }
    
    open var extendedStatus: CFDictionary? {
        return SCNetworkConnectionCopyExtendedStatus(self.conn)
    }
    
    open var statistics: CFDictionary? {
        return SCNetworkConnectionCopyStatistics(self.conn)
    }
    
    open func start(userOptions: CFDictionary?, linger: Bool) -> Bool {
        return SCNetworkConnectionStart(self.conn, userOptions, linger)
    }
    
    open func stop(forceDisconnect: Bool) -> Bool {
        return SCNetworkConnectionStop(self.conn, forceDisconnect)
    }
    
    open var userOptions: CFDictionary? {
        return SCNetworkConnectionCopyUserOptions(self.conn)
    }
}
