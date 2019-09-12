//
//  AlbumPickerViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

private let kAlbumCellIdentifier: String = "AlbumCellIdentifier"

class AlbumPickerViewController: UIViewController {

    // MARK: - Properties
    
    var columnCount: Int = 0
    var isFirstAppear: Bool = true
    
    var albumModels: [AlbumModel] = []
    
    private var imagePicker: ImagePickerController {
        return self.navigationController as! ImagePickerController
    }
    
    private var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Methods-[public]
    
    func fetchAlbums() {
        // 如果不许访问
        if !PhotoPickerManager.shared.authorizationStatusAuthorized() {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            PhotoPickerManager.shared.loadAllAlbums(allowPickingVideo: self.imagePicker.allowPickingVideo, needFetchAssets: true, completion: { (albums) in
                self.albumModels = albums
               
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        
    }
    
    // MARK: - View Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSubviews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 第一次显示时才加载数据
        if isFirstAppear {
            fetchAlbums()
            self.isFirstAppear = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper
    
    private func setupSubviews() {
        title = "相册"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(rightBarButtonClick))
        
        view.addSubview(tableView)
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AlbumCell.self, forCellReuseIdentifier: kAlbumCellIdentifier)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        }
    }
    
    // MARK: - Selector
    
    @objc
    private func rightBarButtonClick() {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}



// MARK: - UITableViewDataSource

extension AlbumPickerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kAlbumCellIdentifier, for: indexPath) as! AlbumCell
        cell.albumModel = albumModels[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AlbumPickerViewController: UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消选中效果
        tableView.deselectRow(at: indexPath, animated: true)
        // 如果相册没有照片的话不跳转
        if albumModels[indexPath.row].count == 0 { return }
        
        let vc = PhotoPickerViewController()
        vc.albumModel = albumModels[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

