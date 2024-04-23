//
//  FireReader.swift
//  DIAnalytics
//
//  Created by William on 7/7/21.
//

import Foundation

class JsonFileReader {
  let path: String
  var fileHandle: FileHandle?
  let fileMgr = FileManager.default
  
  init(_ path: String) {
    self.path = path
  }
  
  func open() {
    if fileMgr.fileExists(atPath: path) {
      fileHandle = FileHandle(forReadingAtPath: path)
    }
  }
  func readAll() -> Data? {
    return fileHandle?.readDataToEndOfFile()
  }
  
  func  close() {
    fileHandle?.closeFile()
  }
  
  class func readAll(from path: String) throws -> Data? {
    let reader = JsonFileReader(path)
    reader.open()
    let data = reader.readAll()
    reader.close()
    return data
  }
  
 class func readUser(from path: String) throws -> User?  {
    guard let data = try readAll(from: path) else {
      return nil
    }

    let json = try JSONSerialization.jsonObject(with: data) as! [String:Any?]
    let id = json["id"] as! String
    let info = json["info"] as? [String:Any]
    return User(id: id, info: info)
 }
  
  class func readLines(from path: String) throws -> [String]  {
    guard let data = try readAll(from: path) else {
       return []
     }
    
    let str = String(data: data, encoding: .utf8)
    return str?.components(separatedBy: "\n") ?? []
  }
}
 
