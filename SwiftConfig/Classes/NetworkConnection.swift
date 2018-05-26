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

class NetworkConnection {
    private var _conn: SCNetworkConnection?
    var conn: SCNetworkConnection { return self._conn! }
    var callout: ((SCNetworkConnectionStatus) -> ())?
    init(_ conn: SCNetworkConnection) {
        self._conn = conn
    }
    
    init?(serviceID: CFString) {
        var context = ConfigHelper<NetworkConnection, SCNetworkConnectionContext>.makeContext(self)
        guard let conn = SCNetworkConnectionCreateWithServiceID(nil, serviceID, connectionCallout(conn:status:info:), &context) else { return nil }
        self._conn = conn
    }
    
    var userPreferences: (serviceID: CFString, userOptions: CFDictionary)? {
        var serviceID = Unmanaged<CFString>.passUnretained("" as CFString)
        var userOptions = Unmanaged<CFDictionary>.passUnretained([:] as CFDictionary)

        guard SCNetworkConnectionCopyUserPreferences(nil, &serviceID, &userOptions) else { return nil }
        
        return (serviceID: serviceID.takeRetainedValue(), userOptions: userOptions.takeRetainedValue())
    }
    
    var serviceID: CFString? {
        return SCNetworkConnectionCopyServiceID(self.conn)
    }
    
    var status: SCNetworkConnectionStatus {
        return SCNetworkConnectionGetStatus(self.conn)
    }
    
    var extendedStatus: CFDictionary? {
        return SCNetworkConnectionCopyExtendedStatus(self.conn)
    }
    
    var statistics: CFDictionary? {
        return SCNetworkConnectionCopyStatistics(self.conn)
    }
    
    func start(userOptions: CFDictionary?, linger: Bool) -> Bool {
        return SCNetworkConnectionStart(self.conn, userOptions, linger)
    }
    
    func stop(forceDisconnect: Bool) -> Bool {
        return SCNetworkConnectionStop(self.conn, forceDisconnect)
    }
    
    var userOptions: CFDictionary? {
        return SCNetworkConnectionCopyUserOptions(self.conn)
    }
}
