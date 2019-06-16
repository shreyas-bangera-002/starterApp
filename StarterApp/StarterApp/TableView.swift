//
//  TableView.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

struct List<Section,Item> {
    let section: Section?
    var items: [Item]?
    
    static func dataSource(sections: [Section?], items: [[Item]?]) -> [List<Section,Item>] {
        let diff = abs(sections.count - items.count)
        return List.list(sections: sections, items: items)
            .add(sections.count > items.count ?
                List.list(sections: sections.last(diff), items: Array(repeating: [], count: diff)) :
                List.list(sections: Array(repeating: nil, count: diff), items: items.last(diff)))
    }
    
    static func list(sections: [Section?], items: [[Item]?]) -> [List<Section,Item>] {
        return zip(sections, items).map({ .init(section: $0.0, items: $0.1) })
    }
}

class TableView<Section,Item>: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    private var data = [List<Section,Item>]()
    var original = [List<Section,Item>]()
    var isExpanded = [Bool]()
    var didSelect: ((TableView<Section,Item>, IndexPath, Item) -> Void)?
    var didDeSelect: ((TableView<Section,Item>, IndexPath, Item) -> Void)?
    var header: ((TableView<Section,Item>, Int, Section) -> UIView?)?
    var footer: ((TableView<Section,Item>, Int, Section) -> UIView?)?
    var headerHeight: ((Int) -> CGFloat)?
    var footerHeight: ((Int) -> CGFloat)?
    var configureCell: ((TableView<Section,Item>, IndexPath, Item) -> UITableViewCell)?
    
    convenience init() {
        self.init(frame: .zero, style: .plain)
        backgroundColor = .clear
        tableFooterView = UIView()
        dataSource = self
        delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = data[indexPath.section].items?[indexPath.row],
            let cell = configureCell?(self, indexPath, item) else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return }
        didSelect?(self, indexPath, item)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return }
        didDeSelect?(self, indexPath, item)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let item = data[section].section else { return nil }
        return header?(self, section, item)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let item = data[section].section else { return nil }
        return footer?(self, section, item)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return data[section].section.isNil ? 0 : headerHeight?(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return data[section].section.isNil ? 0 : footerHeight?(section) ?? 0
    }
    
    func update(_ items: [List<Section,Item>]) {
        isExpanded = Array(repeating: true, count: items.count)
        original = items
        data = items
        reloadData()
    }
    
    func toggle(_ section: Int) {
        isExpanded[section].toggle()
        data[section].items = isExpanded[section] ? original[section].items : .empty
        reloadSections([section], with: .automatic)
    }
}

class TableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    func render() {}
}

class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: nil)
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    func render() {}
}
