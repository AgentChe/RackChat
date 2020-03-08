//
//  TimeOutView.swift
//  RACK
//
//  Created by Алексей Петров on 02.11.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

final class TimeOutView: UIView {
    class func instanceFromNib() -> TimeOutView {
        UINib(nibName: "TimeOutView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! TimeOutView
    }
    
    var onNewSearch: (() -> ())?
    
    @IBAction private func newSearchAction(_ sender: Any) {
        onNewSearch?()
    }
}
