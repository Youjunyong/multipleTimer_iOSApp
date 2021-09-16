//
//  TimeTableViewCell.swift
//  multipleTimer
//
//  Created by 유준용 on 2021/09/15.
//

import UIKit

class TimeTableViewCell: UITableViewCell {
    

    let dataManager = DataManager.shared
    weak var delegate : TimeTableViewCellDelegate!

    @IBOutlet weak var wrappingView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBAction func timerButton(_ sender: UIButton) {
        
        let wrappingView = sender.superview!
        let contentView = wrappingView.superview
        let cell = contentView?.superview as! UITableViewCell
        let tableView = cell.superview as! UITableView
        let indexPathRow = tableView.indexPath(for: cell)!.row
        delegate.timerButtonClicked(at: indexPathRow)
        
    }
    
    fileprivate func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 0.2)

    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        wrappingView.clipsToBounds = true
        wrappingView.layer.cornerRadius = wrappingView.frame.width/9
        wrappingView.backgroundColor = getRandomColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
