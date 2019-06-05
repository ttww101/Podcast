//
//  ShareEpisodeViewController.swift
//  Podcast
//
//  Created by Natasha Armbrust on 2/15/18.
//  Copyright © 2018 Cornell App Development. All rights reserved.
//
import UIKit
import SwiftMessages

class ShareEpisodeViewController: FollowerFollowingViewController {

    var episode: Episode
    @objc var episodeShareCompletion: ((User) -> ())!

    init(user: User, episode: Episode) {
        self.episode = episode
        super.init(user: user)
        followersOrFollowings = .Followers
        episodeShareCompletion = { tappedUser in
            MessageView.show(with: .share(episode: episode, user: tappedUser), completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Tap to Share"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tappedUser = users[indexPath.row]
        let shareEpisodeOption = ActionSheetOption(type: .confirmShare, action: {
            self.episode.share(with: tappedUser, success: { self.episodeShareCompletion(tappedUser) }, failure: { self.navigationController?.present(UIAlertController.somethingWentWrongAlert(), animated: true, completion: nil)})
            // TODO: error handling
        })

        var header: ActionSheetHeader?

        let imageView = ImageView()
        imageView.setImageAsynchronouslyWithDefaultImage(url: episode.smallArtworkImageURL)
        if let image = imageView.image {
            header = ActionSheetHeader(image: image, title: episode.title, description: episode.dateTimeLabelString)
        }

        let actionSheetViewController = ActionSheetViewController(options: [shareEpisodeOption], header: header)
        showActionSheetViewController(actionSheetViewController: actionSheetViewController)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = super.tableView(tableView, cellForRowAt: indexPath) as? SearchPeopleTableViewCell else { return UITableViewCell() }
        cell.followButton.isHidden = true
        return cell
    }
}
