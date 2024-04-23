//
//  Analytics.swift
//  DIAnalytics
//
//  Created by liemvu on 06/29/2021.
//  Copyright (c) 2021 liemvu. All rights reserved.
//

public class Analytics {
  private static var __trackingInstance = Tracker();
  
  /// Configure analytics with default configuration. Must be called 1 before logEvent
  public class func configure(apiKey: String, trackingUrl: URL) {
    let config = Configuration(apiKey: apiKey, trackingUrl: trackingUrl)
    __trackingInstance.configure(config)
  }
  
  /// Configure analytics with custom configuration
  public class func configure(config: Configuration) {
    __trackingInstance.configure(config)
  }
  
  ///
  /// Log an event
  /// @param name name of event
  public class func logEvent(_ name:String) {
    __trackingInstance.logEvent(name)
  }
  
  ///
  /// Log an event with parameters
  /// @param name name of event
  /// @param name other event paramerters, only accept primitive types
  public class func logEvent(_ name:String,  parameters:[String: Any]?) {
    __trackingInstance.logEvent(name, parameters: parameters)
  }
  
  ///
  /// Engage a user
  /// @param userId Id of user, define by app. Set nil to clear
  public class func setUser(_ userId: String?) {
    __trackingInstance.setUser(userId)
  }
  
  ///
  /// Engage a user with user information
  /// @param userId Id of user, define by app. Set nil to clear
  /// @param info Other user's information, such as email, name... Only accept primitive types
  public class func setUser(_ userId: String?, info:[String: Any]?) {
    __trackingInstance.setUser(userId, info: info)
  }

  /// Clears all analytics data for this instance from the device 
  public class func resetAnalyticsData() {
    __trackingInstance.resetAnalyticsData()
  }
  
  /// Dispatch events immediately
  public class func dispatchEvents() {
    __trackingInstance.dispatchEvents()
  }
  
  ///
  /// Add Parameters to every logged events.
  /// To remove a previous set parameter, set its value = nil
  public class func addSharedParameters(_ parameters:[String: Any?]) {
    __trackingInstance.addSharedParameters(parameters)
  }
  
  ///
  /// Debug console log enabled, default: false
  public class func setDebugLogEnabled(_ enabled: Bool) {
    Log.level = enabled ? Log.Level.deubg : Log.Level.warning
  }
  
  class func resetTrackerInstance() {
    __trackingInstance = Tracker()
  }
  
  ///
  /// Enable or disable tracking. Default true
  public class func setEnabled(_ enabled: Bool) {
    __trackingInstance.setEnabled(enabled)
  }

  public static let version = "1.0.0"
}
