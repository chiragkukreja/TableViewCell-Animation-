//
//  CustomTableViewCell.swift
//  Assignment
//
//  Created by Chirag Kukreja on 8/7/16.
//  Copyright © 2016 abc. All rights reserved.
//

import UIKit

protocol CustomTableViewCellDelegate : class  {
    
    func customCelltappedDismissButton(cell:CustomTableViewCell)
}

class CustomTableViewCell: UITableViewCell {

    weak var delegate  : CustomTableViewCellDelegate?
    
    static let cellIdentifier = "cell"

    //MARK:- IBOutlets
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    //MARK:- Init
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //MARK:- Public Methods
    
    /**
     Display Data in cell
     
     - parameter title: string to show in cell
     */
    func showText(title: String) {
        
        self.title.text = title
        category.text = title
    }
    
    /**
     Customise Cell IBOutlets based in Bool
     
     - parameter isExpanded: boolean variable
     */
    func customizeCell(isExpanded : Bool) {
        category.hidden = !isExpanded
        dismissButton.hidden = !isExpanded
        title.hidden = isExpanded
    }
    
    /**
     Enable or Disable button
     
     - parameter enable: Boolean variable
     */
    func enableButton(enable:Bool) {
        
        dismissButton.enabled = enable
    }
    
    /**
     Dismiss Button Action
     
     - parameter sender: sender of type UIBUtton
     */

    @IBAction func dismiss(sender: AnyObject) {
        
       delegate?.customCelltappedDismissButton(self)
    }
}
