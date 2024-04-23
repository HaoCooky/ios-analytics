//
//  TrackingService.swift
//  DIAnalytics
//
//  Created by William on 7/6/21.
//

import Foundation


///
/// Class xử lý chính của SDK:
///  - Handle thread safe
///  - Forward event vào storage
///  - Schedule việc submit log định thời
///
class Tracker {
  private let queue = DispatchQueue(label: "di_analytics.serial.queue.storage")
  private var storage: Storage!
  private var disptacher: Dispatcher!
  private var config: Configuration!
  private var sessionMgr: SessionManager!
  private var sharedProperties: [String:Any] = [:]
  private var reachability: Reachability!
  private var enabled = true

  
  /// Configure tracker bao gồm
  /// - validate config
  /// - Tạo các components: storage, session manager, log dispatcher, schedulers
  /// - start session mới
  func configure(_ config: Configuration) {
    queue.async {
      if(self.config != nil) {
        Log.w("SDK is already configurated!")
        return
      }
      
      // set config
      config.validate()
      self.config = config
      Log.i("Configure sdk: \(config)")
      
      // reachability
      self.reachability = Reachability()
      self.reachability.monitorReachabilityChanges()
      
      // create storage
      self.storage = Storage(config)
      self.storage.delegate = self
      
      // create dispatcher
      self.disptacher = Dispatcher(config, delegate: self, queue: self.queue)
      
      // init session
      self.sessionMgr = SessionManager(config: config)
      self.sessionMgr.onSessionStarted = {[weak self] (_)  in
        self?.logEvent(DataKey.sessionCreated)
      }
      self.sessionMgr.onSessionEnded = {[weak self] (session)  in
        self?.logEvent(DataKey.sessionEneded, parameters: [
          DataKey.sessionDuration: Int64(session.duration * 1000)
        ])
      }
      self.sessionMgr.touch()
    }
  }
  
  func setEnabled(_ enabled: Bool) {
    queue.async {
      self.enabled = enabled
    }
  }
  
  func addSharedParameters(_ parameters:[String: Any?]) {
    for k in parameters.keys {
      if let v = parameters[k], v != nil {
        sharedProperties[k] = v
      } else {
        sharedProperties.removeValue(forKey: k)
      }
    }
  }
  
  func logEvent(_ name:String,  parameters:[String: Any]? = nil) {
    queue.async {
      if(self.enabled == false) {
        return
      }
      
      if(self.config == nil) {
        Log.w("Please call Analytics.configure() first!")
        return
      }
      
      var event:[String:Any] = [
        "name": name,
        "ts": Utils.getCurrentTimestamp()
      ]
      
      // merege with shared properties
      var params:[String:Any] = [:]
      params.merge(self.sharedProperties, uniquingKeysWith: { (_, last) in last })
      if let parameters = parameters {
        params.merge(parameters, uniquingKeysWith: { (_, last) in last })
      }
      
      event["properties"] = params
      
      // add session
      event["session"] = [
        DataKey.sessionId: self.sessionMgr.get().id,
        DataKey.time: Int64(self.sessionMgr.get().startAt * 1000)
      ]
        
      // app, lib, device, os info
      event["context"] = Utils.getContextInfo(networkStatus: self.reachability.currentStatus)
      
      if let user = self.storage!.user {
        event["user"] = [
          DataKey.userId: user.id,
          DataKey.userInfo : user.info ?? [:]
        ]
      }
      
      Log.d("add event[\(name)]: \(event)")
      if(self.config.queueEnabled) {
        self.storage.addEvent(event)
      } else {
        self.disptacher.submitEvent(event: event)
      }
      
    }
  }
  
  func setUser(_ userId: String?, info:[String: Any]? = nil) {
    queue.async {
      if(self.config == nil) {
        Log.w("Please call Analytics.configure() first!")
        return
      }
      
      Log.d("set user: \(userId ?? "nil") \(String(describing: info))")
      self.storage.setUser(userId, info: info)
    }
  }
  
  func resetAnalyticsData() {
    queue.async {
      if(self.config == nil) {
        Log.w("Please call Analytics.configure() first!")
        return
      }
      
      self.storage.clear()
      self.sessionMgr.reset()
      self.logEvent("remove_events", parameters: [
        "queue_full": false
      ])
    }
  }
  
  func dispatchEvents() {
    queue.async {
      if(self.config == nil) {
        Log.w("Please call Analytics.configure() first!")
        return
      }
      
      self.disptacher.onTick()
    }
  }
}

extension Tracker : DispatcherDelegate {
  func eventsToSubmit(dispatcher: Dispatcher) -> (key: String, events: [String])? {
    if let status = reachability.currentStatus {
      switch status {
      case .online(let type):
        
        // check cờ submit trên wifi hay ko
        if config.submitLogOnWifiOnly == false || type == ReachabilityType.wiFi {
          return storage.getEventsToSubmit()
        } else {
          Log.i("Skip submit on data network")
        }
        
        break
      default:
        break
      }
    }
    
    Log.i("No network skip submit")
    
    return nil
  }
  
  func on(dispatcher: Dispatcher, successWithKey key: String) -> Bool{
    self.storage.removeSubmittedEvents(path: key)
    return self.storage.queueCount > 0
  }
  
  func on(dispatcher: Dispatcher, failed: Error, key: String) {
    Log.e("Submit error \(failed.localizedDescription)")
  }
}

extension Tracker : StorageDelegate {
  func storage(_ storage: Storage, onEventsRemove count: Int) {
    logEvent("remove_events", parameters: [
      "count": count,
      "queue_full": true
    ])
  }
}
