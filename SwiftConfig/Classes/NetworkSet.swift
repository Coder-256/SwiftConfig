//
//  NetworkSet.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class NetworkSet {
    open let set: SCNetworkSet
    public init(_ set: SCNetworkSet) {
        self.set = set
    }
    
    open func add(service: NetworkService) -> Bool {
        return SCNetworkSetAddService(self.set, service.service)
    }
    
    open func remove(service: NetworkService) -> Bool {
        return SCNetworkSetRemoveService(self.set, service.service)
    }
    
    open func contains(interface: NetworkInterface) -> Bool {
        return SCNetworkSetContainsInterface(self.set, interface.interface)
    }
    
    open var services: [NetworkService]? {
        guard let arr = SCNetworkSetCopyServices(self.set) as? [SCNetworkService] else { return nil }
        return arr.map { NetworkService($0) }
    }
    
    open var name: String? {
        get {
            return SCNetworkSetGetName(self.set) as String?
        } set {
            SCNetworkSetSetName(self.set, newValue as CFString?)
        }
    }
    
    open var setID: CFString? {
        return SCNetworkSetGetSetID(self.set)
    }
    
    open var serviceOrder: [NetworkService]? {
        get {
            guard let arr = SCNetworkSetGetServiceOrder(self.set) as? [SCNetworkService] else { return nil }
            return arr.map { NetworkService($0) }
        } set {
            if let newValue = newValue {
                SCNetworkSetSetServiceOrder(self.set, newValue.map { $0.service } as CFArray)
            }
        }
    }
    
    open func makeCurrent() -> Bool {
        return SCNetworkSetSetCurrent(self.set)
    }
    
    open func remove() -> Bool {
        return SCNetworkSetRemove(self.set)
    }
}
