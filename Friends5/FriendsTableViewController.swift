

import UIKit

class FriendsTableViewController: UITableViewController {
    private var friends: [Person] = []
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.backgroundColor = UIColor.lightGray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
}

extension FriendsTableViewController: FriendTableViewCellDelegate {
    func friendCellStarredStateChanged(_ sender: FriendTableViewCell) {
        guard let index: IndexPath = self.tableView.indexPath(for: sender) else {
            return
    }
    
    guard index.row < self.friends.count else {return}
    
        let friend: Person = self.friends[index.row]
    
    if sender.starButton.isSelected {
        Person.addBestFriend(friend)
    } else {
        Person.removeBestFriend(friend)
        }
    }
}


extension FriendsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FriendTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
        cell.delegate = self
        guard indexPath.row < self.friends.count else {
            return cell
        }
        let friend: Person = self.friends[indexPath.row]
        //configure the cell
        cell.configure(friend: friend, tableView: tableView, indexPath: indexPath)
        return cell
    }
}
//사용자가 셀을 선택했을 때 동작.
extension FriendsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell: UITableViewCell = tableView.cellForRow(at: indexPath) {
            self.performSegue(withIdentifier: "showFriendInfo", sender: cell)
        }
    }
}

//activity indicator 동작 코드
extension FriendsTableViewController {
    private func showActivityIndicator() {
        self.view.addSubview(self.indicator)
        let safeAreaLayoutGuide: UILayoutGuide = self.view.safeAreaLayoutGuide
        self.indicator.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        self.indicator.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        indicator.startAnimating()
        
    }
    
    private func hideActivityIndicator() {
        self.indicator.stopAnimating()
        self.indicator.removeFromSuperview()
    }
}
// request
extension FriendsTableViewController {
    @objc private func requestFriends() {
        if let isRefreshing: Bool = self.tableView.refreshControl?.isRefreshing,
            isRefreshing == false {
            self.showActivityIndicator()
        }
        Request.friends { (friends: [Person]?) in
            if let friends = friends {
                self.friends = friends
                self.tableView.reloadSections(IndexSet(0...0), with: UITableView.RowAnimation.automatic)
            }
            if let refreshControl: UIRefreshControl = self.tableView.refreshControl,
                refreshControl.isRefreshing == true {
                refreshControl.endRefreshing()
            } else {
                self.hideActivityIndicator()
                
            }
        }
    }
}

extension FriendsTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib: UINib = UINib.init(nibName: "FriendTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "friendCell")
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.requestFriends), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        self.tableView.refreshControl = refreshControl
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.friends.isEmpty {
            self.requestFriends()
            
        } else {
            self.tableView.reloadSections(IndexSet(0...0), with: UITableView.RowAnimation.none)
        }
        
    }
}
extension FriendsTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showFriendInfo" else { return }
        guard let cell: FriendTableViewCell = sender as? FriendTableViewCell else {
            return
    }
        guard let index: IndexPath = self.tableView.indexPath(for: cell) else {
            return
    }
        guard index.row < self.friends.count else { return }
        guard let friendViewController: FriendViewController = segue.destination as? FriendViewController else {
            return
}
        let friend: Person = self.friends[index.row]
        friendViewController.friend = friend
        friendViewController.thumbnailImage = cell.profileImageView.image
    }
}
