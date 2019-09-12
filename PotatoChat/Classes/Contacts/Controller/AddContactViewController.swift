//
//  AddContactViewController.swift
//  WeChat
//
//  Created by 黄中山 on 2018/5/13.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

private let reuseIdentifier = "reuseIdentifier"

final class AddContactViewController: UIViewController {
    
    private lazy var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private lazy var searchBar: UISearchBar = UISearchBar(frame: .zero)
    private lazy var results: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "添加朋友"
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        searchBar.delegate = self
        view.addSubview(searchBar)
    
        tableView.estimatedRowHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        tableView.register(AddContactCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            searchBar.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


// MARK: - UITableViewDataSource
extension AddContactViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }
}


// MARK: - UITableViewDelegate
extension AddContactViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.endEditing(true)
        MessageClient.shared.addContact(results[indexPath.row], with: "很高兴认识你!") { (result) in
            switch result {
            case .success:
                SVProgressHUD.showSuccess(withStatus: "添加请求发送成功")
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        MessageClient.shared.addContact(results[indexPath.row], with: "很高兴认识你!") { (result) in
            switch result {
            case .success:
                SVProgressHUD.showSuccess(withStatus: "添加请求发送成功")
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}


// MARK: - UISearchBarDelegate
extension AddContactViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        results.removeAll()
        results.append(searchBar.text!)
        tableView.reloadData()
    }
}

final class AddContactCell: UITableViewCell {
    private lazy var addLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addLabel.frame.size = CGSize(width: 60, height: 30)
        addLabel.backgroundColor = UIColor.blue
        addLabel.textColor = UIColor.white
        addLabel.text = "添加"
        addLabel.textAlignment = .center
        accessoryView = addLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
