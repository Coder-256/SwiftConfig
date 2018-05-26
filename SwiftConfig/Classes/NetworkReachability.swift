//
//  NetworkReachability.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

fileprivate func reachabilityCallout(target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    if let info = info {
        ConfigHelper<NetworkReachability, SCNetworkReachabilityContext>.decodeContext(info).callout?(flags)
    }
}

open class NetworkReachability {
    private var _target: SCNetworkReachability?
    open var target: SCNetworkReachability { return self._target! }
    open var callout: ((SCNetworkReachabilityFlags) -> ())?
    
    @discardableResult private func setupCallout() -> Bool {
        var context = ConfigHelper<NetworkReachability, SCNetworkReachabilityContext>.makeContext(self)
        return SCNetworkReachabilitySetCallback(self.target, reachabilityCallout(target:flags:info:), &context)
    }
    
    public init(_ target: SCNetworkReachability) {
        self._target = target
        setupCallout()
    }
    
    public init?(address: sockaddr) {
        var addrCopy = address
        guard let result = SCNetworkReachabilityCreateWithAddress(nil, &addrCopy) else { return nil }
        self._target = result
        setupCallout()
    }
    
    // If there's a better way to do this, let me know!
    public init?(localAddress: sockaddr?, remoteAddress: sockaddr?) {
        let result: SCNetworkReachability?
        if var localCopy = localAddress {
            if var remoteCopy = remoteAddress {
                result = SCNetworkReachabilityCreateWithAddressPair(nil, &localCopy, &remoteCopy)
            } else {
                result = SCNetworkReachabilityCreateWithAddressPair(nil, &localCopy, nil)
            }
        } else {
            if var remoteCopy = remoteAddress {
                result = SCNetworkReachabilityCreateWithAddressPair(nil, nil, &remoteCopy)
            } else {
                return nil
            }
        }
        
        guard let target = result else { return }
        self._target = target
        setupCallout()
    }
    
    public init?(nodeName: String) {
        guard let result = SCNetworkReachabilityCreateWithName(nil, nodeName) else { return nil }
        self._target = result
        setupCallout()
    }
    
    open var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(self.target, &flags) else { return nil }
        return flags
    }
}
