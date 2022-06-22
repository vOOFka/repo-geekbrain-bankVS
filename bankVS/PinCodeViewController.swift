//
//  PinCodeViewController.swift
//  bankVS
//
//  Created by Home on 22.06.2022.
//

import UIKit

class PinCodeViewController: UIViewController {
    @IBOutlet weak var firstCircleView: CircleView!
    @IBOutlet weak var secondCircleView: CircleView!
    @IBOutlet weak var thirdCircleView: CircleView!
    @IBOutlet weak var fourthCircleView: CircleView!
    
    private var pinNumbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func oneBtnTap(_ sender: UIButton) {
        let newNumber = sender.tag
        print(newNumber)
        pinNumbers.append(newNumber)
    }
    
    @IBAction func deleteBtnTap(_ sender: UIButton) {
        if pinNumbers.count > 1 {
            pinNumbers.removeLast()
        }
    }
}
