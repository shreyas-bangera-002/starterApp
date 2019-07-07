//
//  PlantController.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 06/07/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit
import Stevia

extension UIColor {
    static let plantBG = #colorLiteral(red: 0.9255588055, green: 0.9253922701, blue: 0.9339988828, alpha: 1)
    static let plantColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
    static let favBG = #colorLiteral(red: 0.6310636401, green: 0.7705437541, blue: 0.6404860616, alpha: 1)
}

enum PlantType: String, CaseIterable {
    case monstera, suculents, ferns
    
    var name: String {
        return rawValue.capitalized
    }
    
    var image: String {
        return rawValue
    }
    
    var desc: String {
        switch self {
        case .monstera:
            return "Monstera deliciosa, the ceriman, is a species of flowering plant native to tropical forests of southern Mexico, south to Panama.[1] It has been introduced to many tropical areas, and has become a mildly invasive species in Hawaii, Seychelles, Ascension Island and the Society Islands."
        case .suculents:
            return "In botany, succulent plants, also known as succulents, are plants that have some parts that are more than normally thickened and fleshy, usually to retain water in arid climates or soil conditions. The word \"succulent\" comes from the Latin word sucus, meaning juice, or sap.[1] Succulent plants may store water in various structures, such as leaves and stems. Some definitions also include roots, thus geophytes that survive unfavorable periods by dying back to underground storage organs may be regarded as succulents."
        case .ferns:
            return "A fern is a member of a group of vascular plants (plants with xylem and phloem) that reproduce via spores and have neither seeds nor flowers. They differ from mosses by being vascular, i.e., having specialized tissues that conduct water and nutrients and in having life cycles in which the sporophyte is the dominant phase. Ferns have complex leaves called megaphylls, that are more complex than the microphylls of clubmosses. Most ferns are leptosporangiate ferns, sometimes referred to as true ferns. They produce coiled fiddleheads that uncoil and expand into fronds.[3] The group includes about 10,560 known extant species."
        }
    }
}

class Plant {
    let name: String
    let image: String
    let desc: String
    var isFav: Bool = false
    var favImage: String {
        return isFav ? "favorite" : "unfavorite"
    }
    var favTint: UIColor {
        return isFav ? .red : .black
    }
    
    init(name: String, image: String, desc: String) {
        self.name = name
        self.image = image
        self.desc = desc
    }
}

class PlantController: ViewController {
    
    lazy var tableView = TableView<String,Plant>().then {
        $0.separatorStyle = .none
        $0.register(PlantCell.self)
        $0.configureCell = { $0.dequeueCell(PlantCell.self, at: $1, with: $2) }
        $0.didSelect = { [weak self] in self?.navigate(to: .plantDetail($2), transition: .push) }
        $0.update(List.dataSource(sections: .empty, items: [PlantType.allCases.map { Plant(name: $0.name, image: $0.image, desc: $0.desc) }]))
    }
    
