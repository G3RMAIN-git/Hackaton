//
//  TableViewController.swift
//  PoseFinder
//
//  Created by Quentin Bona on 18/10/2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    
    var poses: [Ghost] {SavedPoses.shared.poses}
    
    @IBOutlet var myTabView: UITableView!
    @IBAction func addNewGhost(_ sender: Any) {
        if let addVC =  storyboard?.instantiateViewController(withIdentifier: "AddPoseView")as? AddPoseView{
            addVC.delegate = self
            navigationController?.pushViewController(addVC, animated: true)
 
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        myTabView.delegate = self
        myTabView.dataSource = self
        myTabView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")

    }
    
}

extension TableViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        poses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell") as? CustomTableViewCell
        else{
            fatalError()
        }
       
        cell.setupCell(model: poses[indexPath.row])
        
        return cell
    }
}

extension TableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        SavedPoses.shared.selected = poses[indexPath.row]
    }
}
extension TableViewController: AddPoseViewDelegate {
    func dataChange() {
        myTabView.reloadData()
    }
}
