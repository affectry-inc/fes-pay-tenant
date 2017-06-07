//
//  CompleteViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class CompleteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {

    // MARK: - Properties
    
    var payInfo: PayInfo?
    
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var summaryTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UITableViewDelegate setting
        summaryTable.delegate = self
        
        // UITableViewDataSource setting
        summaryTable.dataSource = self
        
        // UINavigationBarDelegate setting
        navBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UINavigationBarDelegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを作る
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if (indexPath.row == 0) {
            cell.textLabel?.text = "ID"
            cell.detailTextLabel?.text = self.payInfo?.bandId
        }
        else if (indexPath.row == 1) {
            cell.textLabel?.text = "金額"
            cell.detailTextLabel?.text = "¥" + String(format: "%.0f", (self.payInfo?.price)!)
        }
        else if (indexPath.row == 3) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            cell.textLabel?.text = "決済時刻"
            cell.detailTextLabel?.text = dateFormatter.string(from: (self.payInfo?.paidAt)!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数を設定
        return 4
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // セルの高さを設定
        return 50
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
