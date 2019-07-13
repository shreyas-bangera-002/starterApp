//
//  HomeController.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

extension RawRepresentable where Self: CaseIterable, Self.RawValue == String {
    static var strings: [String] {
        return allCases.map({ $0.rawValue.capitalized })
    }
}

enum First: String, CaseIterable {
    case a, b, c, d
}
enum Second: String, CaseIterable {
    case x, y, z
}
enum DataSource: String, CaseIterable {
    case first, second
    var list: [String] {
        switch self {
        case .first:
            return First.strings
        case .second:
            return Second.strings
        }
    }
}

class HomeController: ViewController, WelcomeDelegate {
    
    lazy var list = TableView<String,String>().then {
        let sections = DataSource.strings
        $0.register(HomeTableCell.self)
        $0.header = { [weak self] table, index, item in
            return UILabel().then {
                $0.style(font: .header(16), color: .white, bgColor: .purple, alignment: .center)
                $0.text = sections[index]
                $0.addGesture(UITapGestureRecognizer { _ in
                    table.toggle(index)
                })
            }
        }
        $0.headerHeight = { _ in return 40 }
        $0.configureCell = { table, index, item in
            return table.dequeueCell(HomeTableCell.self, at: index, with: item)
        }
        $0.update(sections, items: [First.strings, Second.strings])
    }
    
    lazy var red = UIButton().then {
        $0.backgroundColor = UIColor.purple
        $0.onTap { b in
            UIView.animate(withDuration: 0.5, animations: {
                b.transform = CGAffineTransform(scaleX: 30, y: 30)
            }, completion: { [weak self] _ in
                self?.navigate(to: .welcome, transition: .overlay, delegate: self)
            })
        }
    }
    
    override func render() {
        view.sv(list, red)
        list.fillContainer()
        red.right(40).bottom(40).circle(80)
    }
    
    func didDismiss() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.red.transform = .identity
        })
    }
}

class HomeTableCell: TableViewCell, Configurable {
    func configure(_ item: String) {
        textLabel?.text = item
    }
}

class WelcomeController: ViewController {
    var stack: UIStackView!
    let texts = [
    "Hi, How are you?",
    "Are you ready?",
    "Your mission should you choose to accept it",
    "Good luck on your mission agent!",
    "This message will self destruct in 3 2 1"
    ]
    var currentText = -1
    override func render() {
        view.backgroundColor = .clear
        let close = UIButton().then {
            $0.style(bgColor: .magenta)
            $0.onTap { [weak self] _ in
                self?.close()
            }
        }
        view.sv(close)
        stack = view.vStack(UIView())
        stack.spacing = 10
        close.top(60).left(20).circle(40)
        stack.centerHorizontally().width(0.8).top(50)
        addLabel()
    }
    
    func close() {
        dismiss(animated: false, completion: { [weak self] in
            (self?.delegate as? WelcomeDelegate)?.didDismiss()
        })
    }
    
    func addLabel() {
        currentText += 1
        let text = texts[currentText]
        var index = 0
        let label = UILabel().then {
            $0.style(font: .header(16), color: .white, alignment: .center)
            $0.height(60)
            $0.multiLine()
        }
        stack.add(label)
        label.fillContainer()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] in
            label.text = text[0..<index]
            if text.count == index {
                $0.invalidate()
                self?.addTextField()
            }
            index += 1
        })
    }
    
    func addTextField() {
        guard currentText < texts.count-1 else {
            close()
            return
        }
        let textField = UITextField().then {
            $0.style(color: .white, bgColor: .magenta, alignment: .center)
            $0.on(.editingDidEnd, closure: { [weak self] _ in
                self?.addLabel()
            })
            $0.delegate = self
        }
        stack.add(textField)
        textField.top(0).bottom(0).centerHorizontally().width(0.6).roundedEdges(40)
        textField.becomeFirstResponder()
    }
}

extension WelcomeController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
protocol WelcomeDelegate: Delegate {
    func didDismiss()
}
