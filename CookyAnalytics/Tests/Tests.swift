import XCTest
@testable import CookyAnalytics

class DITests: XCTestCase {
  var urlSessionFactory: MockURLSessionFactory!
  var apiKey = "c2c09332-14a1-4eb1-8964-2d85b2a561c8"
  var trackingUrl = URL(string: "https://dev.datainsider.co/api/tracking/events/track")!
  
  override func setUp() {
    super.setUp()
    Analytics.configure(apiKey: apiKey, trackingUrl: trackingUrl)
    urlSessionFactory = MockURLSessionFactory()
    URLSessionFactory.instance = urlSessionFactory
  }
    
  override func tearDown() {
    Analytics.resetTrackerInstance()
    URLSessionFactory.instance = URLSessionFactory()
  }
    
  func testSubmit() {
    let exp = expectation(description: "Wait for data submit")
    var json: [String: Any]?
    urlSessionFactory.session = MockURLSession({[weak self] req in
      XCTAssertEqual(self?.trackingUrl, req.url)
      json = try! JSONSerialization.jsonObject(with: req.httpBody!) as! [String: Any]
      
      let resp = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
      DispatchQueue.global().async {
        exp.fulfill()
      }
      return (data: nil, response: resp, error: nil)
    })
    
    let sharedParams:[String : AnyHashable] = [
      "shared_param": "abc"
    ]
    let eventParams:[String : AnyHashable] = [
      "int": 1,
      "string": "str",
      "double": 1.1,
      "array": ["str1", "str2"],
      "map": [
        "param1": 1,
        "param2": 2
      ]
    ]
    Analytics.addSharedParameters(sharedParams)
    Analytics.logEvent("test_event", parameters: eventParams)
    
    Analytics.dispatchEvents()
    let result = XCTWaiter.wait(for: [exp], timeout: 5.0)
    if result == XCTWaiter.Result.timedOut {
      XCTFail("Timeout")
    } else {
      let apiKey = json!["tracking_api_key"] as! String
      XCTAssertEqual(apiKey, apiKey)
      
      let events = json!["events"] as! [[String: Any]]
      var found = false
      for event in events {
        let eventName = event["name"] as! String
        let properties = event["properties"] as! [String: AnyHashable]
        
        if eventName == "test_event" {
          found = true
          sharedParams.forEach { key,value in
            XCTAssertTrue(properties[key] == value)
          }
          eventParams.forEach { key,value in
            XCTAssertTrue(properties[key] == value)
          }
        }
      }
      
      XCTAssertTrue(found)
    }
  }
    
  func testPerformance() {
      // This is an example of a performance test case.
      self.measure() {
        let eventParams:[String : AnyHashable] = [
          "int": 1,
          "string": "str",
          "double": 1.1,
          "array": ["str1", "str2"],
          "map": [
            "param1": 1,
            "param2": 2
          ]
        ]
        Analytics.logEvent("test_performance", parameters: eventParams)
      }
  }
    
}


class MockURLSessionFactory : URLSessionFactory {
  var session: URLSession?
  
  override func create() -> URLSession {
    return session ?? super.create()
  }
}

typealias MockRequestHandler = (_ request: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?)
class MockURLSession : URLSession {
  var callTime = 0
  var handler:MockRequestHandler!
  
  init(_ handler: @escaping  MockRequestHandler) {
    self.handler = handler
  }
  
  override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    callTime += 1
    let res = handler(request)
    completionHandler(res.data, res.response, res.error)
    return MockURLSessionDataTask()
  }
}

class MockURLSessionDataTask : URLSessionDataTask {
  override func resume() {}
}
