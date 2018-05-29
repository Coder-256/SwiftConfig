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
    
    open var protocols: [NetworkProtocol]? {
        return (SCNetworkServiceCopyProtocols(self.service) as? [SCNetworkProtocol])?.map { NetworkProtocol($0) }
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
    
    open var active: Bool {
        guard let bsdName = self.interface?.bsdName else { return false }
        return check_active(bsdName)
    }
    
    open var interface: NetworkInterface? {
        guard let interface = SCNetworkServiceGetInterface(self.service) else { return nil }
        return NetworkInterface(interface)
    }
    
    open var name: String? {
        get {
            return SCNetworkServiceGetName(self.service) as String?
        } set {
            SCNetworkServiceSetName(self.service, name as CFString?)
        }
    }
    
    open func copyProtocol(protocolType: CFString) -> NetworkProtocol? {
        guard let result = SCNetworkServiceCopyProtocol(self.service, protocolType) else { return nil }
        return NetworkProtocol(result)
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
