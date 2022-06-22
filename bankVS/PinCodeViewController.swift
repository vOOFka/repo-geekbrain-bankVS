//
//  PinCodeViewController.swift
//  bankVS
//
//  Created by Home on 22.06.2022.
//

import UIKit
import Combine

final class PinCodeViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var firstCircleView: CircleView!
    @IBOutlet weak var secondCircleView: CircleView!
    @IBOutlet weak var thirdCircleView: CircleView!
    @IBOutlet weak var fourthCircleView: CircleView!
    
    @IBOutlet weak var oneNumberBtn: UIButton!
    @IBOutlet weak var twoNumberBtn: UIButton!
    @IBOutlet weak var threeNumberBtn: UIButton!
    @IBOutlet weak var fourNumberBtn: UIButton!
    @IBOutlet weak var fiveNumberBtn: UIButton!
    @IBOutlet weak var sixNumberBtn: UIButton!
    @IBOutlet weak var sevenNumberBtn: UIButton!
    @IBOutlet weak var eightNumberBtn: UIButton!
    @IBOutlet weak var nineNumberBtn: UIButton!
    @IBOutlet weak var zeroNumberBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    // MARK: - Properties
    
    private lazy var buttonsArray = [oneNumberBtn, twoNumberBtn, threeNumberBtn, fourNumberBtn, fiveNumberBtn,
                                     sixNumberBtn, sevenNumberBtn, eightNumberBtn, nineNumberBtn, zeroNumberBtn,
                                     deleteBtn]
    
    private var pinNumbers: [Int] = []
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observedButtonsTaps()
    }
    
    // MARK: - Methods
    
    private func observedButtonsTaps() {
        for button in buttonsArray {
            guard let button = button else {
                break
            }
            
            button
                .publisher(forEvent: .touchUpInside)
                .sink { print("Tapped", button.tag) }
                .store(in: &cancellables)
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func oneBtnTap(_ sender: UIButton) {
        let newNumber = sender.tag
        pinNumbers.append(newNumber)
    }
    
    @IBAction func deleteBtnTap(_ sender: UIButton) {
        if pinNumbers.count > 1 {
            pinNumbers.removeLast()
        }
    }
}

// MARK: - Helpers and extensions

extension UIControl {
    func publisher(forEvent event: Event = .primaryActionTriggered) -> Publishers.Control {
        .init(control: self, event: event)
    }
}

extension Publishers {
    struct Control: Publisher {
        typealias Output = Void
        typealias Failure = Never
        
        private let control: UIControl
        private let event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Void == S.Input {
            subscriber.receive(subscription: Subscription(subscriber, control, event))
        }
        
        private class Subscription<S>: NSObject, Combine.Subscription where S: Subscriber, S.Input == Void, S.Failure == Never {
            private var subscriber: S?
            private weak var control: UIControl?
            private let event: UIControl.Event
            private var unconsumedDemand = Subscribers.Demand.none
            private var unconsumedEvents = 0
            
            init(_ subscriber: S, _ control: UIControl, _ event: UIControl.Event) {
                self.subscriber = subscriber
                self.control = control
                self.event = event
                super.init()
                
                control.addTarget(self, action: #selector(onEvent), for: event)
            }
            
            deinit {
                control?.removeTarget(self, action: #selector(onEvent), for: event)
            }
                        
            func request(_ demand: Subscribers.Demand) {
                unconsumedDemand += demand
                consumeDemand()
            }
            
            func cancel() {
                subscriber = nil
            }
            
            private func consumeDemand() {
                while let subscriber = subscriber, unconsumedDemand > 0, unconsumedEvents > 0 {
                    unconsumedDemand -= 1
                    unconsumedEvents -= 1
                    unconsumedDemand += subscriber.receive(())
                }
            }

            @objc private func onEvent() {
                unconsumedEvents += 1
                consumeDemand()
            }
        }
    }
}
