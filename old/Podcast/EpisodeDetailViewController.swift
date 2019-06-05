//
//  EpisodeDetailViewController.swift
//  Podcast
//
//  Created by Mark Bryan on 4/11/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

import UIKit

class EpisodeDetailViewController: ViewController {

    override var usesLargeTitles: Bool { get { return false } }

    let marginSpacing: CGFloat = EpisodeDetailHeaderView.marginSpacing
    var episode: Episode?
    var headerView: EpisodeDetailHeaderView = EpisodeDetailHeaderView()
    var episodeDescriptionView: UITextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .offWhite
        
        episodeDescriptionView.isEditable = false
        episodeDescriptionView.font = ._14RegularFont()
        episodeDescriptionView.textColor = .charcoalGrey
        episodeDescriptionView.showsVerticalScrollIndicator = false
        episodeDescriptionView.backgroundColor = .clear
        episodeDescriptionView.textContainer.lineFragmentPadding = 0
        episodeDescriptionView.textContainerInset = UIEdgeInsetsMake(marginSpacing / 2, marginSpacing, marginSpacing, marginSpacing)
        view.addSubview(episodeDescriptionView)
        mainScrollView = episodeDescriptionView

        view.addSubview(headerView)
        headerView.delegate = self

        headerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        
        episodeDescriptionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        if let episode = episode {
            headerView.setup(for: episode, downloadStatus: DownloadManager.shared.status(for: episode.id))
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 4
            style.alignment = .left
            episodeDescriptionView.attributedText = episode.attributedDescription.toEpisodeDescriptionStyle()
            // weird known iOS bug when resizing a textContainer's text to be the start of a UITextView .. do not remove
            episodeDescriptionView.isScrollEnabled = false
            episodeDescriptionView.setNeedsUpdateConstraints()
            episodeDescriptionView.isScrollEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //here as well because from ExternalProfileViewController the navigationBar is hidden during viewDidLoad
        headerView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(navigationController?.navigationBar.frame.maxY ?? 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DownloadManager.shared.delegate = self
        headerView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(navigationController?.navigationBar.frame.maxY ?? 0)
        }
    }

}

// MARK: EpisodeDetailHeaderView Delegate
extension EpisodeDetailViewController: EpisodeDetailHeaderViewDelegate {

    func episodeDetailHeaderDidPressRecommendButton(view: EpisodeDetailHeaderView) {
        guard let headerEpisode = episode else { return }
        recast(for: headerEpisode, completion: { _, _ in
             view.setup(for: headerEpisode, downloadStatus: DownloadManager.shared.status(for: headerEpisode.id))
        })
    }
    
    func episodeDetailHeaderDidPressMoreButton(view: EpisodeDetailHeaderView) {
        guard let episode = episode else { return }
        
        let downloadOption = ActionSheetOption(type: DownloadManager.shared.actionSheetType(for: episode.id), action: {
            DownloadManager.shared.handle(episode)
        })

        let shareEpisodeOption = ActionSheetOption(type: .shareEpisode, action: {
            guard let user = System.currentUser else { return }
            let viewController = ShareEpisodeViewController(user: user, episode: episode)
            self.navigationController?.pushViewController(viewController, animated: true)
        })

        var header: ActionSheetHeader?
        
        if let image = view.episodeArtworkImageView.image, let title = view.episodeTitleLabel.text, let description = view.dateLabel.text {
            header = ActionSheetHeader(image: image, title: title, description: description)
        }
        
        let actionSheetViewController = ActionSheetViewController(options: [downloadOption, shareEpisodeOption], header: header)
        showActionSheetViewController(actionSheetViewController: actionSheetViewController)
    }
    
    func episodeDetailHeaderDidPressPlayButton(view: EpisodeDetailHeaderView) {
        guard let episode = episode, let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.showAndExpandPlayer()
        Player.sharedInstance.playEpisode(episode: episode)
        view.updateWithPlayButtonPress(episode: episode)
    }
    
    func episodeDetailHeaderDidPressBookmarkButton(view: EpisodeDetailHeaderView) {
        guard let episode = episode else { return }
        let completion = view.setBookmarkButtonToState
        episode.bookmarkChange(completion: completion)
    }
    
    func episodeDetailHeaderDidPressSeriesTitleLabel(view: EpisodeDetailHeaderView) {
        guard let episode = episode else { return }
        let seriesDetailViewController = SeriesDetailViewController()
        seriesDetailViewController.fetchSeries(seriesID: episode.seriesID)
        navigationController?.pushViewController(seriesDetailViewController, animated: true)
    }
    
}

// MARK: Episode Downloader
extension EpisodeDetailViewController: EpisodeDownloader {
    func didReceive(statusUpdate: DownloadStatus, for episode: Episode) {
        if let downloadedEpisode = self.episode, downloadedEpisode.id == episode.id {
            headerView.setup(for: downloadedEpisode, downloadStatus: DownloadManager.shared.status(for: downloadedEpisode.id))
        }
    }
}
