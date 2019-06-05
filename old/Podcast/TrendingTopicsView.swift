//
//  TrendingTopicsView.swift
//  Podcast
//
//  Created by Mindy Lou on 11/21/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

import UIKit

protocol TrendingTopicsViewDelegate: class {
    func trendingTopicsView(trendingTopicsView: TrendingTopicsView, didSelectItemAt indexPath: IndexPath)
}

enum TrendingTopicsViewType {
    case trending
    case related
}

class TrendingTopicsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var iconView: ImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var collectionView: UICollectionView!

    weak var dataSource: TopicsCollectionViewDataSource?
    weak var delegate: TrendingTopicsViewDelegate?

    let titleLabelText = "Trending Topics"
    let descriptionLabelText = "Find podcasts that everyone is talking about."
    let iconViewBorderPadding: CGFloat = 20
    let iconViewLength: CGFloat = 24
    let iconViewContentPadding: CGFloat = 10
    let titleDescriptionLabelPadding: CGFloat = 18
    let titleDescriptionLabelTopOffset: CGFloat = 22.5
    let descriptionLabelTopOffset: CGFloat = 7.5
    let descriptionCollectionViewPadding: CGFloat = 18
    let collectionViewTopOffset: CGFloat = 14.5
    let collectionViewBottomInset: CGFloat = 24
    let titleLabelHeight: CGFloat = 18
    let descriptionLabelHeight: CGFloat = 17

    let reuseIdentifier = "Cell"

    init(frame: CGRect, type: TrendingTopicsViewType) {
        super.init(frame: frame)
        backgroundColor = .offWhite

        titleLabel = UILabel()
        titleLabel.font = ._20SemiboldFont()
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(titleDescriptionLabelTopOffset)
            make.height.equalTo(titleLabelHeight)
            make.leading.equalToSuperview().offset(titleDescriptionLabelPadding)
        }

        descriptionLabel = UILabel()
        descriptionLabel.font = ._14RegularFont()
        descriptionLabel.textColor = .charcoalGrey
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .left
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(descriptionLabelTopOffset)
            make.leading.equalTo(titleLabel.snp.leading)
            make.height.equalTo(descriptionLabelHeight)
            make.trailing.equalToSuperview().inset(iconViewBorderPadding)
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: RecommendedTopicsCollectionViewFlowLayout(layoutType: .relatedTopics))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecommendedTopicsCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.width.leading.trailing.equalToSuperview()
            make.top.equalTo(descriptionLabel.snp.bottom).offset(collectionViewTopOffset).priority(999)
            make.bottom.equalToSuperview().inset(collectionViewBottomInset)
        }

        switch type {
        case .trending:
            titleLabel.text = "Trending Topics"
            descriptionLabel.text = "Find podcasts that everyone is talking about."
        case .related:
            titleLabel.text = "Related Topics"
            descriptionLabel.text = "You might be interested in these topics."
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfTopics(collectionView: collectionView) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? RecommendedTopicsCollectionViewCell,
            let podcastTopic = dataSource?.topicForCollectionViewCell(collectionView: collectionView, dataForItemAt: indexPath.row)
            else { return UICollectionViewCell() }
        cell.setup(with: podcastTopic)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.font = RecommendedTopicsCollectionViewCell.cellFont
        if let topic = dataSource?.topicForCollectionViewCell(collectionView: collectionView, dataForItemAt: indexPath.row){
            label.text = topic.name
        }
        label.sizeToFit()
        return CGSize(width: label.frame.width + 16, height: label.frame.height + 16)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.trendingTopicsView(trendingTopicsView: self, didSelectItemAt: indexPath)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
