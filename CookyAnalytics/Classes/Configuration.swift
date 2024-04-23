//
//  Configuration.swift
//  DIAnalytics
//
//  Created by William on 7/6/21.
//

import Foundation
public class Configuration {
  private static let EVENT_SUBMIT_INTERVAL:TimeInterval = 1 * 60 // 60seconds
  private static let MAX_SIZE_OF_LOG_FILE:Int = 1 * 1024 * 1024 // 1MB
  private static let MAX_NUMBER_OF_LOG_FILE:Int = 10 // 10 files
  private static let SESSION_EXPIRE_TIME:TimeInterval = 10 * 60 // 10mins
  private static let SUBMIT_TIMEOUT_INTERVAL:TimeInterval = 2 * 60 // 2mins
  
  ///
  /// API Key
  public let apiKey: String
  
  ///
  /// Tracking url
  public let trackingUrl: URL
  
  ///
  /// Events will be submit by batch every @submitInterval seconds. Default: 1min
  public var submitInterval:TimeInterval = Configuration.EVENT_SUBMIT_INTERVAL;
  
  ///
  /// Timeout interval for submit api. Default 2mins
  public var submitTimeoutInterval:TimeInterval = SUBMIT_TIMEOUT_INTERVAL
  
  ///
  /// Max size in bytes per log file. Default 1MB
  public var maxSizeOfLogFile: Int = MAX_SIZE_OF_LOG_FILE
  
  ///
  /// Max number of log file stored. Default 10
  public var maxNumberOfLogFile: Int = MAX_NUMBER_OF_LOG_FILE
  
  ///
  /// If there are no interaction after @sessionExpireTime, it will be expired. Default 10mins
  public var sessionExpireTime:TimeInterval = SESSION_EXPIRE_TIME
  
  ///
  /// if true only submit log when connected to a wifi network
  public var submitLogOnWifiOnly:Bool = false
  
  ///
  /// if set false, log will be submit immediately. Default true
  public var queueEnabled:Bool = true
  
  
  public init (apiKey: String, trackingUrl: URL) {
    self.apiKey = apiKey
    self.trackingUrl = trackingUrl
  }
  
  func validate() {
    if(submitInterval <= 0) {
      Log.w("Invalid submitInterval, set to default value!")
      submitInterval = Configuration.EVENT_SUBMIT_INTERVAL
    }
    if(submitTimeoutInterval <= 0) {
      Log.w("Invalid submitTimeoutInterval, set to default value!")
      submitTimeoutInterval = Configuration.SUBMIT_TIMEOUT_INTERVAL
    }
    if(maxSizeOfLogFile < 0 || maxSizeOfLogFile > 512 * 1024 * 1024) {
      Log.w("Invalid maxSizeOfLogFile, set to default value!")
      maxSizeOfLogFile = Configuration.MAX_SIZE_OF_LOG_FILE
    }
    if(maxNumberOfLogFile < 0 || maxNumberOfLogFile > 10000) {
      Log.w("Invalid maxNumberOfLogFile, set to default value!")
      maxNumberOfLogFile = Configuration.MAX_NUMBER_OF_LOG_FILE
    }
    if(sessionExpireTime < 0 || sessionExpireTime > 24 * 60 * 60) {
      Log.w("Invalid sessionExpireTime, set to default value!")
      sessionExpireTime = Configuration.SESSION_EXPIRE_TIME
    }
    
  }
}
