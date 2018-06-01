//
//  NetworkInterface.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class NetworkProtocol: Hashable, Equatable {
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
        return SCNetworkProtocolGetProtocolType(self.netProtocol)
    }
    
    open var hashValue: Int {
        return self.netProtocol.hashValue
    }
    
    open static func == (lhs: NetworkProtocol, rhs: NetworkProtocol) -> Bool {
        return lhs.netProtocol == rhs.netProtocol
    }
}
