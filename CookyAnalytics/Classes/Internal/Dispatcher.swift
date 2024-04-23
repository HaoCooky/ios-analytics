//
//  Dispatcher.swift
//  DIAnalytics
//
//  Created by William on 7/6/21.
//

import Foundation

///
/// Class này có nhiệm vụ:
/// -  Submit event
class Dispatcher {
  let apiKey: String
  let trackingUrl: URL
  let timeoutInterval:TimeInterval
  private var timer: DispatchSourceTimer?
  private weak var delegate: DispatcherDelegate?
  private var uploading = false
  private var queue: DispatchQueue
  
  init(_ config: Configuration, delegate: DispatcherDelegate, queue: DispatchQueue) {
    apiKey = config.apiKey
    trackingUrl = config.trackingUrl
    timeoutInterval = config.submitTimeoutInterval
    self.delegate = delegate
    self.queue = queue
    
    // schedule timer
    let timer = DispatchSource.makeTimerSource(queue: queue)
    timer.schedule(deadline: .now() + config.submitInterval, repeating: config.submitInterval)
    timer.setEventHandler { [weak self] in
      self?.onTick()
    }
    
    timer.resume()
    self.timer = timer
    Log.d("timer started with interval: \(config.submitInterval)")
  }
  
  deinit {
    if timer != nil {
      timer!.setEventHandler {}
      timer!.cancel()
      timer = nil
    }
  }
  
  func onTick() {
    guard uploading == false,
          let data = delegate?.eventsToSubmit(dispatcher: self) else {
      return
    }
    
    uploading = true
    DispatchQueue.global().async { [weak self] in
      self?.submitEvents(data.key, data.events, onSuccess: {
        self?.queue.async {
          self?.uploading = false
          let hasMore = self?.delegate?.on(dispatcher: self!, successWithKey: data.key)
          if hasMore == true {
            self?.onTick()
          }
        }
        
      }, onFailed: { error in
        self?.queue.async {
          self?.uploading = false
          self?.delegate?.on(dispatcher: self!, failed: error, key: data.key)
        }
      })
    }
  }
  
  /// submit event lên server
  /// @return true nếu như submit thành công
  func submitEvents(_ key:
                      String, _ events: [String],
                    onSuccess: @escaping () -> Void,
                    onFailed: @escaping (_ error: Error) -> Void) {
    guard events.count > 0 else {
      onSuccess()
      return
    }
    

    let jsonStr =
      """
      {
        "tracking_api_key":"\(apiKey)",
        "events":[
          \(events.joined(separator: ","))
        ]
      }
      """
    
    let data = jsonStr.data(using: .utf8)
    let session = URLSessionFactory.instance.create()
    var request = URLRequest(url: trackingUrl)
    request.httpMethod = "POST"
    request.httpBody = data
    request.timeoutInterval = timeoutInterval
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = session.dataTask(with: request) { data, response, error in
      if let error = error {
        onFailed(error)
        return
      }
      
      if let data = data,
         let dataStr = String(data: data, encoding: .utf8) {
        Log.i("Submit api resp \(dataStr)")
      }
      
      let resp = response as? HTTPURLResponse
      if (resp?.statusCode ?? 0) <= 399 {
        onSuccess()
      } else {
        let error = DIError.submitError(message: "Server error: \(resp?.statusCode ?? 599)")
        onFailed(error)
      }
    }
    
    task.resume()
  }
  
  func submitEvent(event: [String:Any]) {
    if let data = try? JSONSerialization.data(withJSONObject: event),
       let str = String(data: data, encoding: .utf8) {
      
      submitEvents("_", [str]) {} onFailed: { err in
        Log.e("Submit event error \(err)")
      }
    }
  }
}


protocol DispatcherDelegate : AnyObject {
  func eventsToSubmit(dispatcher: Dispatcher) -> (key: String, events: [String])?
  func on(dispatcher: Dispatcher, successWithKey: String) -> Bool
  func on(dispatcher: Dispatcher, failed: Error, key: String)
}

class URLSessionFactory {
  static var instance = URLSessionFactory()
  
  func create() -> URLSession {
    return URLSession.shared
  }
}
