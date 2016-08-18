//
//  ViewController.swift
//  Assignment
//
//  Created by Chirag Kukreja on 8/7/16.
//  Copyright © 2016 abc. All rights reserved.
//

import UIKit

private let data = ["Business", "Games", "Finance", "Lifestyle", "Music", "News", "Productivity", "Social Networking", "Entertainment"]

class ViewController: ExpandableViewController {

    //MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK:- UITableView Delegate & DataSource

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(CustomTableViewCell.cellIdentifier, forIndexPath: indexPath) as? CustomTableViewCell else {
            fatalError("Unexpected cell")
        }
        
        cell.showText(data[indexPath.row])
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? CustomTableViewCell else {
            return
        }
        
        insertViewControllerWithIdentifier("DetailViewController", fromStoryboard: storyboard, toTableView: tableView, atIndexPath: indexPath, animateAlongsideTransition: {
            cell.delegate = self
            cell.customizeCell(true)
            cell.backgroundColor = UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1)
            cell.layoutIfNeeded()
            
            }, completion: {
                cell.enableButton(true)
        })
    }
}

//MARK:- CustomCell Delegate

extension ViewController : CustomTableViewCellDelegate {
    
    func customCelltappedDismissButton(cell:CustomTableViewCell) {

        if let cell = customSelectedCell as? CustomTableViewCell {
            dismissViewController(animateAlongsideTransition: {
                
                cell.customizeCell(false)
                cell.backgroundColor = UIColor.whiteColor()
                cell.layoutIfNeeded()
                
                }, completion: {
                    
                    cell.enableButton(false)
            })
        }
    }
}
