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
  var linkEditingIndex: Int?
  
//  var links: Results<Link> {
//    let realm = try! Realm()
//    return realm.objects(Link.self)
//  }
  
  var realm: Realm!
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    apiController = APIController(delegate: self)
    
//    apiController.shorten(longURL: "www.google.com")
    
    realm = try! Realm()
    links = realm.objects(Link.self)
    
    tableView.tableFooterView = UIView()
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    let link = links[indexPath.row]
    
    cell.textLabel?.text = link.shortURL
    cell.detailTextLabel?.text = link.longURL
    
    return cell
    
//    let cell = tableView.dequeueReusableCell(withIdentifier: "BitlyCell", for: indexPath) as! BitlyCell
//    
//    let aLink = links[indexPath.row]
//    
//    cell.urlTextField.text = aLink.longURL
//    cell.newURLLabel.text = aLink.shortURL
//    
//    if aLink.longURL == ""
//    {
//      cell.urlTextField.becomeFirstResponder()
//    }
//    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 80
  }
  
  
  
  // MARK: - Table view delegate
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let shortURL = links[indexPath.row].shortURL
    UIPasteboard.general.string = shortURL
    
    let alert = UIAlertController(title: "Copied", message: "Copied to clipboard: " + shortURL, preferredStyle: .alert)
    
    present(alert, animated: true) { 
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
        timer.invalidate()
        alert.dismiss(animated: true, completion: nil)
      }
    }
    
//    if let selectedCell = tableView.cellForRow(at: indexPath) as? BitlyCell
//    {
//      let selectedLink = links[indexPath.row]
//      if selectedLink.shortURL != ""
//      {
//        UIPasteboard.general.string = selectedLink.shortURL
//      }
//      else
//      {
//        selectedCell.urlTextField.becomeFirstResponder()
//      }
//    }
  }
  
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
  
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool
//  {
//    if let contentView = textField.superview,
//      let cell = contentView.superview as? BitlyCell,
//      let indexPath = tableView.indexPath(for: cell)
//    {
//      let selectedLink = links[indexPath.row]
//      if let text = textField.text,
//        text != ""
//      {
//        if textField == cell.urlTextField
//        {
//          try! realm.write {
//            selectedLink.longURL = text
//          }
//          cell.urlTextField.resignFirstResponder()
//          apiController.shorten(longURL: selectedLink.longURL)
//          linkEditingIndex = indexPath.row
//        }
//      }
//    }
//    return false
//  }
  
  @IBAction func addNewLink(sender: UIBarButtonItem)
  {
    let alert = UIAlertController(title: "Shorten Link", message: nil, preferredStyle: .alert)
    
    alert.addTextField { textField in
      textField.placeholder = "http://www.example.com"
      textField.keyboardType = .URL
    }
    
    let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
      guard var text = alert.textFields?.first?.text else { return }
      
      if !text.contains("www.")
      {
        text = "www." + text
      }
      
      if !text.contains("http://")
      {
        text = "http://" + text
      }
      
      if let url = URL(string: text),
        UIApplication.shared.canOpenURL(url) {
        self.apiController.shorten(longURL: text)
      } else {
        let errorAlert = UIAlertController(title: "Error", message: "Invalid URL", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        errorAlert.addAction(action)
        self.present(errorAlert, animated: true, completion: nil)
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(confirmAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
    
    
    
    
    
    
    
//    let aLink = Link(longURL: "", shortURL: "")
//    try! realm.write {
//      realm.add(aLink)
//    }
//    setEditing(true, animated: true)
//    tableView.reloadData()
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
    tableView.reloadData()
  }
}

