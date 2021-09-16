//
//  ViewController.swift
//  multipleTimer
//
//  Created by 유준용 on 2021/09/11.
//

import UIKit
//import CoreData

class ViewController: UIViewController {
    
    let dataManager = DataManager.shared
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBAction func addButton(_ sender: Any) {
        guard let AddVC = self.storyboard?.instantiateViewController(identifier: "AddVC")else{return}
        AddVC.modalPresentationStyle = .fullScreen
        present(AddVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        timeTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeTableView.delegate = self
        timeTableView.dataSource = self
        let nib = UINib(nibName: "TimeTableViewCell", bundle: nil)
        timeTableView.register(nib, forCellReuseIdentifier: "cell")
        dataManager.fetchTimeBox()
//        let container = NSPersistentContainer(name: "multipleTimer")
//          print(container.persistentStoreDescriptions.first?.url)
    }
}

extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.timeBoxList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.timeLabel.text! = "00:00:00"
        cell.titleLabel.text! = dataManager.timeBoxList[indexPath.row].timeTitle!
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
}
extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delAction = UIContextualAction(style: .destructive, title: "삭제"){ action, view, handler in
            self.dataManager.delTimeBox(self.dataManager.timeBoxList[indexPath.row])
            handler(true)
            self.timeTableView.reloadData()
        }
        let swipe = UISwipeActionsConfiguration.init(actions: [delAction])
        return swipe
    }
}

extension ViewController: TimeTableViewCellDelegate{

    func intervalCalculate(_startTime: Date, _at index: Int)-> String{
        guard let timeInterval = self.dataManager.timeBoxList[index].startTime?.distance(to: Date())else{
            return "STOP"
        }
        var intTime = [Int]()
        if timeInterval > 3600{
            intTime = [Int(timeInterval) % 60, (Int(timeInterval)/60)%60, Int(timeInterval) / 3600]
        }else if timeInterval > 60{
            intTime = [Int(timeInterval) % 60, (Int(timeInterval)/60), 0]
        }else{
            intTime = [Int(timeInterval) % 60,0,0]
        }
        var stringTime = [String]()
        for i in intTime{
            if i < 10{
                stringTime.append("0\(i)")
            }else{
                stringTime.append("\(i)")
            }
        }
        return "\(stringTime[2]):\(stringTime[1]):\(stringTime[0])"
    }
    
    func timerButtonClicked(at index: Int) {
        let cell = self.timeTableView.cellForRow(at: [0, index]) as? TimeTableViewCell
        
        if dataManager.timeBoxList[index].startOrStop == false{
            dataManager.timeBoxList[index].startTime = Date()
            let img = UIImage(systemName: "stop.circle")
            cell?.timerButton.setImage(img, for: .normal)
            cell?.timerButton.tintColor = .systemPink
            dataManager.timeBoxList[index].startOrStop.toggle()
            dataManager.saveContext()
            
            startTimeBox(at: index)

        }else{
            let img = UIImage(systemName: "play.circle")
            cell?.timerButton.setImage(img, for: .normal)
            cell?.timerButton.tintColor = .systemGreen
            dataManager.timeBoxList[index].startTime = nil
            dataManager.timeBoxList[index].startOrStop.toggle()
            dataManager.saveContext()
        }
    }

    func startTimeBox(at index: Int){
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            var stringTime = self.intervalCalculate(_startTime: Date(),_at: index)
            let cell = self.timeTableView.cellForRow(at: [0,index]) as? TimeTableViewCell
            if stringTime == "STOP"{
                timer.invalidate()
                stringTime = "00:00:00"
            }
            cell?.timeLabel.text! = stringTime
        }
    }
}
