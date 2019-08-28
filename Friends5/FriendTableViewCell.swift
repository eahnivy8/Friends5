//
//  FriendTableViewCell.swift
//  Friends5
//
//  Created by Eddie Ahn on 28/08/2019.
//  Copyright © 2019 Eddie Ahn. All rights reserved.
//

import UIKit
// delegate
protocol FriendTableViewCellDelegate {
    func friendCellStarredStateChanged(_ sender: FriendTableViewCell)
}

class FriendTableViewCell: UITableViewCell {
    var delegate: FriendTableViewCellDelegate?
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!

    // methods
    @IBAction func touchUpStarButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let delegate = self.delegate {
            delegate.friendCellStarredStateChanged(self)
        }
    }
}

extension FriendTableViewCell {
    func configure(friend: Person, tableView: UITableView, indexPath: IndexPath) {
        self.nameLabel.text = friend.name.full
        self.nationalityLabel.text = friend.nationality
        self.cellLabel.text = friend.cell
        self.starButton.isSelected = Person.bestFriends.contains(friend)
        
        self.profileImageView.image = placeHolderImage
        Request.image(friend.pictureURL.thumbnail, completion:  { (image: UIImage?) in
            DispatchQueue.main.async {
                guard let cell: FriendTableViewCell = tableView.cellForRow(at:  indexPath) as? FriendTableViewCell else {
                    return
                }
                cell.profileImageView.image = image
            }
        })
    }
}
