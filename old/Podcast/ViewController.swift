//
//  ViewController.swift
//  Podcast
//
//  Created by Drew Dunne on 4/25/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

/*
 * USAGE:
 *     Either override the function updateTableViewInsetsForAccessoryView() in your subclass
 *     and update the bottom UITableView insets to be large enough for the accessory view (miniplayer)
 * OR:
 *     Set the 'mainScrollView' property to be your view's UIScrollView/UITableView/UICollectionView/etc
 *         ex. mainScrollView = bookmarkTableView
 *     This way is easier but offers less flexibility (ex. doesn't work for multiple full screen tableViews on one view).
 *
 */

import UIKit

class ViewController: UIViewController {

    // Override this variable to not use iOS 11 large titles 
    var usesLargeTitles: Bool { get { return true } }

    let iPhoneXBottomOffset:CGFloat = 5
    var insetPadding: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set navigationController?.navigationItem.largeTitleDisplayMode on ALL view controllers
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if System.isiPhoneX() { insetPadding = iPhoneXBottomOffset }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        stylizeNavBar()
    }
    
    func stylizeNavBar() {
        navigationController?.navigationBar.tintColor = .sea
        navigationController?.navigationBar.backgroundColor = .offWhite
        navigationController?.navigationBar.barTintColor = .offWhite
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = .offWhite
    }
    
    var mainScrollView: UIScrollView?
    
    func updateTableViewInsetsForAccessoryView() {
        // Override this function in views with UITableViews
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let mainScrollView = mainScrollView else { return }
        if appDelegate.tabBarController.accessoryViewController == nil {
            mainScrollView.contentInset.bottom = appDelegate.tabBarController.tabBar.frame.height - insetPadding
        } else {
            let miniPlayerFrame = appDelegate.tabBarController.accessoryViewController?.accessoryViewFrame()
            if let accessoryFrame = miniPlayerFrame {
                mainScrollView.contentInset.bottom = appDelegate.tabBarController.tabBar.frame.height + accessoryFrame.height - insetPadding
            } else {
                mainScrollView.contentInset.bottom = appDelegate.tabBarController.tabBar.frame.height - insetPadding
            }
        }
    }
    
    func mainScrollViewSetup() {
        mainScrollView?.contentInsetAdjustmentBehavior = .automatic
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem?.title = ""
    }     

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableViewInsetsForAccessoryView()
        mainScrollViewSetup()
        displayNavTitle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayNavTitle()
    }

    func displayNavTitle() {
        if usesLargeTitles {
            navigationController?.navigationBar.topItem?.largeTitleDisplayMode = .always
            navigationController?.navigationItem.largeTitleDisplayMode = .always
        } else {
            navigationController?.navigationBar.topItem?.largeTitleDisplayMode = .never
            navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = .clear
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
