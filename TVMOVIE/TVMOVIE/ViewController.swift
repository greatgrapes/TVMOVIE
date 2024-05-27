//
//  ViewController.swift
//  TVMOVIE
//
//  Created by beaunexMacBook on 5/24/24.
//

import UIKit
import SnapKit
import RxSwift

// 레이아웃에 대한 기준을 잡고 Section을 잡음.
enum Section: Hashable {
    case double
    case banner
    case horizontal(String)
    case vertical(String)
}

//셀
enum Item: Hashable {
    case normal(Content) 
    case bigImage(Movie)
    case list(Movie)
}



class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    
    let buttonView = ButtonView()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.register(NormalCollectionViewCell.self, forCellWithReuseIdentifier: NormalCollectionViewCell.id)
        collectionView.register(BigImageCollectionViewCell.self, forCellWithReuseIdentifier: BigImageCollectionViewCell.id)
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.id)
        return collectionView
    }()
    
    let viewModel = ViewModel()
    // Subject - 이벤트를 발생시키면서, Observable 형태도 되는 것.
    let tvTrigger = PublishSubject<Void>()
    let movieTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDatasource()
        bindViewModel()
        bindView()
        
        tvTrigger.onNext(())
    }
    
    private func setUI() {
        self.view.addSubview(buttonView)
        self.view.addSubview(collectionView)
        
        //        collectionView.backgroundColor = .blue
        buttonView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(80)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        let input = ViewModel.Input(tvTrigger: tvTrigger.asObserver(), movieTrigger: movieTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        output.tvList.bind { [weak self] tvList in
            print(tvList)
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            let items = tvList.map { return Item.normal(Content(tv: $0))}
            let section = Section.double
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            self?.dataSource?.apply(snapshot)
        }.disposed(by: disposeBag)
        
        output.movieList.bind { movieResult in
            print(movieResult)
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            let bigImageList = movieResult.nowPlaying.results.map { movie in
                return Item.bigImage(movie)
            }
            let bannerSection = Section.banner
            snapshot.appendSections([bannerSection])
            snapshot.appendItems(bigImageList, toSection: bannerSection)
            
            let horizontalSection = Section.horizontal("Popular Movies")
            let normalList = movieResult.popular.results.map { movie in
                return Item.normal(Content(movie: movie))
            }
            snapshot.appendSections([horizontalSection])
            snapshot.appendItems(normalList, toSection: horizontalSection)
            
            let verticalSection = Section.vertical("Upcoming Movies")
            let itemList = movieResult.upcoming.results.map { movie in
                return Item.list(movie)
            }
            snapshot.appendSections([verticalSection])
            snapshot.appendItems(itemList, toSection: verticalSection)
            
            self.dataSource?.apply(snapshot)
        }.disposed(by: disposeBag)
    }
    
    private func bindView() {
        buttonView.tvButton.rx.tap.bind { [weak self] in
            self?.tvTrigger.onNext(Void())
        }.disposed(by: disposeBag)
        
        
        buttonView.movieButton.rx.tap.bind { [weak self] in
            self?.movieTrigger.onNext(Void())
        }.disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 14
        
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            
            switch section {
            case .banner:
                return self?.createBannerSection()
            case .horizontal:
                return self?.createHorizontalSection()
            case .vertical:
                return self?.createVerticalSection()
            default:
                return self?.createDoubleSection()
            }
            
        }, configuration: config)
    }
    
    private func createVerticalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        
        section.boundarySupplementaryItems = [header]
        return section
        
    }
    
    private func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(640))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private func createDoubleSection() -> NSCollectionLayoutSection {
        //아이템 정의
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4)
        
        //그룹 정의
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        //섹션 정의
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func setDatasource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            
            switch item {
            case .normal(let contentData):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NormalCollectionViewCell.id, for: indexPath) as? NormalCollectionViewCell else { return UICollectionViewCell() }
                cell.configure(title: contentData.title, review: contentData.vote, desc: contentData.overview, imageURL: contentData.posterURL)
                return cell
                
            case .bigImage(let movieData):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigImageCollectionViewCell.id, for: indexPath) as?
                BigImageCollectionViewCell
                
                cell?.configure(title: movieData.title, overview: movieData.overview, review: movieData.vote, imageUrl: movieData.posterURL)
                return cell
                
            case .list(let movieData):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as?
                ListCollectionViewCell
                
                cell?.configure(title: movieData.title, releaseDate: movieData.releaseDate, imageUrl: movieData.posterURL)
                return cell
            }
        })
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.id, for: indexPath)
            let section = self?.dataSource?.sectionIdentifier(for: indexPath.section)
            
            switch section {
            case .horizontal(let title), .vertical(let title):
                (header as? HeaderView)?.configure(title: title)
            default:
                print("Default")
                
            }
            return header
        }
    }
}

