//
//  APIController.swift
//  WeekendApp
//
//  Created by Timothy Hang on 4/22/17.
//  Copyright © 2017 Timothy Hang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol APIControllerDelegate
{
  func apiController(didReceive json: JSON)
}

class APIController
{
  var delegate: APIControllerDelegate
  let baseAPIUrlString = "https://api-ssl.bitly.com"
  
  init(delegate: APIControllerDelegate)
  {
    self.delegate = delegate
  }
  
  func shorten(longURL: String)
  {
    let urlString = baseAPIUrlString + "/v3/shorten"
    
    let parameters: [String: Any] = [
      "longUrl": longURL,
      "access_token": "b9e8c4608f75c4930117aaab7b0c3e24ecb50d26"
    ]
    
    let request = Alamofire.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default)
    
    request.responseJSON { response in
      debugPrint(response)
      
      if let value = response.value {
        let json = JSON(value)
        self.delegate.apiController(didReceive: json)
      } else if let error = response.error {
        print(error)
      }
    }
  }
}
