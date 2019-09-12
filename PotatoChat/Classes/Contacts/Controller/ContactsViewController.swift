//
//  ContactsViewController.swift
//  WeChat
//
//  Created by 黄中山 on 2017/11/21.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "cellReuseIdentifier"

final class ContactsViewController: BaseViewController {

    // MARK: - Properties
    
    private lazy var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private lazy var viewModel: ContactsViewModel = ContactsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSubviews()
        setupConstraints()
        registerReusableViews()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }
    
    private func setupSubviews() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 54
        tableView.sectionIndexColor = UIColor.darkGray
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "contacts_add_friend"), style: .plain, target: self, action: #selector(clickAddButton))
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
    
    private func registerReusableViews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    private func setupViewModel() {
        viewModel.reloadCollectionViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.showFriendRequestTip = { [weak self] in
            if let value = self?.tabBarItem.badgeValue, let count = Int(value) {
                self?.tabBarItem.badgeValue = "\(count + 1)"
            }
            self?.tabBarItem.badgeValue = "1"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Selector
    @objc private func clickAddButton() {
        let vc = AddContactViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MAKR: - UITableViewDataSource
extension ContactsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = viewModel.sortedKeys[section];
        return viewModel.list[key]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let key = viewModel.sortedKeys[indexPath.section]
        cell.textLabel?.text = (viewModel.list[key]!)[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        return viewModel.sortedKeys[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.sortedKeys
    }
}

// MARK: - UITableViewDelegate
extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.item) {
        case (0, 0):
            self.tabBarItem.badgeValue = nil
            let vc = FriendRequestViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            let sortedKey = viewModel.sortedKeys[indexPath.section]
            let userid = viewModel.list[sortedKey]![indexPath.item]
            if userid.isEmpty {
                debugPrint("跳转失败，没有userid")
                return
            }
            
            let vc = ChatViewController()
            vc.userid = userid
            navigationController?.pushViewController(vc, animated: true)
            MessageClient.shared.getConversation(by: userid)
        }
    }
}
