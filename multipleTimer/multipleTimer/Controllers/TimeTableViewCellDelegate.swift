//
//  protocol.swift
//  multipleTimer
//
//  Created by 유준용 on 2021/09/15.
//

import Foundation
import UIKit

protocol TimeTableViewCellDelegate: AnyObject {
    func timerButtonClicked(at index: Int)
    func startTimeBox(at index: Int)
    func intervalCalculate(_startTime: Date, _at index: Int)->String
}
