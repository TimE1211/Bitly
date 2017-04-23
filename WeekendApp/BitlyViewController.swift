//
//  BitlyViewController.swift
//  WeekendApp
//
//  Created by Timothy Hang on 4/22/17.
//  Copyright © 2017 Timothy Hang. All rights reserved.
//


import UIKit
import SwiftyJSON
import RealmSwift

class BitlyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{
  var apiController: APIController!
  var links: Results<Link>!
  var realm: Realm!
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    apiController = APIController(delegate: self)
    
//    apiController.shorten(longURL: "www.google.com")
    
    realm = try! Realm()
    links = realm.objects(Link.self)
  }
  
//  override func viewDidAppear(_ animated: Bool)
//  {
//    
//  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return links.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BitlyCell", for: indexPath) as! BitlyCell
    
    let aLink = links[indexPath.row]
    
    cell.urlTextField.text = aLink.longURL
    cell.newURLLabel.text = aLink.shortURL
    
    if aLink.longURL == ""
    {
      cell.urlTextField.becomeFirstResponder()
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 60
  }
  
  // MARK: - Table view delegate
  
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//  {
//    tableView.deselectRow(at: indexPath, animated: true)
//    
//    if let selectedCell = tableView.cellForRow(at: indexPath)
//    {
//      let selectedLink = links[indexPath.row]
//      UIPasteboard.addItems(selectedLink.shortURL)
//    }
//  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
  {
    if editingStyle == .delete
    {
      try! realm.write {
        let linkToDelete = links[indexPath.row]
        self.realm.delete(linkToDelete)
      }
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    if let contentView = textField.superview,
      let cell = contentView.superview as? BitlyCell,
      let indexPath = tableView.indexPath(for: cell)
    {
      let selectedLink = links[indexPath.row]
      if let text = textField.text,
        text != ""
      {
        if textField == cell.urlTextField
        {
          try! realm.write {
            selectedLink.longURL = text
          }
          cell.urlTextField.resignFirstResponder()
          apiController.shorten(longURL: selectedLink.longURL)
          tableView.reloadData()
        }
      }
    }
    return false
  }
  @IBAction func addNewLink(sender: UIBarButtonItem)
  {
    let aLink = Link(longURL: "", shortURL: "")
    try! realm.write {
      realm.add(aLink)
    }
    setEditing(true, animated: true)
    tableView.reloadData()
  }
}

extension BitlyViewController: APIControllerDelegate
{
  func apiController(didReceive json: JSON)
  {
    let aLink = Link(json: json)
    try! realm.write {
      realm.add(aLink)
    }
    
    print(aLink.shortURL)
    print(aLink.longURL)
  }
}

