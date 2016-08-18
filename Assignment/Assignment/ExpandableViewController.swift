//
//  ExpandableViewController.swift
//  Assignment
//
//  Created by Chirag Kukreja on 8/7/16.
//  Copyright © 2016 abc. All rights reserved.
//

import UIKit

class ExpandableViewController: UIViewController {

    //MARK:- Private Variables
    private var tableView               : UITableView?
    private var childViewController     : UIViewController?
    private var visibleCells            : [UITableViewCell]?
    private(set) var customSelectedCell : UITableViewCell?
    
    private var tableViewTopCellContentOffset   : CGFloat = 0
    private var tableViewContentOffset          : CGFloat = 0
    private var statusBarOffset                 : CGFloat = 0
    private var navigationBarOffset             : CGFloat = 0
    
    private var selectedCellFrame                       = CGRectZero
    private var selectedCellFrameOnAnimationCompletion  = CGRectZero
    private var childViewControllerFrame                = CGRectZero
    
    //MARK:- Public Methods
    /**
     This method will be called when dismiss button is tapped on cell
     
     - parameter animateAlongsideTransition: animation Block
     - parameter completion:                 completion Block
     */
    func dismissViewController(animateAlongsideTransition animateAlongsideTransition: (() -> Void)?, completion: (() -> Void)?) {
        
        guard let selectedCell = customSelectedCell else {
            fatalError("Selected cell is missing")
        }
        
        guard let tableView = tableView else {
            fatalError("TableView is missing")
        }
        
        guard let indexPath = tableView.indexPathForCell(selectedCell) else {
            assertionFailure("Cannot get indexPath for selected cell")
            return
        }
        
        guard let visibleCells = visibleCells else {
            fatalError("VisibleCells array is missing")
        }
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            
            animateAlongsideTransition?()
            
            for cell in visibleCells {
                
                if let cellIndexPath = tableView.indexPathForCell(cell) {
                    
                    // Move up cells which have indexPath higher than selected cell
                    if cellIndexPath.row > indexPath.row {
                        cell.frame = CGRectOffset(cell.frame, 0, -tableView.frame.height + tableView.estimatedRowHeight * CGFloat(indexPath.row + 1) - self.tableViewContentOffset)
                        
                    } else {
                        
                        if cell == selectedCell {
                            cell.frame = self.selectedCellFrame
                        } else {
                            
                            // Move down cells which have indexPath lower than selected cell
                            cell.frame = CGRectOffset(self.selectedCellFrame, 0, -tableView.estimatedRowHeight * CGFloat(indexPath.row - cellIndexPath.row))
                        }
                    }
                }
            }
            
            self.childViewController?.view.frame = self.childViewControllerFrame
            
            }, completion: { _ in
                tableView.reloadData()
                tableView.scrollEnabled = true
                tableView.allowsSelection = true
                self.visibleCells?.removeAll()
                self.visibleCells = nil
                self.childViewController?.view.removeFromSuperview()
                self.childViewController?.removeFromParentViewController()
                self.childViewController = nil
                self.customSelectedCell = nil
                
                completion?()
        })
    }
    /**
     Insert new Viewcontroller as a child
     
     - parameter identifier:                 identifier of the new view controller
     - parameter storyboard:                 Instance of storyBoard
     - parameter tableView:                  tableView Instance
     - parameter indexPath:                  indexpath of selected cell
     - parameter animateAlongsideTransition: animation Block
     - parameter completion:                 completion Block
     */
    
    func insertViewControllerWithIdentifier(identifier: String, fromStoryboard storyboard: UIStoryboard?, toTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath, animateAlongsideTransition: (() -> Void)?, completion: (() -> Void)?) {
        
        guard let viewController = storyboard?.instantiateViewControllerWithIdentifier(identifier) else {
            assertionFailure("No such view controller (\(identifier)) in specified storyboard")
            return
        }
        
        guard let selectedCell = tableView.cellForRowAtIndexPath(indexPath) else {
            assertionFailure("Cannot get cell for row \(indexPath.row)")
            return
        }
        
        self.tableView = tableView
        self.customSelectedCell = selectedCell
        self.childViewController = viewController
        
        // Insert viewController as a child
        self.addChildViewController(viewController)
        viewController.didMoveToParentViewController(self)
        
        // Get frame of selected cell
        selectedCellFrame = tableView.rectForRowAtIndexPath(indexPath)
        
        // Set offset for navigation bar height if needed
        if let navigationController = self.navigationController {
            navigationBarOffset = navigationController.navigationBar.frame.height
        }
        
        // Set offset for status bar if needed
        if !UIApplication.sharedApplication().statusBarHidden {
            statusBarOffset = self.getStatusBarHeight()
        }
        
        if let parentViewController = self.parentViewController {
            if parentViewController.respondsToSelector(#selector(ExpandableViewController.insertViewControllerWithIdentifier(_:fromStoryboard:toTableView:atIndexPath:animateAlongsideTransition:completion:))) {
                navigationBarOffset = 0
                statusBarOffset = 0
            }
        }
        
        // Set default viewController's frame as CGRect right below selected cell with height 0
        childViewControllerFrame = CGRect(x: selectedCellFrame.origin.x, y: self.navigationBarOffset + self.statusBarOffset + selectedCellFrame.origin.y + tableView.estimatedRowHeight, width: selectedCellFrame.width, height: 0)
        
        viewController.view.frame = childViewControllerFrame
        view.addSubview(viewController.view)
        
        tableView.scrollEnabled = false
        tableView.allowsSelection = false
        
        // Set offsets before animation (needed to animate back properly)
        tableViewTopCellContentOffset = tableView.contentOffset.y % tableView.estimatedRowHeight
        tableViewContentOffset = tableView.contentOffset.y
        
        // Set selected cell frame which should be after animation finished
        if let topCell = tableView.visibleCells.first, let topCellIndexPath = tableView.indexPathForCell(topCell) {
            selectedCellFrameOnAnimationCompletion = CGRect(x: selectedCellFrame.origin.x, y: CGFloat(topCellIndexPath.row) * tableView.estimatedRowHeight + tableViewTopCellContentOffset, width: selectedCellFrame.width, height: selectedCellFrame.height)
        }
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            
            animateAlongsideTransition?()
            
            for cell in tableView.visibleCells {
                
                if self.visibleCells == nil {
                    self.visibleCells = [UITableViewCell]()
                }
                
                self.visibleCells?.append(cell)
                
                if let cellIndexPath = tableView.indexPathForCell(cell) {
                    
                    // Move down cells which have indexPath higher than selected cell
                    if cellIndexPath.row > indexPath.row {
                        
                        // Cell with indexPath next to selected cell indexPath will be right below screen bottom
                        cell.frame = CGRectOffset(cell.frame, 0, tableView.frame.height - tableView.estimatedRowHeight * CGFloat(indexPath.row + 1) + self.tableViewContentOffset)
                        
                    } else {
                        
                        if cell == selectedCell {
                            cell.frame = self.selectedCellFrameOnAnimationCompletion
                        } else {
                            
                            // Move up cells which have indexPath lower than selected cell
                            cell.frame = CGRectOffset(self.selectedCellFrameOnAnimationCompletion, 0, -tableView.estimatedRowHeight * CGFloat(indexPath.row - cellIndexPath.row))
                        }
                    }
                }
            }
            
            viewController.view.frame = CGRect(x: 0, y: self.navigationBarOffset + self.statusBarOffset + tableView.estimatedRowHeight, width: tableView.frame.width, height: tableView.frame.height - tableView.estimatedRowHeight)
            
            }, completion: { _ in
                completion?()
        })
    }
    
    //MARK:- Private Method
    private func getStatusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        return statusBarSize.height
    }
}
