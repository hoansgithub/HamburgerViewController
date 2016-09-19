//
//  HamburgerViewController.swift
//  Mercury
//
//  Created by Hoan on 9/13/16.
//  Copyright © 2016 mobile.tc.com. All rights reserved.
//

import UIKit

let SCREEN_SIZE: CGRect = UIScreen.mainScreen().bounds
enum HamburgerMenuInitialPosition  {
    case Left
    case Right
}
class HamburgerViewController: UIViewController {

    private(set) weak var viewHolder : UIViewController?
    
    private(set) weak var menuView : UIView?
    
    private(set) var menuHolder : UIView?
    
    private(set) var widthMultiplier: CGFloat   = 0.8
    
    private(set) var initialPosition: HamburgerMenuInitialPosition = .Left
    
    private(set) var menuConstraints = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            viewHolder = nav
        }
        else {
            viewHolder = self
        }
        
        let viewFrame = viewHolder?.view.frame
        self.menuHolder = UIView(frame: CGRectMake(-(viewFrame?.size.width)!, 0,  (viewFrame?.size.width)!,  (viewFrame?.size.height)!) )
        self.viewHolder?.view.superview?.addSubview(self.menuHolder!)
        
        
        //tap gesture for menuHolder
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(HamburgerViewController.singleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        self.menuHolder?.addGestureRecognizer(singleTapGesture)
        singleTapGesture.delegate = self
        
        
    }

    func singleTap(gestureRecognizer: UITapGestureRecognizer ) {

        if gestureRecognizer.view == self.menuHolder {
            self.closeBurgerMenu()
        }
    }
    
    
    final func openBurgerMenuWithViewController(vc : UIViewController , widthMultiplier : CGFloat , initialPosition : HamburgerMenuInitialPosition) {
        let viewFrame = viewHolder?.view.frame
        let posKey : CGFloat = initialPosition == .Left ? (-1) : 1
        self.menuHolder?.frame.origin.x = (viewFrame?.size.width)! * (posKey)
        
        self.initialPosition = initialPosition
        
        //default width is 8/10 of holder screen
        self.widthMultiplier = widthMultiplier == 0 ? 0.8 : widthMultiplier
        
        self.menuView?.removeFromSuperview()
        self.menuHolder?.addSubview(vc.view)
        vc.view.didMoveToSuperview()
        vc.didMoveToParentViewController(self)
        self.menuHolder?.removeConstraints(menuConstraints)
        self.menuView = vc.view
        self.menuView?.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        
        let views:[String : UIView] = [
            "menuView" : self.menuView!
        ]
        let metrics = ["viewWidth" : (viewFrame?.size.width)! * widthMultiplier]
        
        let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[menuView]|", options: [], metrics: nil, views: views)
        let constraintsHFormat = initialPosition == .Left ? "H:|[menuView(viewWidth)]" : "H:[menuView(viewWidth)]|"
        
        let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat(constraintsHFormat, options: [], metrics: metrics, views: views)
        
        menuConstraints.appendContentsOf(constraintsV)
        menuConstraints.appendContentsOf(constraintsH)
        
        self.menuHolder?.addConstraints(menuConstraints)
        
        
        //view holder shadow
        let holderLayer = self.menuView?.layer
        holderLayer?.shadowOpacity = 0.6
        holderLayer?.shadowOffset = CGSize(width: 0, height: 0)
        holderLayer?.masksToBounds = false
        
        
        //animate view holder
        self.menuHolder?.frame.origin.x = (viewFrame?.size.width)! * widthMultiplier * posKey
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            self.menuHolder?.frame.origin.x = 0
            self.viewHolder?.view.frame.origin.x = (viewFrame?.size.width)! * widthMultiplier * -posKey
            }) { (finished) in
        }
        
    }
    
    final func closeBurgerMenu() {
        
        let posKey: CGFloat  = self.initialPosition == .Left ? -1 : 1
        
        UIView.animateWithDuration(0.3, animations: { 
                self.menuHolder?.frame.origin.x = (self.menuHolder?.frame.size.width)! * self.widthMultiplier * posKey
            self.viewHolder?.view.frame.origin.x = 0
            }) { (finished) in
                if finished {
                    self.menuHolder?.frame.origin.x = (self.menuHolder?.frame.size.width)! * -posKey
                    self.menuView?.removeFromSuperview()
                }
        }
    }
}


//prevent child view tap
extension HamburgerViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view == self.menuHolder {
            return true
        }
        return false
    }
}

