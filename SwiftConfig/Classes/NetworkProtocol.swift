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
    
    open func configuration() throws -> [CFString: CFPropertyList] {
        return try SCNetworkProtocolGetConfiguration(self.netProtocol)%
    }
    
    open func setConfiguration(_ newValue: [CFString: CFPropertyList]?) throws {
        try SCNetworkProtocolSetConfiguration(self.netProtocol, newValue as CFDictionary?)~
    }
    
    open func enabled() -> Bool {
        return SCNetworkProtocolGetEnabled(self.netProtocol)
    }
    
    open func setEnabled(_ newValue: Bool) throws {
        try SCNetworkProtocolSetEnabled(self.netProtocol, newValue)~
    }
    
    open func protocolType() -> CFString! {
        // Specified as non-nil in SCNetworkProtocol.c:166
        return SCNetworkProtocolGetProtocolType(self.netProtocol)
    }
}
