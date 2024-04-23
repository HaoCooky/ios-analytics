//
//  SessionManager.swift
//  DIAnalytics
//
//  Created by William on 7/7/21.
//

import Foundation
class SessionManager {
  private var session: Session?
  let nc = NotificationCenter.default
  let config: Configuration
  var onSessionStarted: ((Session) -> Void)?
  var onSessionEnded: ((Session) -> Void)?
  
  init(config: Configuration) {
    self.config = config
    listenAppState()
  }
  
  deinit {
    nc.removeObserver(self)
  }
  
  func listenAppState() {
    if #available(iOS 13.0, *) {
      nc.addObserver(self,
                     selector: #selector(willResignActive),
                     name: UIScene.willDeactivateNotification,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(willEnterForeground),
                     name: UIScene.willEnterForegroundNotification,
                     object: nil)
    } else {
      nc.addObserver(self,
                     selector: #selector(willResignActive),
                     name: UIApplication.willResignActiveNotification,
                     object: nil)
      nc.addObserver(self,
                     selector: #selector(willEnterForeground),
                     name: UIApplication.willEnterForegroundNotification,
                     object: nil)
    }
  }
  
  @objc func willResignActive(_ notification: Notification) {
    self.touch()
    session?.expireAt = Date().timeIntervalSince1970 + config.sessionExpireTime
  }
  
  @objc func willEnterForeground(_ notification: Notification) {
    self.touch()
    session?.expireAt = nil
  }
  
  func touch() {
    if session == nil {
      Log.i("Create new session..")
      _ = get()
    } else if(session!.isExpired) {
      Log.i("Session expired! create new session..")
      if onSessionEnded != nil {
        onSessionEnded!(session!)
      }
      session = nil
      _ = get()
    }
  }
  
  func get() -> Session {
    if session == nil {
      session = Session(
        id: UUID().uuidString,
        startAt: Date().timeIntervalSince1970,
        expireAt: nil
      )
      
      if onSessionStarted != nil {
        onSessionStarted!(session!)
      }
    }
    
    return session!
  }
  
  func reset() {
    if session != nil {
      session = nil
      _ = get()
    }
  }
}
