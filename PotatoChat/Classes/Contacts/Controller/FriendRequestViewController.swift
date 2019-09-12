//
//  FriendRequestViewController.swift
//  WeChat
//
//  Created by 黄中山 on 2018/5/18.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

private let reuseIdentifier = "reuseIdentifier"

class FriendRequestViewController: UIViewController {

    private lazy var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private lazy var results: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        loadData()
    }
    
    private func setupSubviews() {
        tableView.estimatedRowHeight = 0
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func loadData() {
        results = MessageClient.shared.loadFriendRequests()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - UITableViewDataSource
extension FriendRequestViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FriendRequestCell
        cell.delegate = self
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FriendRequestViewController: UITableViewDelegate {}


// MARK: - FriendRequestViewController
extension FriendRequestViewController: FriendRequestCellDelegate {
    
    /// 同意好友申请
    func friendRequestCell(_ cell: FriendRequestCell, clickApproveButton: UIButton) {
        clickApproveButton.isEnabled = false
        MessageClient.shared.approveFriendRequest(frome: cell.textLabel!.text!) { (result) in
            switch result {
            case .success(let username):
                SVProgressHUD.showSuccess(withStatus: "已成功添加\(username)为好友")
                MessageClient.shared.deleteFriendRequest(username)
                let index = self.results.firstIndex(of: username)!
                self.results.remove(at: index)
                self.tableView.reloadData()
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
            }
            clickApproveButton.isEnabled = true
        }
    }
    
    /// 拒绝好友申请
    func friendRequestCell(_ cell: FriendRequestCell, clickDeclineButton: UIButton) {
        clickDeclineButton.isEnabled = false
        MessageClient.shared.declineFriendRequest(from: cell.textLabel!.text!) { (result) in
            switch result {
            case .success(let username):
                SVProgressHUD.showSuccess(withStatus: "已拒绝\(username)的好友申请")
                MessageClient.shared.deleteFriendRequest(username)
                let index = self.results.firstIndex(of: username)!
                self.results.remove(at: index)
                self.tableView.reloadData()
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
            }
            clickDeclineButton.isEnabled = true
        }
    }
}


protocol FriendRequestCellDelegate: class {
    func friendRequestCell(_ cell: FriendRequestCell, clickApproveButton: UIButton)
    func friendRequestCell(_ cell: FriendRequestCell, clickDeclineButton: UIButton)
}

extension FriendRequestCellDelegate {
    func friendRequestCell(_ cell: FriendRequestCell, clickApproveButton: UIButton) {}
    func friendRequestCell(_ cell: FriendRequestCell, clickDeclineButton: UIButton) {}
}

final class FriendRequestCell: UITableViewCell {
    
    weak var delegate: FriendRequestCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupSubviews() {
        addSubview(approveButton)
        addSubview(declineButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width: CGFloat = 50
        let height: CGFloat = 30
        approveButton.frame = CGRect(x: bounds.width - width - 8, y: (bounds.height - height)/2, width: width, height: height)
        declineButton.frame = CGRect(x: approveButton.frame.minX - width - 8, y: (bounds.height - height)/2, width: width, height: height)
    }
    
    // MARK: - Selector
    @objc private func clickApproveButton(_ sender: UIButton) {
        delegate?.friendRequestCell(self, clickApproveButton: sender)
    }
    
    @objc private func clickDeclineButton(_ sender: UIButton) {
        delegate?.friendRequestCell(self, clickDeclineButton: sender)
    }
    
    // MARK: - Lazy properties
    private lazy var approveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("同意", for: .normal)
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action: #selector(clickApproveButton(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var declineButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("拒绝", for: .normal)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(clickDeclineButton(_:)), for: .touchUpInside)
        return button
    }()

}
