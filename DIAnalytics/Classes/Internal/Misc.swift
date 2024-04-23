//
//  Misc.swift
//  DIAnalytics
//
//  Created by William on 7/7/21.
//

import Foundation
import CoreTelephony

struct User {
  let id: String;
  let info: [String: Any]?
}

struct Session {
  let id: String;
  let startAt: TimeInterval
  var expireAt: TimeInterval?
  
  var isExpired: Bool {
    return expireAt != nil && expireAt! < Date().timeIntervalSince1970
  }
  
  var duration: TimeInterval {
    if isExpired {
      return expireAt! - startAt
    } else {
      return Date().timeIntervalSince1970 - startAt
    }
    
  }
}


enum DIError: Error {
  case writeFile(message: String)
  case serializeEvent(message: String)
  case submitError(message: String)
}

class Utils {
  static func getLogDir() -> String {
    let cachesDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    let logDir = "\(cachesDir)/di_analytics"
    try? FileManager.default.createDirectory(atPath: logDir, withIntermediateDirectories:true, attributes: nil)
    
    return logDir
  }
  
  static func getDeviceModel() -> String {
      if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
        return simulatorModelIdentifier
      }
    
      var sysinfo = utsname()
      uname(&sysinfo) // ignore return value
    
      return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
  }
  
  private static var _staticContextInfo: [String:Any]!
  static func getContextInfo(networkStatus: ReachabilityStatus?) -> [String:Any] {
    let device = UIDevice.current
    
    // some info does not change
    if _staticContextInfo == nil {
      _staticContextInfo = [:]
      
      // app info
      if let bundleInfo = Bundle.main.infoDictionary {
        _staticContextInfo[DataKey.appName] = bundleInfo["CFBundleDisplayName"] ?? ""
        _staticContextInfo[DataKey.appVersion] = bundleInfo["CFBundleShortVersionString"] ?? ""
        _staticContextInfo[DataKey.appBuild] = bundleInfo["CFBundleVersion"] ?? ""
        _staticContextInfo[DataKey.appId] = Bundle.main.bundleIdentifier ?? ""
      }
      
      // library info
      _staticContextInfo[DataKey.libName] = "DI_iOS_Swift"
      _staticContextInfo[DataKey.libVersion] = Analytics.version
      
      // device info
      _staticContextInfo[DataKey.platform] = "iOS"
      _staticContextInfo[DataKey.deviceManufacturer] = "Apple"
      _staticContextInfo[DataKey.deviceModel] = getDeviceModel()
      _staticContextInfo[DataKey.deviceId] = device.identifierForVendor?.uuidString ?? ""

      // os info
      _staticContextInfo[DataKey.os] = device.systemName
      _staticContextInfo[DataKey.osVersion] = device.systemVersion
      
      // mobile network code
      let mob = CTTelephonyNetworkInfo()
      if let r = mob.subscriberCellularProvider,
         let mcc = r.mobileCountryCode,
         let mnc = r.mobileNetworkCode {
        _staticContextInfo[DataKey.mobileNetworkCode] = "\(mcc)\(mnc)"
      }
    }
    
    var res: [String: Any] = [:]
    res.merge(_staticContextInfo) { f,_ in f }
    
    // network
    if let networkStatus = networkStatus {
      switch networkStatus {
      case .offline:
        res[DataKey.networkStatus] = "offline"
        break
      case .online(let type):
        res[DataKey.networkStatus] = type.description
        break
      default:
        res[DataKey.networkStatus] = "unknown"
      }
    }

    return res
  }
  
  static func getCurrentTimestamp() -> Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
  }
}

class DataKey {
  static let sessionCreated = "di_session_created"
  static let sessionEneded = "di_session_end"
  static let sessionDuration = "di_session_dur"
  static let sessionId = "di_session_id"
  static let libName = "di_lib_name"
  static let libVersion = "di_lib_version"
  static let os = "di_os"
  static let osVersion = "di_os_version"
  static let appName = "di_app_name"
  static let appVersion = "di_app_version"
  static let appBuild = "di_app_build"
  static let appId = "di_app_id"
  static let platform = "di_platform"
  static let deviceModel = "di_device_model"
  static let deviceManufacturer = "di_device_manufacturer"
  static let deviceId = "di_device_id"
  static let userId = "di_user_id"
  static let userInfo = "di_user_info"
  static let trackingId = "di_tracking_id"
  static let time = "di_time"
  static let networkStatus = "di_network_status"
  static let mobileNetworkCode = "di_mobile_network_code"
  
}
