# DIAnalyticsSDK
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 9.0+

## Installation

DIAnalyticsSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DIAnalyticsSDK', :git => "git@gitlab.com:datainsider/analytics/datainsider-analytics-ios.git", :tag => 'x.x.x'
# replace x.x.x with newest version, ie: 0.1.2 
```

## Usage
Configure SDK before any usage
```Swift
import DIAnalyticsSDK

Analytics.configure(apiKey: "API-KEY", trackingUrl: TRACKING_URL)
```

<details>
<summary>Other configurations</summary>

```Swift
var config = Configuration(apiKey: apiKey, trackingUrl: trackingUrl)

/// Events will be submit by batch every @submitInterval seconds. Default: 1min
config.submitInterval = 1 * 60

/// Timeout interval for submit request. Default 2mins
config.submitTimeoutInterval = 2 * 60

/// Max size in byte per log file. Default 1MB
config.maxSizeOfLogFile = 1 * 1024 * 1024

/// Max number of log file stored. Default 10
config.maxNumberOfLogFile = 10

/// if set false, log will be submit immediately. Default true
config.queueEnabled = true

/// If there are no interactions in @sessionExpireTime, new session will be generated. Default 10mins
config.sessionExpireTime = 10 * 60

/// if true only submit log when connected to a wifi network
config.submitLogOnWifiOnly = false

Analytics.configure(config: config)

```

</details>

Log an event

```Swift
Analytics.logEvent("in_app_purchase", parameters: [
    "pid": "p001"
])
```

Set user info
```Swift
Analytics.setUser("uid_1", info: [
    "name": "John"
])
```

Add shared properties for all events
```Swift
//set value = nil to remove shared parameters
Analytics.addSharedParameters([
    "utm_source": "google",
])
```

## Author

liemvu, liemvouy@gmail.com

## License

DIAnalyticsSDK is available under the Creative Common license. See the LICENSE file for more info.
