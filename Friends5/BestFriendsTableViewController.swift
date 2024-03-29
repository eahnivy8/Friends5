

import UIKit

class BestFriendsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib.init(nibName: "FriendTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "friendCell")
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadSections(IndexSet(0...0), with: UITableView.RowAnimation.none)
        
    }
}
// TABLEVIEW DATASOURCE
extension BestFriendsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Person.bestFriends.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FriendTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
        guard indexPath.row < Person.bestFriends.count else {
            return cell
        }
        let friend: Person = Person.bestFriends[indexPath.row]
        //configure the cell
        cell.configure(friend: friend, tableView: tableView, indexPath: indexPath)
        return cell
    }
}
extension BestFriendsTableViewController {
    // override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let friend: Person = Person.bestFriends[indexPath.row]
            Person.removeBestFriend(friend) { (isSuccess: Bool) in
                if isSuccess {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
// TableView Delegate
extension BestFriendsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell: UITableViewCell = tableView.cellForRow(at: indexPath) {
            self.performSegue(withIdentifier: "showFriendInfo", sender: cell)
        }
    }
}
//navigation controller
extension BestFriendsTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showFriendInfo" else { return }
        guard let cell: FriendTableViewCell = sender as? FriendTableViewCell else {
            return
        }
        guard let index: IndexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        guard index.row < Person.bestFriends.count else { return }
        guard let friendViewController: FriendViewController = segue.destination as? FriendViewController else {
            return
        }
        let friend: Person = Person.bestFriends[index.row]
        friendViewController.friend = friend
        friendViewController.thumbnailImage = cell.profileImageView.image
    }
}


