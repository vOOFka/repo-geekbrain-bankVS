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
    private lazy var circlesViewArray = [firstCircleView, secondCircleView, thirdCircleView, fourthCircleView]
    
    private lazy var buttonsArray = [oneNumberBtn, twoNumberBtn, threeNumberBtn, fourNumberBtn, fiveNumberBtn,
                                     sixNumberBtn, sevenNumberBtn, eightNumberBtn, nineNumberBtn, zeroNumberBtn,
                                     deleteBtn]
    
    private var pinNumbers: [Int] = []
    private let correctPin = "1111"
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
                .sink { [weak self, weak button] in
                    guard let button = button else {
                        return
                    }
                    print("Tapped", button.tag, String(button.accessibilityIdentifier ?? String()))
                    self?.buttonsTapHandler(button)
                }
                .store(in: &cancellables)
            
        }
    }
    
    private func buttonsTapHandler(_ button: UIButton) {
        if (0...9) ~= button.tag {
            if (0...3) ~= pinNumbers.count {
                pinNumbers.append(button.tag)
                coloringCircleView()
            }
        }
        
        if button.accessibilityIdentifier == "delete" || button.tag == 999 {
            coloringCircleView()
            if !pinNumbers.isEmpty {
                pinNumbers.removeLast()
            }
        }
        
        if pinNumbers.count == 4 {
            let pin = pinNumbers.map{ String($0) }.reduce("", +)
            if pin == correctPin {
                showError(message: "The PIN code is correct", title: "Congratulations") { [weak self] _ in
                    self?.cleanCircleViews()
                }
            } else {
                showError(message: "Invalid PIN Code") { [weak self] _ in
                    self?.cleanCircleViews()
                }
            }
        }
    }
    
    private func coloringCircleView() {
        let index = pinNumbers.count - 1
        if (0...3) ~= index {
            circlesViewArray[index]?.toggleState()
        }
    }
    
    private func cleanCircleViews() {
        pinNumbers.removeAll()
        circlesViewArray.forEach { $0?.toggleState() }
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

extension UIViewController {
    func showError(message: String, title: String? = "Error", handler: ((UIAlertAction) -> Void)? = nil) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: handler)
        
        alertViewController.addAction(closeAction)
        present(alertViewController, animated: true)
    }
}