    override func render() {
        registerKeyboardNotifications()
        let bgImage = UIImageView().then {
            $0.style("leaves", radius: 40)
            $0.isUserInteractionEnabled = true
        }
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        let textfield = TextField(left: 16, color: .black).then { $0.attributedPlaceholder = .text("Search", font: .title(18), color: #colorLiteral(red: 0.6574715376, green: 0.7316547036, blue: 0.734709084, alpha: 1)) }
        let label = Label().then { $0.style("Flower\nSchool", font: .header(40), color: .white, isMultiLine: true) }
        view.sv(bgImage.sv(label, blur, textfield), tableView)
        bgImage.top(44).left(10).right(10).heightEqualsWidth()
        label.Leading == textfield.Leading
        label.Bottom == textfield.Top - 20
        blur.top(60%).left(20).right(20).roundedEdges(50)
        textfield.followEdges(blur)
        tableView.left(25).right(10).bottom(0)
        tableView.Top == textfield.Bottom + 20
    }
    
    override func configureUI() {
        tableView.reloadData()
        tableView.scrollToRow(at: .init(row: 0, section: 0), at: .none, animated: false)
    }
    
    override func keyboardChanged(_ height: CGFloat) {
        tableView.contentInset.bottom = height
    }
}

class PlantCell: TableViewCell, Configurable {
    
    let bgView = UIView().then {
        $0.roundCorners([.layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 20)
        $0.backgroundColor = .plantBG
    }
    
    let plantImageView = UIImageView().then { $0.style() }
    
    let titleLabel = Label().then { $0.style(font: .header(24), color: .plantColor) }
    
    lazy var favButton = UIButton().then {
        $0.onTap { [weak self] in
            guard let plant = self?.plant else { return }
            plant.isFav.toggle()
            $0.image(plant.favImage, tint: plant.favTint)
        }
    }
    
    var plant: Plant!
    
    override func render() {
        sv(bgView.sv(favButton, plantImageView, titleLabel))
        bgView.top(0).left(0).right(0).bottom(20).height(200)
        plantImageView.width(50%).top(0).right(0).bottom(0)
        titleLabel.left(20).bottom(20)
        favButton.size(30).top(20).left(20)
    }
    
    func configure(_ item: Plant) {
        plant = item
        titleLabel.text = item.name
        plantImageView.image(item.image)
        favButton.image(item.favImage, tint: item.favTint)
    }
}

class PlantDetailController: ViewController {
    
    let pageControl = UIPageControl().then {
        $0.numberOfPages = 3
        $0.pageIndicatorTintColor = .gray
        $0.currentPageIndicatorTintColor = .white
    }
    
    var plant: Plant!
    
    convenience init(_ plant: Plant) {
        self.init()
        self.plant = plant
    }
    
    override func render() {
        let back = UIButton().then {
            $0.style(imageName: "back")
            $0.onTap { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        }
        let share = UIButton().then {
            $0.style(imageName: "share")
        }
        let plantImageView = UIImageView().then {
            let overlay = UIView().then { $0.backgroundColor = UIColor.black.withAlphaComponent(0.1) }
            $0.sv(overlay)
            overlay.fillContainer()
            $0.style(plant.image, mode: .scaleAspectFit, bgColor: .plantBG)
            $0.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 30)
            $0.isUserInteractionEnabled = true
        }
        let detailView = UIView().then {
            $0.backgroundColor = .white
            $0.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 40)
        }
        let titleLabel = UILabel().then {
            $0.style(plant.name, font: .header(30), color: .plantColor)
        }
        let favButton = UIButton().then {
            $0.style(bgColor: .favBG)
            $0.layer.cornerRadius = 13
            let fav = UIImageView().then { $0.style(plant.favImage, tint: plant.favTint) }
            $0.sv(fav)
            fav.size(30).centerInContainer()
            $0.onTap { [weak self] _ in
                guard let plant = self?.plant else { return }
                plant.isFav.toggle()
                fav.style(plant.favImage, tint: plant.favTint)
            }
        }
        let descLabel = UILabel().then { $0.style(plant.desc, font: .title(18), color: .plantColor, isMultiLine: true) }
        view.sv(plantImageView.sv(back, share), detailView.sv(titleLabel, descLabel), favButton, pageControl)
        plantImageView.top(44).left(10).right(10).heightEqualsWidth()
        detailView.left(10).right(10).bottom(0)
        plantImageView.Bottom == detailView.Top + 40
        back.size(24).top(20).left(30)
        share.size(30).top(20).right(30)
        titleLabel.top(20).left(20)
        descLabel.left(20).right(20)
        descLabel.Top == titleLabel.Bottom + 10
        favButton.size(52).right(10%)
        favButton.Bottom == detailView.Top + 22
        pageControl.centerHorizontally()
        pageControl.Bottom == detailView.Top - 10
    }
}
