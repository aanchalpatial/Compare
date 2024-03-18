//
//  ComparisonTableViewCell.swift
//  Compare
//
//  Created by Aanchal Patial on 18/03/24.
//

import UIKit

class ComparisonTableViewCell: UITableViewCell {

    @IBOutlet weak var verticalStackView: UIStackView!

    static let identifier = "ComparisonTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        verticalStackView.removeAllArrangedSubviews()
    }

    func configure(rows: [[String]]) {
        verticalStackView.spacing = 4.0
        for row in rows {
            let horizontalStackView = UIStackView()
            verticalStackView.addArrangedSubview(horizontalStackView)
            horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
            horizontalStackView.axis = .horizontal
            horizontalStackView.distribution  = .fillEqually
            horizontalStackView.alignment = .fill
            horizontalStackView.spacing   = 4.0
            for element in row {
                let label = UILabel()
                horizontalStackView.addArrangedSubview(label)
                if rows.first == row {
                    label.font = UIFont(name: "Avenir Heavy", size: 16)
                } else {
                    label.font = UIFont(name: "Avenir Medium", size: 15)
                }
                label.textColor = .darkGray
                label.numberOfLines = 0
                label.textAlignment = .left
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = element
            }
            let separator = UIView()
            verticalStackView.addArrangedSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.layer.cornerRadius = 0.5
            separator.clipsToBounds = true
            separator.backgroundColor = .lightGray
            separator.widthAnchor.constraint(equalTo: horizontalStackView.widthAnchor).isActive = true
            separator.leadingAnchor.constraint(equalTo: horizontalStackView.leadingAnchor, constant: 16).isActive = true
            separator.trailingAnchor.constraint(equalTo: horizontalStackView.trailingAnchor, constant: -16).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        }
    }
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
    }
}
