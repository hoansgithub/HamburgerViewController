//
//  HamburgerViewController.swift
//  Mercury
//
//  Created by Hoan on 9/13/16.
//  Copyright © 2016 mobile.tc.com. All rights reserved.
//

import UIKit

let SCREEN_SIZE: CGRect = UIScreen.main.bounds
enum HamburgerMenuInitialPosition  {
    case left
    case right
}
class HamburgerViewController: UIViewController {
    
    fileprivate(set) weak var viewHolder : UIViewController?
    
    fileprivate(set) weak var menuView : UIView?
    
    fileprivate(set) var menuHolder : UIView?
    
    fileprivate(set) var widthMultiplier: CGFloat   = 0.8
    
    fileprivate(set) var initialPosition: HamburgerMenuInitialPosition = .left
    
    fileprivate(set) var menuConstraints = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            viewHolder = nav
        }
        else {
            viewHolder = self
        }
        
        let viewFrame = viewHolder?.view.frame
        self.menuHolder = UIView(frame: CGRect(x: -(viewFrame?.size.width)!, y: 0,  width: (viewFrame?.size.width)!,  height: (viewFrame?.size.height)!) )
        self.viewHolder?.view.superview?.addSubview(self.menuHolder!)
        
        
        //tap gesture for menuHolder
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(HamburgerViewController.singleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        self.menuHolder?.addGestureRecognizer(singleTapGesture)
        singleTapGesture.delegate = self
        
        
    }
    
    func singleTap(_ gestureRecognizer: UITapGestureRecognizer ) {
        
        if gestureRecognizer.view == self.menuHolder {
            self.closeBurgerMenu()
        }
    }
    
    
    final func openBurgerMenuWithViewController(_ vc : UIViewController , widthMultiplier : CGFloat , initialPosition : HamburgerMenuInitialPosition) {
        let viewFrame = viewHolder?.view.frame
        let posKey : CGFloat = initialPosition == .left ? (-1) : 1
        self.menuHolder?.frame.origin.x = (viewFrame?.size.width)! * (posKey)
        
        self.initialPosition = initialPosition
        
        //default width is 8/10 of holder screen
        self.widthMultiplier = widthMultiplier == 0 ? 0.8 : widthMultiplier
        
        self.menuView?.removeFromSuperview()
        self.menuHolder?.addSubview(vc.view)
        vc.view.didMoveToSuperview()
        vc.didMove(toParentViewController: viewHolder)
        self.menuHolder?.removeConstraints(menuConstraints)
        self.menuView = vc.view
        self.menuView?.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        
        let views:[String : UIView] = [
            "menuView" : self.menuView!
        ]
        let metrics = ["viewWidth" : (viewFrame?.size.width)! * widthMultiplier]
        
        let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[menuView]|", options: [], metrics: nil, views: views)
        let constraintsHFormat = initialPosition == .left ? "H:|[menuView(viewWidth)]" : "H:[menuView(viewWidth)]|"
        
        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: constraintsHFormat, options: [], metrics: metrics, views: views)
        
        menuConstraints.append(contentsOf: constraintsV)
        menuConstraints.append(contentsOf: constraintsH)
        
        self.menuHolder?.addConstraints(menuConstraints)
        
        
        //view holder shadow
        let holderLayer = self.menuView?.layer
        holderLayer?.shadowOpacity = 0.6
        holderLayer?.shadowOffset = CGSize(width: 0, height: 0)
        holderLayer?.masksToBounds = false
        
        
        //animate view holder
        self.menuHolder?.frame.origin.x = (viewFrame?.size.width)! * widthMultiplier * posKey
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            self.menuHolder?.frame.origin.x = 0
            self.viewHolder?.view.frame.origin.x = (viewFrame?.size.width)! * widthMultiplier * -posKey
        }) { (finished) in
        }
        
    }
    
    final func closeBurgerMenu() {
        
        let posKey: CGFloat  = self.initialPosition == .left ? -1 : 1
        
        UIView.animate(withDuration: 0.3, animations: {
            self.menuHolder?.frame.origin.x = (self.menuHolder?.frame.size.width)! * self.widthMultiplier * posKey
            self.viewHolder?.view.frame.origin.x = 0
            }, completion: { (finished) in
                if finished {
                    self.menuHolder?.frame.origin.x = (self.menuHolder?.frame.size.width)! * -posKey
                    self.menuView?.removeFromSuperview()
                }
        })
    }
}


//prevent child view tap
extension HamburgerViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.menuHolder {
            return true
        }
        return false
    }
}

