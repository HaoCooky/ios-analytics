//
//  LogFileRotator.swift
//  DIAnalytics
//
//  Created by William on 7/7/21.
//

import Foundation

class EventQueue {
  let fileMgr = FileManager.default
  let config: Configuration
  private var current: JsonFileWriter?
  let logDir: String
  var queue:[String] = []
  weak var delegate: EventQueueDelegate?
  
  init(_ config: Configuration, logDir: String) {
    self.config = config
    self.logDir = logDir
    loadQueue()
  }
  
  /// Quét thư mục lưu log file đẩy vào queue theo thứ tự cũ nhất trước
  /// Queue chứa những file chờ upload
  func loadQueue() {
    do {
      let files = try fileMgr.contentsOfDirectory(atPath: queueLogPath)
      // sort cái queue = name
      queue.append(contentsOf: files.sorted().map {
        "\(queueLogPath)/\($0)"
      })
      try truncateQueueIfNeeded()

      Log.i("Queue size: \(queue.count)")
    } catch  {
      Log.e("Load queue error \(error)")
    }
  }
  
  /// Cung cấp json writer  cho caller để có thể add events vào file tạm
  func doWrite(block: (_ writer: JsonFileWriter)  throws -> Void) throws{
      if current == nil {
        current = JsonFileWriter(currentLogPath)
        try current!.openFile()
      }
    
    try block(current!)
    
    // Rotate log file nếu bị đầy
    if(current!.size >= config.maxSizeOfLogFile) {
      try rotate()
    }
  }
  
  /// Chuyển file trong file log tạm vào queue chờ upload
  /// Rotate log file nếu bị đầy hoặc force phải rotate
  func rotate() throws {
    guard let eventWriter = current else {
      return
    }
    
    Log.i("Rotate file log \(eventWriter.size)")
    // prepare new file in queue
    let now = Date.timeIntervalSinceReferenceDate
    let filePath = String(format: "\(queueLogPath)/%.0f.log", now * 1000)
    
    if fileMgr.fileExists(atPath: filePath) {
      try? fileMgr.removeItem(atPath: filePath)
    }
    
    // close current file
    try eventWriter.close()
    
    // move it to queue
    try fileMgr.moveItem(atPath: eventWriter.path, toPath: filePath)
    Log.i("Move to queue \(filePath)")
    self.current = nil
    
    queue.append(filePath)
    try truncateQueueIfNeeded()
    Log.i("queue size \(queue.count)")
  }
  
  // clear tất cả queue & xoá file trên đãi
  func clear() {
    try? current?.close()
    current = nil
    try? fileMgr.removeItem(atPath: logDir)
    
    // create lại dir
    let queueDir = "\(logDir)/events/queue";
    try? fileMgr.createDirectory(atPath: queueDir, withIntermediateDirectories:true, attributes: nil)
  }
  
  ///
  /// @return first file from queue and remove it, nếu queue rỗng thì dùng log tạm
  func pop() -> String? {
    guard let first = queue.first else {
      // nếu queue rỗng, dùng file tạm
      if let current = current, current.size > 0 {
        try? current.close()
        self.current = nil
        return currentLogPath
      }
      
      return nil
    }
    
    queue.remove(at: 0)
    return first
  }
 
  // xoá file để đảm bảo < số file trong config
  func truncateQueueIfNeeded() throws {
    // remove from queue if full
    var eventsRemoved = 0
    while isQueueFull()  {
      let path = queue.removeFirst()
      let lines = try? JsonFileReader.readLines(from: path)
      
      eventsRemoved += lines?.count ?? 0
      
      try fileMgr.removeItem(atPath: path)
      Log.i("queue remove \(path)")
    }
    
    if eventsRemoved > 0 {
      delegate?.eventQueue(self, onEventsRemove: eventsRemoved)
    }
  }
  
  func isQueueFull() -> Bool {
    return queue.count > config.maxNumberOfLogFile
  }
  
  // đường dẫn đến thư mục chứa log file chờ upload
  private lazy var queueLogPath: String = {
    let queueDir = "\(logDir)/events/queue";
    try? fileMgr.createDirectory(atPath: queueDir, withIntermediateDirectories:true, attributes: nil)
    return queueDir
  }()
  
  // đường dẫn đến file tạm đang lưu
  private lazy var currentLogPath: String = {
    let eventDir = "\(logDir)/events"
    try? fileMgr.createDirectory(atPath: eventDir, withIntermediateDirectories:true, attributes: nil)
    
    return "\(eventDir)/current.log"
  }()
}
 
protocol EventQueueDelegate : AnyObject {
  func eventQueue(_ eventQueue: EventQueue, onEventsRemove count: Int)
}
