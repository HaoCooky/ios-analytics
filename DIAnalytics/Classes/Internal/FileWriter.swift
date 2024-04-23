//
//  FileWriter.swift
//  DIAnalytics
//
//  Created by William on 7/7/21.
//

import Foundation

class JsonFileWriter : FileWriter {
 class func writeUser(_ user: User?, to path: String) throws {
   guard let user = user else {
     try? FileManager.default.removeItem(atPath: path)
     return
   }
   
     let writer = JsonFileWriter(path)
     try writer.openFile(append: false)
   
     let data:[String:Any?] = [
       "id": user.id,
       "info": user.info
     ];
   
     try writer.write(data)
     try writer.close()
 }
 
 func write(_ data: [String : Any?]) throws {
   var bytes: Data!
   do {
     try bytes = JSONSerialization.data(withJSONObject: data)
   } catch {
     throw DIError.serializeEvent(message: "Serialize data: \(data) failed: \(error)")
   }
   
   if size > 0 {
     try writeData("\n".data(using: .utf8)!)
   }
   
   try writeData(bytes)
 }
}

class FileWriter {
 let path: String
 private var fileHandle:FileHandle?
 private let fileMgr = FileManager.default
 private(set) var size: UInt64 = 0

 init(_ path: String) {
   self.path = path
 }
 
 func openFile(append: Bool = true) throws  {
   let url = URL(fileURLWithPath: path)
   
    // create file if needed
   if !fileMgr.fileExists(atPath: path) {
     Log.i("create file: \(url)")
     fileMgr.createFile(atPath: path, contents: nil, attributes: nil)
   }
   
   Log.i("open file: \(path)")
   
   fileHandle = FileHandle(forWritingAtPath: path)
   guard let fileHandle = fileHandle else {
     throw DIError.writeFile(message: "Can't open file handle")
   }
   
   if append {
    tryBlock {
      self.size = fileHandle.seekToEndOfFile()
    }
     Log.i("size: \(size)")
   } else {
    tryBlock {
     fileHandle.truncateFile(atOffset: 0)
    }
     size = 0
   }
   
 }
 
 func writeData(_ bytes: Data) throws {
   guard let fileHandle = fileHandle else {
     throw DIError.writeFile(message: "file not opened")
   }
   
  // buffer write??
  size += UInt64(bytes.count)
  tryBlock {
    fileHandle.write(bytes)
  }
 }
 
 func close() throws {
   guard let fileHandle = fileHandle else {
     throw DIError.writeFile(message: "file not opened")
   }
   
  tryBlock {
    fileHandle.closeFile()
  }
 }
}
