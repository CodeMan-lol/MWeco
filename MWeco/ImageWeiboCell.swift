//
//  ImageWeiboCell.swift
//  MWeco
//
//  Created by Monzy on 15/11/20.
//  Copyright © 2015年 Monzy. All rights reserved.
//

import UIKit

class ImageWeiboCell: UITableViewCell {

    var status: Status?
    
    // Mark outlets
    @IBOutlet var avatarImageView: AsyncImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var sendFromLabel: UILabel!
    @IBOutlet var upvoteButton: SpringButton! {
        didSet {
            updateButtonState()
        }
    }
    @IBOutlet var repostButton: SpringButton!
    @IBOutlet var commentButton: SpringButton!
    @IBOutlet var imageRootView: UIView!
    
    // Mark actions
    @IBAction func upvoteButtonPressed(sender: SpringButton) {
        sender.animation = "pop"
        sender.animate()
        var newState: Bool = (status?.liked)!
        newState = !newState
        status?.liked = newState
        updateButtonState()
    }
    
    @IBAction func repostButtonPressed(sender: SpringButton) {
        sender.animation = "pop"
        sender.animate()
    }
    
    @IBAction func commentButtonPressed(sender: SpringButton) {
        sender.animation = "pop"
        sender.animate()
    }
    
    func updateButtonState() {
        if status?.liked == true {
            upvoteButton?.setImage(UIImage(named: "upvote-active"), forState: .Normal)
        } else if status?.liked == false {
            upvoteButton?.setImage(UIImage(named: "upvote-unactive"), forState: .Normal)
        }
    }
    
    func configure() {
        contentLabel.text = "self.imageRootView.frame = CGRect(x: self.imageRootView.frame.origin.x, y: self.imageRootView.frame.origin.y, width: self.imageRootView.frame.width, height: 400) self.imageRootView.frame = CGRect(x: self.imageRootView.frame.origin.x, y: self.imageRootView.frame.origin.y, width: self.imageRootView.frame.width, height: 400)"
        dispatch_async(dispatch_get_main_queue(), {
            self.imageRootView.frame = CGRect(x: self.imageRootView.frame.origin.x, y: self.imageRootView.frame.origin.y, width: self.imageRootView.frame.width, height: 400)
            self.contentView.updateConstraintsIfNeeded()
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
