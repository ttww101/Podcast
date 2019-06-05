//
//  EmptyStateView.swift
//  Podcast
//
//  Created by Natasha Armbrust on 10/22/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//
import UIKit
import SnapKit

enum EmptyStateType {
    case pastSearch
    case bookmarks
    case search
    case searchItunes
    case feed
    case listeningHistory
    case following
    case followers
    case subscription
    case sharedContent // for the view controller for episodes shared with you
    case unimplemented
    case downloads
    
    var title: String {
        switch self {
        case .pastSearch:
            return "Search Podcasts"
        case .bookmarks:
            return "Nothing Saved for Later"
        case .search, .searchItunes:
            return "Sorry! No results found."
        case .feed:
            return "Empty Feed"
        case .listeningHistory:
            return "No Listening History"
        case .followers:
            return "No Followers"
        case .following:
            return "No Followings"
        case .subscription:
            return "No Subscriptions"
        case .downloads:
            return "No Downloads"
        case .sharedContent:
            return "No Shared Content"
        case .unimplemented:
            return "Coming Soon!"
        }
    }
    
    var explanation: String {
        switch self {
        case .pastSearch:
            return "Find your favorite podcast episodes, series, & friends."
        case .bookmarks:
            return "You can save podcast episodes for later here. Start looking now!"
        case .feed:
            return "Oh no! Your feed is empty. Find series and friends to get live updates!"
        case .listeningHistory:
            return "You haven’t listened to anything yet. Start listening to some now."
        case .subscription:
            return "You haven’t subscribed to any series yet. Search for some now."
        case .followers:
            return "No followers yet."
        case .following:
            return "No one followed yet."
        case .downloads:
            return "You can view your locally downloaded podcast episodes here."
        case .sharedContent:
            return "This is where you can find podcast episodes shared with you by your friends."
        case .unimplemented:
            return "We are hard at work getting this feature to you!"
        default:
            return ""
        }
    }
    
    var image: UIImage? {
        switch self {
        case .search, .searchItunes:
            return #imageLiteral(resourceName: "no_search_results_icon")
        case .pastSearch:
            return #imageLiteral(resourceName: "searchIcon")
//        case .bookmarks:
//            return #imageLiteral(resourceName: "bookmark_empty_state")
        case .listeningHistory:
            return #imageLiteral(resourceName: "iPodcast")
        case .followers, .following:
            return #imageLiteral(resourceName: "profile_empty_state")
        case .downloads:
            return #imageLiteral(resourceName: "download_null")
        case .sharedContent:
            return #imageLiteral(resourceName: "shared_null_state")
        default:
            return nil
        }
    }
    
    var actionItemButtonTitle: String? {
        switch self {
        case .listeningHistory, .downloads, .bookmarks:
            return "Discover Episodes"
        case .feed:
            return "Find Friends & Series to Follow"
        case .subscription:
            return "Search Series"
        case .sharedContent:
            return "Find Friends to Follow"
        case .search:
            return "Search the web to add more series to our collection."
        default:
            return nil
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .pastSearch:
            return .offWhite
        default:
            return .paleGrey
        }
    }
}

protocol EmptyStateViewDelegate: class {
    func didPressActionItemButton()
}

class EmptyStateView: UIView {
    
    let iconImageViewWidth: CGFloat = 50
    let iconImageViewHeight: CGFloat = 48
    let explanationLabelWidth: CGFloat = 0.7
    let padding: CGFloat = 18
    
    var iconImageView: UIImageView?
    var titleLabel: UILabel!
    var explanationLabel: UILabel!
    var actionItemButton: UIButton!
    var mainView: UIView!
    
    weak var delegate: EmptyStateViewDelegate?
    
    init(type: EmptyStateType, iconImageViewY: CGFloat = 175) {
        super.init(frame: .zero)
        backgroundColor = type.backgroundColor
        mainView = UIView()
        addSubview(mainView)
        
        if let image = type.image {
            iconImageView = UIImageView(image: image)
            mainView.addSubview(iconImageView!)
            iconImageView!.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(iconImageViewY)
                make.centerX.equalToSuperview()
                make.width.lessThanOrEqualTo(iconImageViewWidth)
                make.height.lessThanOrEqualTo(iconImageViewHeight)
            }
        }
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.text = type.title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .slateGrey
        titleLabel.font = ._16SemiboldFont()
        mainView.addSubview(titleLabel)
        
        explanationLabel = UILabel()
        explanationLabel.numberOfLines = 3
        explanationLabel.textAlignment = .center
        explanationLabel.text = type.explanation
        explanationLabel.textColor = .slateGrey
        explanationLabel.font = ._14RegularFont()
        mainView.addSubview(explanationLabel)
        
        actionItemButton = UIButton()
        actionItemButton.setTitleColor(.sea, for: .normal)
        actionItemButton.backgroundColor = .clear
        actionItemButton.addTarget(self, action: #selector(didPressActionItemButton), for: .touchUpInside)
        actionItemButton.isHidden = true
        if let actionItemButtonTitle = type.actionItemButtonTitle {
            let attributedString = NSMutableAttributedString(string: actionItemButtonTitle)
            
            attributedString.addAttribute(.foregroundColor, value: UIColor.sea, range: NSRange(location: 0, length: actionItemButtonTitle.count))
            if type == .search {
                attributedString.addAttribute(.foregroundColor, value: UIColor.slateGrey, range: NSRange(location: 15, length: 37))
            }
            actionItemButton.setAttributedTitle(attributedString, for: .normal)
            
            actionItemButton.titleLabel?.font = ._14RegularFont()
            actionItemButton.titleLabel?.numberOfLines = 2
            actionItemButton.titleLabel?.textAlignment = .center
            actionItemButton.isHidden = false
        }
        mainView.addSubview(actionItemButton)
        
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            if let imageView = iconImageView {
                make.top.equalTo(imageView.snp.bottom).offset(padding)
            } else {
                make.top.equalToSuperview().inset(iconImageViewY)
            }
            make.leading.trailing.equalToSuperview().inset(padding).priority(999)
            make.centerX.equalToSuperview().priority(999)
        }
        
        explanationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(padding)
            make.width.equalTo(snp.width).multipliedBy(explanationLabelWidth)
        }
        
        actionItemButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(padding)
            make.width.equalTo(snp.width).multipliedBy(explanationLabelWidth)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func didPressActionItemButton() {
        delegate?.didPressActionItemButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
