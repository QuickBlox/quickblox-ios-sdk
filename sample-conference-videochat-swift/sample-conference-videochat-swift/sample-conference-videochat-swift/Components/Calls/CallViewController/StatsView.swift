//
//  StatsView.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

struct StatsViewConstants {
    static let kQMStatsReportPlaceholderText = "Loading stats report..."
}

class StatsView: UIView {
    
    lazy private var statsLabel: UILabel = {
        let statsLabel = UILabel(frame: bounds)
        statsLabel.text = StatsViewConstants.kQMStatsReportPlaceholderText
        statsLabel.numberOfLines = 0
        statsLabel.font = UIFont(name: "Roboto", size: 12)
        statsLabel.adjustsFontSizeToFitWidth = true
        statsLabel.minimumScaleFactor = 0.6
        statsLabel.textColor = UIColor.green
        return statsLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(statsLabel)
        backgroundColor = UIColor(white: 0, alpha: 0.6)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStats(_ stats: String?) {
        var stats = stats
        if stats == nil {
            stats = StatsViewConstants.kQMStatsReportPlaceholderText
        }
        statsLabel.text = stats
    }
    
    override func layoutSubviews() {
        statsLabel.frame = bounds
    }
    
    override var isHidden: Bool {
        didSet {
            if isHidden == true {
                setStats(nil)
            }
        }
    }
}
