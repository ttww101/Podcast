//
//  SubscriptionsViewController.swift
//  Podcast
//
//  Created by Natasha Armbrust on 3/6/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

import UIKit

class SubscriptionsViewController: ViewController {

    var subscriptionsCollectionView: EmptyStateCollectionView!
    var subscriptions: [Series] = []
    var user: User

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .paleGrey
        title = "Subscriptions"
               
        let layout = setupCollectionViewFlowLayout()
        subscriptionsCollectionView = EmptyStateCollectionView(frame: view.frame, type: .subscription, collectionViewLayout: layout)
        subscriptionsCollectionView.register(SeriesGridCollectionViewCell.self, forCellWithReuseIdentifier: "SubscriptionsCollectionViewCellIdentifier")
        subscriptionsCollectionView.delegate = self
        subscriptionsCollectionView.dataSource = self
        subscriptionsCollectionView.emptyStateCollectionViewDelegate = self
        mainScrollView = subscriptionsCollectionView
        view.addSubview(subscriptionsCollectionView)
        
        fetchSubscriptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchSubscriptions()
    }

    func setupCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let cellWidth: CGFloat = 0.428 * view.frame.width
        let cellHeight: CGFloat = 0.315 * view.frame.height
        let edgeInset = (UIScreen.main.bounds.width - 2 * cellWidth) / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = edgeInset
        layout.minimumInteritemSpacing = edgeInset
        layout.sectionInset = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
        return layout
    }
    
    // MARK: - Fetch Data

    func fetchSubscriptions() {
        let subscriptionEndpointRequest = FetchSubscriptionsEndpointRequest(userID: user.id)

        subscriptionEndpointRequest.success = { (endpointRequest: EndpointRequest) in
            guard let subscriptions = endpointRequest.processedResponseValue as? [Series] else { return }
            self.subscriptions = subscriptions
            self.subscriptionsCollectionView.stopLoadingAnimation()
            self.subscriptionsCollectionView.reloadData()
        }
        
        subscriptionEndpointRequest.failure = { (endpointRequest: EndpointRequest) in
            self.subscriptionsCollectionView.stopLoadingAnimation()
        }
        
        System.endpointRequestQueue.addOperation(subscriptionEndpointRequest)
    }
    
}

// MARK: CollectionView Data Source
extension SubscriptionsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubscriptionsCollectionViewCellIdentifier", for: indexPath) as? SeriesGridCollectionViewCell else { return UICollectionViewCell() }
        cell.configureForSeries(series: subscriptions[indexPath.row], showLastUpdatedText: true)
        return cell
    }

}

// MARK: CollectionView Delegate
extension SubscriptionsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let seriesDetailViewController = SeriesDetailViewController(series: subscriptions[indexPath.row])
        navigationController?.pushViewController(seriesDetailViewController, animated: true)
    }

}

// MARK: EmptyStateCollectionView Delegate
extension SubscriptionsViewController: EmptyStateCollectionViewDelegate {

    func emptyStateViewDidPressActionItem() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let tabBarController = appDelegate.tabBarController else { return }
        tabBarController.selectedIndex = System.discoverSearchTab
    }
    
}
