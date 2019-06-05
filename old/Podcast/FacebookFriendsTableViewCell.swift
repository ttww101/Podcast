//
//  FacebookFriendsTableViewCell.swift
//  Podcast
//
//  Created by Natasha Armbrust on 12/17/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

import UIKit

enum FacebookFriendsCellAction {
    case follow // press follow button
    case seeAll // press see all in header
    case dismiss // press dismiss of a cell
    case didSelect // press a cell
}

protocol FacebookFriendsTableViewCellDelegate: class {
    func didPress(with action: FacebookFriendsCellAction, on collectionViewCell: FacebookFriendsCollectionViewCell?, in tableViewCell: FacebookFriendsTableViewCell, for indexPath: IndexPath?)
}

protocol FacebookFriendsTableViewCellDataSource: class {
    func facebookFriendsTableViewCell(cell: FacebookFriendsTableViewCell, dataForItemAt indexPath: IndexPath) -> User
    func numberOfFacebookFriends(forFacebookFriendsTableViewCell cell: FacebookFriendsTableViewCell) -> Int
}

// This cell is a self sufficent cell that can be inserted in any tableView
// Displays a horizontal collection view of facebook friends to follow
class FacebookFriendsTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, FacebookFriendsCollectionViewCellDelegate {

    var collectionView: UICollectionView!
    var headerLabel: UILabel!
    var seeAllButton: UIButton!
    var loadingAnimation: UIActivityIndicatorView!
    let cellIdentifier = "facebookCollectionViewCell"
    let edgeInsets: CGFloat = 6
    let topBottomPadding: CGFloat = 12
    let rightLeftPadding: CGFloat = 18
    weak var delegate: FacebookFriendsTableViewCellDelegate?
    weak var dataSource: FacebookFriendsTableViewCellDataSource?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: FacebookFriendsCollectionViewCell.cellWidth, height: FacebookFriendsCollectionViewCell.cellHeight)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = edgeInsets
        layout.minimumInteritemSpacing = edgeInsets
        layout.sectionInset = UIEdgeInsets(top: topBottomPadding, left: rightLeftPadding, bottom: topBottomPadding, right: rightLeftPadding)

        headerLabel = UILabel()
        headerLabel.text = "Suggested Facebook Friends"
        headerLabel.font = ._14SemiboldFont()
        headerLabel.textColor = .charcoalGrey

        seeAllButton = UIButton()
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(.slateGrey, for: .normal)
        seeAllButton.titleLabel!.font = ._12RegularFont()
        seeAllButton.titleEdgeInsets.top = 0
        seeAllButton.addTarget(self, action: #selector(didPressSeeAllButton), for: .touchUpInside)

        contentView.addSubview(seeAllButton)
        contentView.addSubview(headerLabel)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.register(FacebookFriendsCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.backgroundColor = .clear

        contentView.addSubview(collectionView)

        loadingAnimation = LoadingAnimatorUtilities.createInfiniteScrollAnimator()
        contentView.addSubview(loadingAnimation)

        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2 * edgeInsets)
            make.leading.equalToSuperview().inset(3 * edgeInsets)
        }

        seeAllButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(3 * edgeInsets)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.height.greaterThanOrEqualTo(layout.itemSize.height + 4 * edgeInsets)
            make.leading.trailing.bottom.equalToSuperview()
        }

        loadingAnimation.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(6 * edgeInsets)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfFacebookFriends(forFacebookFriendsTableViewCell: self) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? FacebookFriendsCollectionViewCell else { return FacebookFriendsCollectionViewCell() }
        guard let user = dataSource?.facebookFriendsTableViewCell(cell: self, dataForItemAt: indexPath) else { return FacebookFriendsCollectionViewCell() }
        cell.delegate = self
        cell.configureForUser(user: user)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FacebookFriendsCollectionViewCell else { return }
        delegate?.didPress(with: .didSelect, on: cell, in: self, for: indexPath)
    }

    func didPress(action: FacebookFriendsCellAction, on cell: FacebookFriendsCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        delegate?.didPress(with: action, on: cell, in: self, for: indexPath)
    }

    @objc func didPressSeeAllButton() {
        delegate?.didPress(with: .seeAll, on: nil, in: self, for: nil)
    }
}
