//
//  ListCollectionViewCell.swift
//  TVMOVIE
//
//  Created by beaunexMacBook on 5/24/24.
//

import UIKit
import SnapKit
import Kingfisher

final class ListCollectionViewCell: UICollectionViewCell {
    static let id = "ListCell"
    
    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
  
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let releaseDatelabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(image)
        addSubview(titleLabel)
        addSubview(releaseDatelabel)

        
        image.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(image.snp.trailing).offset(8)
   
        }
        releaseDatelabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel.snp.leading)
        }
    }
    
    public func configure(title: String, releaseDate: String, imageUrl: String) {
        titleLabel.text = title
        releaseDatelabel.text = releaseDate
        image.kf.setImage(with: URL(string: imageUrl))
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
