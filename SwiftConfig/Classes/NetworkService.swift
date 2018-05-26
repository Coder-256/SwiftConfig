//
//  NetworkService.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class NetworkService {
    open let service: SCNetworkService
    public init(_ service: SCNetworkService) {
        self.service = service
    }
    
    @discardableResult open func addProtocolType(_ protocolType: CFString) -> Bool {
        return SCNetworkServiceAddProtocolType(self.service, protocolType)
    }
    
    open var protocols: CFArray? {
        return SCNetworkServiceCopyProtocols(self.service)
    }
    
    open func establishDefault() -> Bool {
        return SCNetworkServiceEstablishDefaultConfiguration(self.service)
    }
    
    open var enabled: Bool {
        get {
            return SCNetworkServiceGetEnabled(self.service)
        } set {
            SCNetworkServiceSetEnabled(self.service, newValue)
        }
    }
    
    open var interface: NetworkInterface? {
        guard let interface = SCNetworkServiceGetInterface(self.service) else { return nil }
        return NetworkInterface(interface)
    }
    
    open var name: CFString? {
        get {
        return SCNetworkServiceGetName(self.service)
        } set {
            SCNetworkServiceSetName(self.service, name)
        }
    }
    
    open func copyProtocol(protocolType: CFString) -> SCNetworkProtocol? {
        return SCNetworkServiceCopyProtocol(self.service, protocolType)
    }
    
    open var serviceID: CFString? {
        return SCNetworkServiceGetServiceID(self.service)
    }
    
    open func remove() -> Bool {
        return SCNetworkServiceRemove(self.service)
    }
    
    open func remove(protocolType: CFString) -> Bool {
        return SCNetworkServiceRemoveProtocolType(self.service, protocolType)
    }
}
