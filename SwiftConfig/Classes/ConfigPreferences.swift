//
//  ConfigPreferences.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

fileprivate func configCallout(prefs: SCPreferences, notificationType: SCPreferencesNotification, info: UnsafeMutableRawPointer?) {
    if let info = info {
        ConfigHelper<ConfigPreferences, SCPreferencesContext>.decodeContext(info).callout?(notificationType)
    }
}

class ConfigPreferences {
    private var _prefs: SCPreferences? = nil
    var prefs: SCPreferences { return self._prefs! }
    var callout: ((SCPreferencesNotification) -> ())?
    init(_ prefs: SCPreferences) {
        self._prefs = prefs
    }
    
    init?(name: CFString, prefsID: CFString? = nil, authorization auth: AuthorizationRef? = nil) {
        let result: SCPreferences?
        if let auth = auth {
            result = SCPreferencesCreateWithAuthorization(nil, name, prefsID, auth)
        } else {
            result = SCPreferencesCreate(nil, name, prefsID)
        }
        guard let prefs = result else { return nil }
        
        var context = ConfigHelper<ConfigPreferences, SCPreferencesContext>.makeContext(self)
        SCPreferencesSetCallback(self.prefs, configCallout(prefs:notificationType:info:), &context)
        self._prefs = prefs
    }
    
    func lock(wait: Bool) -> Bool {
        return SCPreferencesLock(self.prefs, wait)
    }
    
    func commitChanges() -> Bool {
        return SCPreferencesCommitChanges(self.prefs)
    }
    
    func applyChanges() -> Bool {
        return SCPreferencesApplyChanges(self.prefs)
    }
    
    @discardableResult func unlock() -> Bool {
        return SCPreferencesUnlock(self.prefs)
    }
    
    func withLock<T>(wait: Bool, block: () throws -> T) rethrows -> T? {
        if self.lock(wait: wait) {
            let result = try block()
            self.unlock()
            return result
        } else {
            return nil
        }
    }
    
    func synchronize() {
        SCPreferencesSynchronize(self.prefs)
    }
    
    var signature: CFData? {
        return SCPreferencesGetSignature(self.prefs)
    }
    
    var keys: CFArray? {
        return SCPreferencesCopyKeyList(self.prefs)
    }
    
    subscript(_ key: CFString) -> CFPropertyList? {
        get {
            return SCPreferencesGetValue(self.prefs, key)
        }
        set(value) {
            if let value = value {
                SCPreferencesSetValue(self.prefs, key, value)
            } else {
                SCPreferencesRemoveValue(self.prefs, key)
            }
        }
    }
    
    subscript(path path: CFString) -> CFDictionary? {
        get {
            return SCPreferencesPathGetValue(self.prefs, path)
        }
        set(value) {
            if let value = value {
                SCPreferencesPathSetValue(self.prefs, path, value)
            } else {
                SCPreferencesPathRemoveValue(self.prefs, path)
            }
        }
    }
    
    func createUniqueChild(prefix: CFString) -> CFString? {
        return SCPreferencesPathCreateUniqueChild(self.prefs, prefix)
    }
    
    func getLink(path: CFString) -> CFString? {
        return SCPreferencesPathGetLink(self.prefs, path)
    }
    
    func setLink(path: CFString, link: CFString) -> Bool {
        return SCPreferencesPathSetLink(self.prefs, path, link)
    }
    
    func serviceCreate(interface: SCNetworkInterface) -> NetworkService? {
        guard let result = SCNetworkServiceCreate(self.prefs, interface) else { return nil }
        return NetworkService(result)
    }
    
    func serviceCopy(serviceID: CFString) -> NetworkService? {
        guard let result = SCNetworkServiceCopy(self.prefs, serviceID) else { return nil }
        return NetworkService(result)
    }
    
    func networkSetCreate() -> NetworkSet? {
        guard let result = SCNetworkSetCreate(self.prefs) else { return nil }
        return NetworkSet(result)
    }
    
    var networkSets: [NetworkSet]? {
        guard let arr = SCNetworkSetCopyAll(self.prefs) as? [SCNetworkSet] else { return nil }
        return arr.map { NetworkSet($0) }
    }
    
    var currentNetworkSet: NetworkSet? {
        guard let result = SCNetworkSetCopyCurrent(self.prefs) else { return nil }
        return NetworkSet(result)
    }
    
    func networkSet(setID: CFString) -> NetworkSet? {
        guard let result = SCNetworkSetCopy(self.prefs, setID) else { return nil }
        return NetworkSet(result)
    }
    
    func setComputerName(name: CFString?, nameEncoding: CFStringEncoding) -> Bool {
        return SCPreferencesSetComputerName(self.prefs, name, nameEncoding)
    }
    
    func setLocalHostName(name: CFString?) -> Bool {
        return SCPreferencesSetLocalHostName(self.prefs, name)
    }
    
    // MARK: Bond
    
    var bondInterfaces: [BondNetworkInterface]? {
        guard let arr = SCBondInterfaceCopyAll(self.prefs) as? [SCBondInterface] else { return nil }
        return arr.map { BondNetworkInterface($0) }
    }
    
    var bondMemberInterfaces: [BondNetworkInterface]? {
        guard let arr = SCBondInterfaceCopyAvailableMemberInterfaces(self.prefs) as? [SCBondInterface] else { return nil }
        return arr.map { BondNetworkInterface($0) }
    }
    
    func bondCreate() -> BondNetworkInterface? {
        guard let result = SCBondInterfaceCreate(self.prefs) else { return nil }
        return BondNetworkInterface(result)
    }
    
    // MARK: VLAN
    
    var vlanInterfaces: [VLANNetworkInterface]? {
        guard let arr = SCVLANInterfaceCopyAll(self.prefs) as? [SCVLANInterface] else { return nil }
        return arr.map { VLANNetworkInterface($0) }
    }
    
    func vlanCreate(physical: VLANNetworkInterface, tag: CFNumber) -> VLANNetworkInterface? {
        guard let result = SCVLANInterfaceCreate(self.prefs, physical.interface, tag) else { return nil }
        return VLANNetworkInterface(result)
    }
    
    var services: [NetworkService]? {
        guard let result = SCNetworkServiceCopyAll(self.prefs) as? [SCNetworkService] else { return nil }
        return result.map { NetworkService($0) }
    }
}
