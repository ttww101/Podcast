//
//  EpisodeTableViewCell.swift
//  Podcast
//
//  Created by Drew Dunne on 2/25/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

import UIKit
import SnapKit

protocol EpisodeTableViewCellDelegate: class {
    func didPress(on action: EpisodeAction, for cell: EpisodeTableViewCell)
}

class EpisodeTableViewCell: UITableViewCell, EpisodeSubjectViewDelegate {

    var episodeSubjectView: EpisodeSubjectView!
    
    weak var delegate: EpisodeTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        episodeSubjectView = EpisodeSubjectView()
        contentView.addSubview(episodeSubjectView)
        
        episodeSubjectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        episodeSubjectView.delegate = self 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with episode: Episode, downloadStatus: DownloadStatus) {
        episodeSubjectView.setup(with: episode, downloadStatus: downloadStatus)
    }

    func updateWithPlayButtonPress(episode: Episode) {
        episodeSubjectView.updateWithPlayButtonPress(episode: episode)
    }
    
    ///
    /// Mark: Delegate
    ///
    func setBookmarkButtonToState(isBookmarked: Bool) {
        episodeSubjectView.episodeUtilityButtonBarView.setBookmarkButtonToState(isBookmarked: isBookmarked)
    }
    
    func setRecommendedButtonToState(isRecommended: Bool, numberOfRecommendations: Int) {
        episodeSubjectView.episodeUtilityButtonBarView.setRecommendedButtonToState(isRecommended: isRecommended, numberOfRecommendations: numberOfRecommendations)
    }

    func didPress(on action: EpisodeAction, for view: EpisodeSubjectView) {
        delegate?.didPress(on: action, for: self)
    }
}




