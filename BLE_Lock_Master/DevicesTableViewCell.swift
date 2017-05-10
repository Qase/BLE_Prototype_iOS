//
//  DevicesTableViewCell.swift
//  BLE_Lock_Master
//
//  Created by Martin Troup on 02/05/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import SnapKit

class DevicesTableViewCell: UITableViewCell {
    
    let title = UILabel()
    let subtitle = UILabel()
    let lastAdvertisationLabel = UILabel()
    
    var isEnabled: Bool = true {
        didSet {
            title.isEnabled = oldValue
            subtitle.isEnabled = oldValue
            lastAdvertisationLabel.isEnabled = oldValue
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let vStackView = UIStackView()
        vStackView.axis = .vertical
        
        self.contentView.addSubview(vStackView)
        vStackView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(10)
            make.right.bottom.equalToSuperview().offset(-10)
        }
        
        title.font = UIFont.boldSystemFont(ofSize: 15)
        vStackView.addArrangedSubview(title)
        
        subtitle.font = UIFont.systemFont(ofSize: 15)
        vStackView.addArrangedSubview(subtitle)
        
        lastAdvertisationLabel.font = UIFont.italicSystemFont(ofSize: 15)
        vStackView.addArrangedSubview(lastAdvertisationLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
