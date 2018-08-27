//
//  ViewController.swift
//  ShoppingList
//
//  Created by Jamie on 2018-08-22.
//  Copyright © 2018 Jamie. All rights reserved.
//

import UIKit
import Realm

class ViewController:
  UIViewController,
  UITableViewDelegate,
  UITableViewDataSource,
  AddObjectViewControllerDelgate
{
  var myAddVC: AddObjectViewController?
  
  @IBOutlet weak var editShoppingListShowingButton: UIButton!
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var itemUITableView: UITableView!
  @IBOutlet weak var editUIButton: UIButton!
  
  @IBOutlet weak var clearUIButton: UIButton!
  
  @IBOutlet weak var titleLabelViewBox: UIView!
  
  var appData = AppData()
  //  var appData = AppData()
  var realmArray = [ListItem]()
  // need array property, mutable.
  

  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    titleLabelViewBox.layer.cornerRadius = 7.5 // handles cornder radius of top bar (edit, title, clear are located)
    appData.sortEntireList() // sorts list at view load
    topMenuButtons() // enables or disables buttons depending on if currentItemsArray returns if it's 'full' or 'empty'
    self.itemUITableView.allowsMultipleSelectionDuringEditing = false;
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    let shoppingList = ShoppingList()
//    let realm = RLMRealm.default()
//    realm.beginWriteTransaction()
//    realm.delete(shoppingList)
//    do                         ---------------doesn't work. Was trying to delete on view did load for testing (see below) but can't find the item to delete in Realm
//    {
//        try realm.commitWriteTransactionWithoutNotifying([])
//    }
//    catch let error
//    {
//        print("\(error)")
//    }
//
//    saveCurrentList(listName: "Test", currentArray: appData.currentItemsArray) --------during testing Realm sees this as editing the name without writing, crash
  }
  
  //MARK: - Keyboard
  
  @objc func keyboardWillShow (){
    tappedAdditem(keyboardUp: true)
  }
  @objc func keyboardWillHide (){
    tappedAdditem(keyboardUp: false)
  }
  
  func tappedAdditem(keyboardUp:Bool){
    //bottomConstraint
    let newConstant :CGFloat
    if keyboardUp == true {
      //if bottomConstraint.constant == -275{ //orig 250
      // IF THIS CHANGES AT ALL, YOU NEED TO CHANGE SPOT IN STORYBOARD AS WELL, containerview "bottom constraint" MUST match this number
      newConstant = 0
      
    }else{
      newConstant = -275 //orig 250; changed so that no 'empty' space below textfield
      // IF THIS CHANGES AT ALL, YOU NEED TO CHANGE SPOT IN STORYBOARD AS WELL, containerview "bottom constraint" MUST match this number
      
    }
    DispatchQueue.main.async {[unowned self] in
      UIView.animate(withDuration: 0.2, animations: {
        self.bottomConstraint.constant = newConstant
        self.view.layoutIfNeeded()
      })
    }
    
  }
  
  //  MARK: - TableView Setup
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return appData.currentItemsArray.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
    let thisItem = appData.currentItemsArray[indexPath.row]
    
    //    SPOT/FUNC FOR MARKING SOMETHING DONE
    // if lightgrey, then 'done/marked' have a black bar 'seeable/alpha=1' on top
    // if black, then 'not done' have black bar alpha = 0
    cell.amountUILabel.text = "\(thisItem.amount)"
    cell.itemUILabel.text = thisItem.title
    
    
    
    
    // start -- mark off bar -- properties
    cell.markOffBar.backgroundColor = UIColor .clear
    //    let myString = thisItem.title
    //    let size: CGSize = myString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)])
    //    cell.markOffBar.frame.size.width = size.width
    
    if (thisItem.isCompleted) // active
    {
      cell.itemUILabel.textColor = UIColor .lightGray
      cell.amountUILabel.textColor = UIColor .lightGray
      cell.markOffBar.backgroundColor = UIColor .red // mark off bar colour black only when isCompleted==True
      cell.markOffBar.alpha = 0.5;
    }
    else
    {
      cell.itemUILabel.textColor = UIColor .black
      cell.amountUILabel.textColor = UIColor .black
      cell.markOffBar.backgroundColor = UIColor .clear // mark off bar colour black only when isCompleted==False
    }
    return cell
  }
  
  //  MARK: - Table View Row Selected
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath)
  {
    let realm = RLMRealm.default()
    realm.beginWriteTransaction()
    appData.currentItemsArray[indexPath.row].isCompleted = !appData.currentItemsArray[indexPath.row].isCompleted
    do
    {
      try realm.commitWriteTransactionWithoutNotifying([])
    }
    catch let error
    {
      print("\(error)")
    }
    appData.sortEntireList()
    itemUITableView .reloadData()
    
  }
  
  
  //  MARK: - Add, Edit, Delete, Move Item and Clear All
  
  func itemAdded(sentItem: ListItem)
  {
    appData.currentItemsArray.append(sentItem)
    writeNewItem(addedItem: sentItem)
    appData.sortEntireList()
    itemUITableView.reloadData()
    topMenuButtons() // enables or disables buttons depending on if currentItemsArray returns if it's 'full' or 'empty'
  }
  
  
  //-----
  //  @IBAction func showEditing(_ sender: UIButton)
  //  {
  //    if(self.itemUITableView.isEditing == true){
  //
  //        appData.currentItemsArray.append(sentItem)
  //        writeNewItem(addedItem: sentItem)
  //        itemUITableView.reloadData()
  //    }
  //}
  
  
  @IBAction func showEditing(_ sender: UIButton)
  {
    if(self.itemUITableView.isEditing == true)
    {
      self.itemUITableView.setEditing(false, animated: true)
      self.editUIButton.setTitle("Edit", for: .normal)
    }
    else
    {
      self.itemUITableView.setEditing(true, animated: true)
      self.editUIButton.setTitle("Done", for: .normal)
    }
    topMenuButtons() // enables or disables buttons depending on if currentItemsArray returns if it's 'full' or 'empty'

  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.delete) {
      //       handle delete (by removing the data from your array and updating the tableview)
      appData.removeListItem(itemNumber: indexPath.row)
      tableView.deleteRows(at: [indexPath],
                           with: UITableViewRowAnimation.top)
    }
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let movedObject = appData.currentItemsArray[sourceIndexPath.row]
    appData.currentItemsArray.remove(at: sourceIndexPath.row)
    appData.currentItemsArray.insert(movedObject, at: destinationIndexPath.row)
  }
  
  
  @IBAction func clearItemList(_ sender: UIButton) {
    appData.currentItemsArray.removeAll()
    topMenuButtons() // enables or disables buttons depending on if currentItemsArray returns if it's 'full' or 'empty'
    let realm = RLMRealm.default()
    realm.beginWriteTransaction()
    realm.deleteAllObjects()
    do
    {
      try realm.commitWriteTransactionWithoutNotifying([])
    }
    catch let error
    {
      print("\(error)")
    }
    
    itemUITableView.reloadData()
  }
  
  //  MARK: - Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if (segue.identifier == "toAddObjectViewController")
    {
      myAddVC = (segue.destination as! AddObjectViewController)
      myAddVC!.delegate = self
    }
  }
  
  
  @IBAction func chooseOrCreateNewListButton(_ sender: UIButton) {
    
    let newConstant :CGFloat
    
    if bottomConstraint.constant == -275 {
      //if bottomConstraint.constant == -275{ //orig 250
      // IF THIS CHANGES AT ALL, YOU NEED TO CHANGE SPOT IN STORYBOARD AS WELL, containerview "bottom constraint" MUST match this number
      newConstant = 0
      
    }else{
      newConstant = -275 //orig 250; changed so that no 'empty' space below textfield
      // IF THIS CHANGES AT ALL, YOU NEED TO CHANGE SPOT IN STORYBOARD AS WELL, containerview "bottom constraint" MUST match this number
      
    }
    DispatchQueue.main.async {[unowned self] in
      UIView.animate(withDuration: 0.2, animations: {
        self.bottomConstraint.constant = newConstant
        self.view.layoutIfNeeded()
      })
    }
  }
  
  
  
  
  
  //  MARK: - Realm Functions
  
  func writeNewItem(addedItem: ListItem) //need to bring in ListItem object
  {
    let newItem = ListItem ()
    newItem.title = addedItem.title
    newItem.amount = addedItem.amount
    newItem.priority = addedItem.priority
    let realm = RLMRealm.default()
    realm.beginWriteTransaction()
    realm.add(newItem)
    do
    {
      try realm.commitWriteTransactionWithoutNotifying([])
    }
    catch let error
    {
      print("\(error)")
    }
  }
  
  func topMenuButtons() {
    // enables or disables buttons depending on if currentItemsArray returns if it's 'full' or 'empty'
    if appData.currentItemsArray.isEmpty {
      editUIButton.isEnabled = false
      editUIButton.alpha = 0.5
      clearUIButton.isEnabled = false
      clearUIButton.alpha = 0.5
    } else {
      editUIButton.isEnabled = true
      editUIButton.alpha = 1.0
      clearUIButton.isEnabled = true
      clearUIButton.alpha = 1.0
    }
  }
    
    func saveCurrentList (listName: (String), currentArray: (Array<ListItem>)){
        
        //this works
        let shoppingList:ShoppingList = ShoppingList()
        shoppingList.name = listName
        for object in currentArray{
            shoppingList.rlmArray.add(object)
        let realm = RLMRealm.default()
        realm.beginWriteTransaction()
        realm.add(shoppingList)
        do
        {
            try realm.commitWriteTransactionWithoutNotifying([])
        }
        catch let error
        {
            print("\(error)")
        }
    }
    }
    
    func saveNewList (listName: (String)){
        
    }

}





