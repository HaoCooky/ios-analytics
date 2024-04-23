//
//  Storage.swift
//  DIAnalytics
//
//  Created by William on 7/6/21.
//

import Foundation

///
/// Class này có nhiêm vụ:
/// - Lưu trữ event
/// - Load event đễ submit
/// - Quản lý kích thước lưu trữ
class Storage {
  private(set) var  user: User?
  var eventWriter: JsonFileWriter?
  
  var fileMgr = FileManager.default
  let config: Configuration
  let eventQueue: EventQueue!
  let logDir = Utils.getLogDir()
  weak var delegate: StorageDelegate?
  
  var queueCount: Int {
    return eventQueue.queue.count
  }
  
  init(_ config: Configuration) {
    self.config = config
    self.eventQueue = EventQueue(config, logDir: logDir)
    self.eventQueue.delegate = self
    
    do {
      try user = JsonFileReader.readUser(from: userFilePath)
      
      Log.i("User: \(String(describing: user))")
    } catch  {
      Log.e("Loadding user error \(error)")
    }
  }
  
  func addEvent(_ event: [String: Any]) {
    do {
      try self.eventQueue.doWrite {
        try $0.write(event)
      }
    } catch {
      Log.e(error)
    }
  }
  
  func setUser(_ userId: String?, info:[String: Any]? = nil) {
    if(userId == nil) {
      user = nil
    } else {
      user = User(id: userId!, info: info)
    }
    
    try? JsonFileWriter.writeUser(user, to: userFilePath)
  }
  
  /// Get events có thể submit
  /// @return: path đến file & các hàng của file
  func getEventsToSubmit() -> (key: String, events: [String])? {
    do {
      var resPath:String? = nil
      
      // nếu có file đang uploading thì trả về nó
      if fileMgr.fileExists(atPath: uploadingLogPath){
        Log.i("use pending upload file")
        resPath = uploadingLogPath
      } else {
        // nếu ko lấy từ queue
        let filePath = eventQueue.pop()
        
        if let filePath = filePath,
           fileMgr.fileExists(atPath: filePath) {
          
          // đổi tên file thành uploading để biết là đang upload
          Log.i("move file \(filePath) to \(uploadingLogPath)")
          try fileMgr.moveItem(atPath: filePath, toPath: uploadingLogPath)
          
          resPath = uploadingLogPath
        }
      }
      
      // đọc nó lên
      if let resPath = resPath {
        let lines = try JsonFileReader.readLines(from: uploadingLogPath)
        return (resPath, lines)
      }
    } catch  {
      Log.e("Get event error: \(error)")
      
      //remove error log file
      if fileMgr.fileExists(atPath: uploadingLogPath) {
        Log.i("remove error file \(uploadingLogPath)")
        try? fileMgr.removeItem(atPath: uploadingLogPath)
      }
    }
    
    return nil
  }
  
  /// Uploader gọi func này để remove file đã được submit
  func removeSubmittedEvents(path: String) {
    if fileMgr.fileExists(atPath: path) {
      Log.i("remove file \(path)")
      try? fileMgr.removeItem(atPath: path)
    }
  }
  
  func clear() {
    eventQueue.clear()
    setUser(nil)
  }

  /// path đến file lưu thông tin user
  private lazy var userFilePath: String = {
    return "\(logDir)/user";
  }()
  
  /// path đến file đang được upload
  private lazy var uploadingLogPath: String = {
    let eventDir = "\(logDir)/events"
    try? fileMgr.createDirectory(atPath: eventDir, withIntermediateDirectories:true, attributes: nil)
    
    return "\(eventDir)/uploading.log"
  }()
}

extension Storage: EventQueueDelegate {
  func eventQueue(_ eventQueue: EventQueue, onEventsRemove count: Int) {
    delegate?.storage(self, onEventsRemove: count)
  }
}

protocol StorageDelegate : AnyObject {
  func storage(_ storage: Storage, onEventsRemove count: Int)
}
