//
//  Log.swift
//  DIAnalytics
//
//  Created by William on 7/6/21.
//

import Foundation


class Log {
  static var level: Level = Level.warning
  enum Level : Int{
    case deubg = 0
    case info = 1
    case warning = 2
    case error = 3
  }
  
  static func i(_ items: Any..., file: String = #file, line: Int = #line) {
    log(level: .info, file: file, line: line, items: items)
  }
  
  static func d(_ items: Any..., file: String = #file, line: Int = #line) {
    log(level: .deubg, file: file, line: line, items: items)
  }
  
  static func w(_ items: Any..., file: String = #file, line: Int = #line) {
    log(level: .warning, file: file, line: line, items: items)
  }
  
  static func e(_ items: Any..., file: String = #file, line: Int = #line) {
    log(level: .error, file: file, line: line, items: items)
  }
  
  private static func log(level: Level, file: String, line: Int, items: [Any]) {
    guard level.rawValue >= Log.level.rawValue else {
      return
    }
    
    let itemString = items.map { String(describing: $0) }.joined(separator: " ")
    let fileName = file.split(separator: "/").last ?? ""
    print("[\(level)] \(fileName)(\(line)): \(itemString)")
  }
}
