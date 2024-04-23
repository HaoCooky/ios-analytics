//
//  ViewController.swift
//  DIAnalytics
//
//  Created by liemvu on 06/29/2021.
//  Copyright (c) 2021 liemvu. All rights reserved.
//

import UIKit
import DIAnalyticsSDK
import FirebaseAnalytics
class MainViewController: UIViewController {
  private var timer: DispatchSourceTimer?
  @IBOutlet weak var autoLogEventButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    DIAnalyticsSDK.Analytics.setUser("uid_1", info: [
      "name": "John"
    ])
    
    DIAnalyticsSDK.Analytics.addSharedParameters([
      "param_2": nil,
    ])
    
    FirebaseAnalytics.Analytics.setUserID("uid_1")
    FirebaseAnalytics.Analytics.setUserProperty("John", forName: "name")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  deinit {
    timer?.setEventHandler {}
    timer?.cancel()
    timer = nil
    UIApplication.shared.isIdleTimerDisabled = false
  }
  
  @IBAction func logEvent(_ sender: Any) {
    let params = [
      "a param": 1
    ]
    DIAnalyticsSDK.Analytics.logEvent("main_screen_event", parameters: params)
    FirebaseAnalytics.Analytics.logEvent("main_screen_event", parameters: params)
  }
  
  @IBAction func dispatchNow(_ sender: Any) {
    DIAnalyticsSDK.Analytics.dispatchEvents()
  }
  
  @IBAction func logout(_ sender: Any) {
    DIAnalyticsSDK.Analytics.logEvent("tap_btn_logout")
    DIAnalyticsSDK.Analytics.setUser(nil)
    
    FirebaseAnalytics.Analytics.logEvent("tap_btn_logout", parameters: nil)
    FirebaseAnalytics.Analytics.setUserID(nil)
    self.navigationController?.popViewController(animated: true)
  }
  
  
  
  @IBAction func autoLogEvent(_ sender: Any) {
    if timer == nil {
      // start timer
      let timer = DispatchSource.makeTimerSource()
      timer.schedule(deadline: .now() + 1.0, repeating: 1.0)
      timer.setEventHandler { [weak self] in
        self?.onTick()
      }
      
      timer.resume()
      self.timer = timer
      autoLogEventButton.setTitle("Stop auto log events", for: .normal)
      UIApplication.shared.isIdleTimerDisabled = true
    } else {
      // stop timer
      timer!.setEventHandler {}
      timer!.cancel()
      timer = nil
      autoLogEventButton.setTitle("Start auto log events", for: .normal)
      UIApplication.shared.isIdleTimerDisabled = false
    }
  }
  
  func onTick() {
    DIAnalyticsSDK.Analytics.logEvent("auto_event")
    FirebaseAnalytics.Analytics.logEvent("auto_event", parameters: nil)
  }
  
  @IBAction func reset(_ sender: Any) {
    DIAnalyticsSDK.Analytics.resetAnalyticsData()
  }
}

