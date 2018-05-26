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
    typealias Key = CFString
    typealias Value = CFPropertyList
    
    private(set) var _store: SCDynamicStore? = nil
    var store: SCDynamicStore { return self._store! }
    var callout: (([Key]) -> ())?
    var notificationKeys: [Key] = [] {
        didSet {
            SCDynamicStoreSetNotificationKeys(self.store, self.notificationKeys as CFArray, nil)
        }
    }
    
    init(_ store: SCDynamicStore) {
        self._store = store
    }
    
    init!(name: CFString) {
        var context = ConfigHelper<DynamicStore, SCDynamicStoreContext>.makeContext(self)
        guard let store = SCDynamicStoreCreate(nil, name, storeCallout(store:changedKeys:info:), &context) else { return nil }
        self._store = store
    }
    
    convenience init!(name: String) {
        self.init(name: name as CFString)
    }
    
    subscript(_ key: Key) -> Value? {
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
    
    var computerInfo: (name: CFString?, encoding: CFStringEncoding?) {
        var encoding: CFStringEncoding = 0
        let name = SCDynamicStoreCopyComputerName(self.store, &encoding)
        return (name: name, encoding: encoding)
    }
    
    var consoleUser: (uid: uid_t?, gid: gid_t?, info: CFString?) {
        var uid: uid_t = 0
        var gid: gid_t = 0
        let info = SCDynamicStoreCopyConsoleUser(store, &uid, &gid)
        guard info != nil else { return (uid: nil, gid: nil, info: nil) }
        return (uid: uid, gid: gid, info: info)
    }
    
    var localHostName: CFString? {
        return SCDynamicStoreCopyLocalHostName(store)
    }
    
    var currentLocationIdentifier: CFString? {
        return SCDynamicStoreCopyLocalHostName(store)
    }
    
    var proxies: CFDictionary? {
        return SCDynamicStoreCopyProxies(store)
    }
    
    func key(domain: CFString, globalEntity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkGlobalEntity(nil, domain, globalEntity)
    }
    
    func keyInterface(domain: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkInterface(nil, domain)
    }
    
    func key(domain: CFString, ifname: CFString, entity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkInterfaceEntity(nil, domain, ifname, entity)
    }
    
    func key(domain: CFString, serviceID: CFString, entity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkServiceEntity(nil, domain, serviceID, entity)
    }
    
    var keyComputerName: Key {
        return SCDynamicStoreKeyCreateComputerName(nil)
    }
    
    var keyConsoleUser: Key {
        return SCDynamicStoreKeyCreateConsoleUser(nil)
    }
    
    var keyHostNames: Key {
        return SCDynamicStoreKeyCreateHostNames(nil)
    }
    
    var keyLocation: Key {
        return SCDynamicStoreKeyCreateLocation(nil)
    }
    
    var keyProxies: Key {
        return SCDynamicStoreKeyCreateProxies(nil)
    }
    
    // MARK: DHCP
    
    class DHCPInfo {
        let info: CFDictionary
        init(_ info: CFDictionary) {
            self.info = info
        }
        
        func getOptionData(code: UInt8) -> CFData? {
            return DHCPInfoGetOptionData(self.info, code)
        }
        
        var leaseStart: CFDate? {
            return DHCPInfoGetLeaseStartTime(self.info)
        }
        
        var leaseExpiration: CFDate? {
            return DHCPInfoGetLeaseExpirationTime(self.info)
        }
    }
    
    var dhcpInfo: DHCPInfo? {
        guard let info = SCDynamicStoreCopyDHCPInfo(self.store, nil) else { return nil }
        return DHCPInfo(info)
    }
    
    func dhcpInfo(serviceID: CFString) -> DHCPInfo? {
        guard let info = SCDynamicStoreCopyDHCPInfo(self.store, serviceID) else { return nil }
        return DHCPInfo(info)
    }
}


