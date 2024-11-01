//
//  Reachability.swift
//  workAtHome
//
//  Created by 김평구 on 10/15/24.
//

import Foundation
import SystemConfiguration

// MARK: - 네트워크 확인
class Reachability {
    
    class func networkConnected() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isRachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let neddsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0

        
        return (isRachable && !neddsConnection)
    }
    
}
