//
//  ViewController.swift
//  Burhacline
//
//  Created by Burak Altunoluk on 28/01/2023.
//

import UIKit
import CoreBluetooth

class MainView: UIViewController, BluetoothHelperDelegate {
    
    let bluetoothHelper = BluetoothHelper()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statueInfo: UILabel!
    @IBOutlet weak var serialInputText: UITextField!
    var allData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.cornerRadius = 16
        view.isUserInteractionEnabled = true
        
        let gestur = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard1))
        view.addGestureRecognizer(gestur)
        NotificationCenter.default.addObserver(self, selector:#selector(doneResponse) , name: Notification.Name("done"), object: nil)
             
           
    }
    @objc func doneResponse() {
        self.statueInfo.text = "1"
    }
    func didDataReceived(data: String) {
        allData.insert(data, at: 0)
        tableView.reloadData()
    }
    
    func didErrorReceived(data: String) {
        
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if self.serialInputText.text != "" {
            bluetoothHelper.sendDataToDevice(self.serialInputText.text!)
            self.serialInputText.text = ""
        }
        
    }
    
    @IBAction func connectDeviceButtonPressed(_ sender: Any) {
        bluetoothHelper.startService(self)
        
    }
    
    @objc func hideKeyboard1() {
        
        view.endEditing(true)
        
    }
}

extension MainView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = allData[indexPath.row]
        return cell
    }
    
    
    
    
}
