//
//  HomeViewController.swift
//  scriptBH
//
//  Created by Work on 04/07/2024.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    @IBOutlet weak var carouselCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    private var carouselViewModel = CarouselViewModel()
    private var listViewModel = ListViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var filteredItems: [ListItemModel] = [] // Store filtered items locally
    private var listItemHeight = 48
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModels()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup Carousel CollectionView
        carouselCollectionView.dataSource = self
        carouselCollectionView.delegate = self
        carouselCollectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: CarouselCollectionViewCell.identifier)
        carouselCollectionView.translatesAutoresizingMaskIntoConstraints = false

        // Setup Page Control
        pageControl.currentPage = 0
        
        // Setup Search Bar
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search placeholder")
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        // Setup TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func bindViewModels() {
        carouselViewModel.fetchImages { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.carouselCollectionView.reloadData()
                    self.pageControl.numberOfPages = self.carouselViewModel.images.count
                    if !self.carouselViewModel.images.isEmpty {
                        let firstIndexPath = IndexPath(item: 0, section: 0)
                        self.carouselCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
                        self.collectionView(self.carouselCollectionView, didSelectItemAt: firstIndexPath)
                    }
                case .failure(let error):
                    print("Failed to fetch images: \(error.localizedDescription)")
                }
            }
        }
        
        // Subscribe to updates in filteredItemsPublisher
        listViewModel.filteredItemsPublisher
            .sink { [weak self] filteredItems in
                self?.filteredItems = filteredItems // Store filtered items locally
                DispatchQueue.main.async {
                    self?.tableViewHeightConstraint.constant = CGFloat(filteredItems.count * (self?.listItemHeight ?? 0))
                    self?.tableView.reloadData() // Reload tableView with the latest filtered items
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carouselViewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCollectionViewCell.identifier, for: indexPath) as! CarouselCollectionViewCell
        let image = carouselViewModel.images[indexPath.item]
        cell.configure(with: image.imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Update currentCarouselIndex and fetch items for the new index
        listViewModel.fetchItems(forIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.04 * Double(indexPath.item), options: .curveEaseInOut, animations: {
            cell.alpha = 1
        }, completion: nil)
    }
}

// MARK: - UISearchBar Delegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        listViewModel.filterItems(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableView DataSource & Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        let item = filteredItems[indexPath.row]
        cell.configure(with: item.label)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 1, delay: 0.03 * Double(indexPath.row), options: .curveEaseInOut, animations: {
            cell.alpha = 1
        }, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.listItemHeight)
    }

}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == carouselCollectionView {
            // Calculate the current page based on the scroll position
            let width = scrollView.frame.width
            let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
            
            // Check if the current page has changed from the last known page
            if currentPage != pageControl.currentPage {
                pageControl.currentPage = currentPage
                listViewModel.fetchItems(forIndex: currentPage)
                searchBar.text = ""
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateCurrentIndexAfterScroll()
                }
            }
        }
    }
    
    private func updateCurrentIndexAfterScroll() {
        guard let visibleIndexPath = carouselCollectionView.indexPathsForVisibleItems.first else { return }
        carouselViewModel.updateCurrentIndex(visibleIndexPath.item)
    }
}
