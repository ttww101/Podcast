//
//  TopicTableViewHeader.swift
//  Podcast
//
//  Created by Natasha Armbrust on 3/12/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

import UIKit

enum TopicTableViewHeaderType {
    case seriesHeader
    case episodesHeader
}

protocol TopicTableViewHeaderDelegate: class {
    func topicTableViewHeaderDidPressViewAllButton(view: TopicTableViewHeader)
}

class TopicTableViewHeader: UIView {
    
    let edgePadding: CGFloat = 20
    var mainLabel: UILabel!
    var viewAllButton: UIButton!
    var type: TopicTableViewHeaderType?
    weak var delegate: TopicTableViewHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainLabel = UILabel(frame: CGRect(x: edgePadding, y: 0, width: frame.width*3/4, height: frame.height))
        mainLabel.text = "Doggos You Might Enjoy"
        mainLabel.font = ._14SemiboldFont()
        mainLabel.textColor = .charcoalGrey
        
        viewAllButton = UIButton(frame: CGRect.zero)
        viewAllButton.addTarget(self, action: #selector(didPressViewAllButton), for: .touchUpInside)
        viewAllButton.center.y = mainLabel.center.y
        let attributedTitle = NSAttributedString(string: "View all", attributes: [NSAttributedStringKey.foregroundColor: UIColor.sea, NSAttributedStringKey.font: UIFont._12RegularFont()])
        viewAllButton.setAttributedTitle(attributedTitle, for: .normal)
        viewAllButton.sizeToFit()
        viewAllButton.center.y = mainLabel.center.y
        viewAllButton.frame.origin.x = frame.width - viewAllButton.frame.width - edgePadding
        addSubview(mainLabel)
        addSubview(viewAllButton)
    }
    
    func configure(sectionName: String) {
        mainLabel.text = sectionName
        
        if type == .episodesHeader {
            viewAllButton.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainLabel.frame = CGRect(x: edgePadding, y:0, width:frame.width*3/4, height:frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didPressViewAllButton() {
        delegate?.topicTableViewHeaderDidPressViewAllButton(view: self)
    }
}
