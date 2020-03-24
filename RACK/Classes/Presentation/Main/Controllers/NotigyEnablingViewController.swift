//
//  NotigyEnablingViewController.swift
//  RACK
//
//  Created by Алексей Петров on 03/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

enum NotifyCellTypes {
    case match
    case users
    case message
    case knocks
}

struct SwitchCellModel {
    var title: String
    var subtitle: String
    var enabled: Bool
    var type: NotifyCellTypes
}

class NotifyEnablingViewController: UIViewController {
    var cells: [SwitchCellModel] = [SwitchCellModel(title: "Messages",
                                                    subtitle: "Someone sent you a new message",
                                                    enabled: false,
                                                    type: .message),
                                    SwitchCellModel(title: "A Match!",
                                                    subtitle: "Your match is waiting for your reply",
                                                    enabled: false,
                                                    type: .match),
                                    SwitchCellModel(title: "Users online",
                                                    subtitle: "New user is looking for a match",
                                                    enabled: false,
                                                    type: .users),
                                    SwitchCellModel(title: "Knock-knocks",
                                                    subtitle: "When youre about to miss something cool going on",
                                                    enabled: false,
                                                    type: .knocks)]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "NotifySetingUiTableViewCell", bundle: .main), forCellReuseIdentifier: "NotifySetingUiTableViewCell")
        
        NotificationManager.shared.getSwither { [weak self] (result) in
            if result != nil {
                self?.cells = [SwitchCellModel(title: "Messages",
                                               subtitle: "Someone sent you a new message",
                                               enabled: result!.onMessage,
                                               type: .message),
                               SwitchCellModel(title: "A Match!",
                                               subtitle: "Your match is waiting for your reply",
                                               enabled: result!.onMatch,
                                               type: .match),
                               SwitchCellModel(title: "Users online",
                                               subtitle: "New user is looking for a match",
                                               enabled: result!.onUsers,
                                               type: .users),
                               SwitchCellModel(title: "Knock-knocks",
                                               subtitle: "When you're about to miss something cool going on",
                                               enabled: result!.onKnoks,
                                               type: .knocks)]
                self?.tableView.reloadData()
            }
        }
    }
}

extension NotifyEnablingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotifySetingUiTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NotifySetingUiTableViewCell", for: indexPath) as! NotifySetingUiTableViewCell
        cell.config(model: cells[indexPath.row])
        return cell
    }
}
