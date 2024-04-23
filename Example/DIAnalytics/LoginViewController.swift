//
//  LoginViewController.swift
//  DIAnalytics_Example
//
//  Created by William on 7/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//


import UIKit
import DIAnalyticsSDK
import FirebaseAnalytics
class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      let sharedParams = [
        "param_1": "DI",
        "param_2": "Login",
      ]
      
      DIAnalyticsSDK.Analytics.addSharedParameters(sharedParams)
      FirebaseAnalytics.Analytics.setDefaultEventParameters(sharedParams)
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  @IBAction func logEvent(_ sender: Any) {
    let param = [
      "a": "b"
    ]
    DIAnalyticsSDK.Analytics.logEvent("login_screen_event", parameters: param)
    FirebaseAnalytics.Analytics.logEvent("login_screen_event", parameters: param)
  }
  @IBAction func login(_ sender: Any) {
    DIAnalyticsSDK.Analytics.logEvent("tap_btn_login")
    FirebaseAnalytics.Analytics.logEvent("tap_btn_login", parameters: nil)
  }
}

