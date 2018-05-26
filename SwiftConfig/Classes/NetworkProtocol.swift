//
//  NetworkInterface.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class NetworkProtocol {
    open let netProtocol: SCNetworkProtocol
    public init(_ netProtocol: SCNetworkProtocol) {
        self.netProtocol = netProtocol
    }
    
    open var configuration: [CFString: CFPropertyList]? {
        get {
            return SCNetworkProtocolGetConfiguration(self.netProtocol) as? [CFString: CFPropertyList]
        } set {
            SCNetworkProtocolSetConfiguration(self.netProtocol, newValue as CFDictionary?)
        }
    }
    
    open var enabled: Bool {
        get {
            return SCNetworkProtocolGetEnabled(self.netProtocol)
        } set {
            SCNetworkProtocolSetEnabled(self.netProtocol, newValue)
        }
    }
    
    open var protocolType: CFString? {
        return SCNetworkProtocolGetProtocolType(self.netProtocol)
    }
}
