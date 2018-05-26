//
//  DynamicStore.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration
import SystemConfiguration.SCDynamicStoreCopyDHCPInfo

fileprivate func storeCallout(store: SCDynamicStore, changedKeys: CFArray, info: UnsafeMutableRawPointer?) {
    if let info = info, let changedKeys = changedKeys as? [DynamicStore.Key] {
        ConfigHelper<DynamicStore, SCDynamicStoreContext>.decodeContext(info).callout?(changedKeys)
    }
}

open class DynamicStore {
    public typealias Key = CFString
    public typealias Value = CFPropertyList
    
    private(set) var _store: SCDynamicStore? = nil
    open var store: SCDynamicStore { return self._store! }
    open var callout: (([Key]) -> ())?
    open var notificationKeys: [Key] = [] {
        didSet {
            SCDynamicStoreSetNotificationKeys(self.store, self.notificationKeys as CFArray, nil)
        }
    }
    
    public init(_ store: SCDynamicStore) {
        self._store = store
    }
    
    public init?(name: CFString) {
        var context = ConfigHelper<DynamicStore, SCDynamicStoreContext>.makeContext(self)
        guard let store = SCDynamicStoreCreate(nil, name, storeCallout(store:changedKeys:info:), &context) else { return nil }
        self._store = store
    }
    
    public convenience init?(name: String) {
        self.init(name: name as CFString)
    }
    
    open subscript(_ key: Key) -> Value? {
        get {
            return SCDynamicStoreCopyValue(self.store, key)
        }
        set(value) {
            if let value = value {
                SCDynamicStoreSetValue(self.store, key, value)
            } else {
                SCDynamicStoreRemoveValue(self.store, key)
            }
        }
    }
    
    open var computerInfo: (name: String?, encoding: CFStringEncoding?) {
        var encoding: CFStringEncoding = 0
        let name = SCDynamicStoreCopyComputerName(self.store, &encoding) as String?
        return (name: name, encoding: encoding)
    }
    
    open var consoleUser: (uid: uid_t?, gid: gid_t?, info: String?) {
        var uid: uid_t = 0
        var gid: gid_t = 0
        let info = SCDynamicStoreCopyConsoleUser(store, &uid, &gid) as String?
        guard info != nil else { return (uid: nil, gid: nil, info: nil) }
        return (uid: uid, gid: gid, info: info)
    }
    
    open var localHostName: String? {
        return SCDynamicStoreCopyLocalHostName(store) as String?
    }
    
    open var currentLocationIdentifier: CFString? {
        return SCDynamicStoreCopyLocalHostName(store)
    }
    
    open var proxies: [CFString: CFPropertyList]? {
        return SCDynamicStoreCopyProxies(store) as? [CFString: CFPropertyList]
    }
    
    open func key(domain: CFString, globalEntity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkGlobalEntity(nil, domain, globalEntity)
    }
    
    open func keyInterface(domain: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkInterface(nil, domain)
    }
    
    open func key(domain: CFString, ifname: CFString, entity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkInterfaceEntity(nil, domain, ifname, entity)
    }
    
    open func key(domain: CFString, serviceID: CFString, entity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkServiceEntity(nil, domain, serviceID, entity)
    }
    
    open var keyComputerName: Key {
        return SCDynamicStoreKeyCreateComputerName(nil)
    }
    
    open var keyConsoleUser: Key {
        return SCDynamicStoreKeyCreateConsoleUser(nil)
    }
    
    open var keyHostNames: Key {
        return SCDynamicStoreKeyCreateHostNames(nil)
    }
    
    open var keyLocation: Key {
        return SCDynamicStoreKeyCreateLocation(nil)
    }
    
    open var keyProxies: Key {
        return SCDynamicStoreKeyCreateProxies(nil)
    }
    
    // MARK: DHCP
    
    open class DHCPInfo {
        open let info: CFDictionary
        public init(_ info: CFDictionary) {
            self.info = info
        }
        
        open func getOptionData(code: UInt8) -> CFData? {
            return DHCPInfoGetOptionData(self.info, code)
        }
        
        open var leaseStart: CFDate? {
            return DHCPInfoGetLeaseStartTime(self.info)
        }
        
        open var leaseExpiration: CFDate? {
            return DHCPInfoGetLeaseExpirationTime(self.info)
        }
    }
    
    open var dhcpInfo: DHCPInfo? {
        guard let info = SCDynamicStoreCopyDHCPInfo(self.store, nil) else { return nil }
        return DHCPInfo(info)
    }
    
    open func dhcpInfo(serviceID: CFString) -> DHCPInfo? {
        guard let info = SCDynamicStoreCopyDHCPInfo(self.store, serviceID) else { return nil }
        return DHCPInfo(info)
    }
}


