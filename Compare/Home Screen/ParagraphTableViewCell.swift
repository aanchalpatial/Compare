//
//  ParagraphTableViewCell.swift
//  Compare
//
//  Created by Aanchal Patial on 18/03/24.
//

import UIKit

class ParagraphTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    static let identifier = "ParagraphTableViewCell"

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
        descriptionLabel.text = nil
    }

    func configure(with description: String) {
        descriptionLabel.text = description
    }
}
