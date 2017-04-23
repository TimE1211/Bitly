//
//  Link.swift
//  WeekendApp
//
//  Created by Timothy Hang on 4/22/17.
//  Copyright © 2017 Timothy Hang. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Link: Object
{
  dynamic var toDoId = UUID().uuidString
  
  dynamic var longURL = ""
  dynamic var shortURL = ""

  override class func primaryKey() -> String?
  {
    return "toDoId"
  }
  
  override class func indexedProperties() -> [String]
  {
    return ["isDone"]
  }
  
  convenience init(json: JSON)
  {
    self.init()
    (1...40).forEach { _ in print("\n") }
    
    print(json.dictionaryObject!)
    
    self.longURL = json["data"]["long_url"].stringValue
    self.shortURL = json["data"]["url"].stringValue
  }
  
  convenience init(longURL: String, shortURL: String)
  {
    self.init()
    self.longURL = longURL
    self.shortURL = shortURL
  }
}






