//
//  ListTableViewCell.swift
//  scriptBH
//
//  Created by Work on 07/07/2024.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "ListTableViewCell"
    
    // Views
    private let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
    
    private let cellTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "Main")
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        self.selectionStyle = .none
        
        // Add subviews
        contentView.addSubview(mainView)
        mainView.addSubview(cellTitle)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // MainView constraints
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // CellTitle constraints
            cellTitle.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            cellTitle.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            cellTitle.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration Method
    func configure(with text: String) {
        cellTitle.text = text
    }
}
