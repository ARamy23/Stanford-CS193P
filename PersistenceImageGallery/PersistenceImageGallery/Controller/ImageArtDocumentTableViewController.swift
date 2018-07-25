//
//  ImageArtDocumentTableViewController.swift
//  ImageGallery
//
//  Created by Ahmed Ramy on 7/20/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class ImageArtDocumentTableViewController: UITableViewController {

    var emojiArtDocuments = ["🤪","🤩","🤤"]
    var removedEmojis = [String]()
    var sections: [[String]] { return [emojiArtDocuments, removedEmojis] }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
        case 0:
            return "Favourite Emojis"
        case 1:
            return "Deleted Emojis"
        default:
            return ""
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")

        // Configure the cell...
        cell.textLabel?.text = emojiArtDocuments[indexPath.row]
        cell.textLabel?.font = cell.textLabel?.font.withSize(Settings.DefaultValues.TableViewValues.textSize)
        cell.textLabel?.textAlignment = .center
        cell.frame.size = Settings.DefaultValues.TableViewValues.cellSize

        return cell
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay
        {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let removedEmoji = emojiArtDocuments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            removedEmojis.append(removedEmoji)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 {
            let restore = UIContextualAction(style: .normal, title: "Restore") { (action, view, completionHandler) in
                let restoredItem = self.removedEmojis.remove(at: indexPath.row)
                self.emojiArtDocuments.append(restoredItem)
                completionHandler(true)
                self.tableView.reloadData()
            }
            restore.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            
            return UISwipeActionsConfiguration(actions: [restore])
        } else {
            return nil
        }
    }

    @IBAction func didTapAddButton(_ sender: UIBarButtonItem)
    {
        emojiArtDocuments += ["Untitled".madeUnique(withRespectTo: emojiArtDocuments)]
        tableView.reloadData()
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLine
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
