//
//  CategoriesTableViewController.swift
//  Code Blue
//
//  Created by Erik Santana on 4/13/15.
//  Copyright (c) 2015 Erik Santana. All rights reserved.
//

import UIKit
import CoreData

protocol AddEventDelegate
{
    func updateItem(_ item: String)
}

class EventsTableViewController: UITableViewController
{
    var events = [Event]()
    var delegate: AddEventDelegate?
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Use optional binding to confirm the managedObjectContext
        if let moc = self.managedObjectContext
        {
            // Create default table items - (run once)
            if(!UserDefaults.standard.bool(forKey: "eventsLaunched1.0"))
            {
                //Put any code here and it will be executed only once.
                UserDefaults.standard.set(true, forKey: "eventsLaunched1.0")
                UserDefaults.standard.synchronize();
                
                // Create default item list
                let items =
                [
                    ("AED pads applied"),
                    ("Backboard"),
                    ("Bag-mask device"),
                    ("Cardiac Monitor"),
                    ("Endotracheal intubation"),
                    ("IO access"),
                    ("IV access"),
                    ("Nasal cannula"),
                    ("Nasopharyngeal airway"),
                    ("Oropharyngeal airway"),
                    ("Oxygen"),
                    ("Pulse Check"),
                    ("Supraglottic airway"),
                    ("Waveform capnography")
                ]
                
                // Loop through, creating items
                for (itemName) in items
                {
                    // Create an individual item
                    _ = Event.createInManagedObjectContext(moc, name: itemName)
                }
            }
        }
        
        // Get items from entity
        fetchItems()
        
        // Save everything
        save()
        
        // Change table background to a blurry screenshot
        let backgroundImage = UIImageView(image: UIImage(named: "blurry_background.png"))
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.tableView.bounds //backgroundImage.bounds
        backgroundImage.addSubview(blurView)
        self.tableView.backgroundView = backgroundImage
        
        // Eliminate table cell separators
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.tableView.separatorColor = UIColor.clear
    }
    
    // Function to grab items from entity
    func fetchItems()
    {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Event")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Event]
        {
            events = fetchResults
        }
    }
    
    // Function to save and maintain data persistence
    func save()
    {
        do
        {
            try managedObjectContext!.save()
        }
        catch
        {
            fatalError("Could not save data.")
        }
    }
    
    // Add new item button was pressed
    @IBAction func addItemButton(_ sender: AnyObject)
    {
        addNewItem()
    }
    
    // Setup alert view to enter data via addNewItem method
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1
    
    func addNewItem()
    {
        
        let titlePrompt = UIAlertController(title: "New Event",
            message: "Please enter new item",
            preferredStyle: .alert)
        
        var titleTextField: UITextField?
        titlePrompt.addTextField
            {
                (textField) -> Void in
                titleTextField = textField
                textField.placeholder = "Event"
        }
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .default,
            handler:
            { (action) -> Void in
                if let textField = titleTextField
                {
                    self.saveNewItem(textField.text!)
                }
        }))
        
        self.present(titlePrompt,
            animated: true,
            completion: nil)
    }
    
    //Function to save new item
    func saveNewItem(_ title : String)
    {
        // Create the new item
        let newItem = Event.createInManagedObjectContext(self.managedObjectContext!, name: title)
        
        // Update the array containing the table view row data
        self.fetchItems()
        
        // Use Swift's find() function to figure out the index of the new item
        // after it's been added and sorted in our logItems array
        if let newItemIndex = events.firstIndex(of: newItem)
        {
            // Create an NSIndexPath from the newItemIndex
            let newItemIndexPath = IndexPath(row: newItemIndex, section: 0)
            // Animate in the insertion of this row
            tableView.insertRows(at: [ newItemIndexPath ], with: .automatic)
            save()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return self.events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) 

        let event = self.events[(indexPath as NSIndexPath).row]
        
        // Configure the cell
        cell.textLabel!.text = event.name
        cell.textLabel!.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear

        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support item selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedItem = events[(indexPath as NSIndexPath).row]
        self.delegate?.updateItem(selectedItem.name)
        _ = navigationController?.popViewController(animated: true)
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            // Find the item object the user is trying to delete
            let itemToDelete = events[(indexPath as NSIndexPath).row]
            
            // Delete it from the managedObjectContext
            managedObjectContext?.delete(itemToDelete)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchItems()
            
            // Tell the table view to animate out that row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            save()
        }
    }
}
