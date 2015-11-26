//
//  Constants.swift
//  AutoLayoutByCode
//
//  Created by Monzy on 15/11/26.
//  Copyright © 2015年 Monzy. All rights reserved.
//

import UIKit


let FONT_SCREENNAME = UIFont(name: "Avenir-Light", size: 18)
let FONT_TEXT = UIFont(name: "Avenir-Light", size: 15)
let FONT_RETWEETSCREENNAME = UIFont(name: "Avenir-Light", size: 18)
let FONT_RETWEETTEXT = UIFont(name: "Avenir-Light", size: 15)


//imagenames
class ImageNames {
    static let attitude_unactive = "upvote-unactive"
    static let attitude_active = "upvote-active"
    
    static let repost_unactive = "repost-unactive"
    static let repost_active = "repost-active"
    
    static let comment_unactive = "comment-unactive"
    static let comment_active = "comment-active"
}

class ImageType {
    static let origin = "origin"
    static let large = "large"
    static let bmiddle = "bmiddle"
    static let thumbnail = "thumbnail"
}

class Colors {
    static let pictureBackgroundColor = UIColor.clearColor()
    static let retweetBackgroundColor = UIColor(hex6: 0xE6E6E6)
}

class ItemSize {
    static let DefaultSpace: CGFloat = 10
    static let InnerSpace: CGFloat = 8
    static let HalfSpace: CGFloat = 5
    static let AvatarHeight: CGFloat = 48
    static let ButtonHeight: CGFloat = 20
    static let imageSpacePercent: CGFloat = 1 / 60
}

/*
retweetTextContentLabel?.text = status.retweetText
retweetTextContentLabel?.font = UIFont(name: "Avenir-Light", size: 15)
*/