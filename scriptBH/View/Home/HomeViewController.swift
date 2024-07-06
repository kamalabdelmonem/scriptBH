//
//  HomeViewController.swift
//  scriptBH
//
//  Created by Work on 04/07/2024.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var carouselCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    private var carouselViewModel = CarouselViewModel()
    private var listViewModel = ListViewModel()
    private var filteredItems: [ListItemModel] = []
    private var cancellables = Set<AnyCancellable>()
    private var listItemHeight = 48
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModels()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        setupScrollView()
        setupCarouselCollectionView()
        setupPageControl()
        setupSearchBar()
        setupTableView()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
    }
    
    private func setupCarouselCollectionView() {
        carouselCollectionView.dataSource = self
        carouselCollectionView.delegate = self
        carouselCollectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: CarouselCollectionViewCell.identifier)
    }
    
    private func setupPageControl() {
        pageControl.currentPage = 0
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search placeholder")
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.contentInset = .zero
    }
    
    // MARK: - Bind ViewModels
    private func bindViewModels() {
        bindCarouselViewModel()
        bindListViewModel()
    }
    
    private func bindCarouselViewModel() {
        carouselViewModel.fetchImages { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleFetchImagesResult(result)
            }
        }
    }
    
    private func handleFetchImagesResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            carouselCollectionView.reloadData()
            pageControl.numberOfPages = carouselViewModel.images.count
            selectInitialCarouselItemIfNeeded()
        case .failure(let error):
            handleFetchError(error)
        }
    }
    
    private func handleFetchError(_ error: Error) {
        print("Failed to fetch images: \(error.localizedDescription)")
        // Optionally show an alert to the user
        let alertController = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("Failed to load images.", comment: ""),
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alertController, animated: true)
    }
    
    private func selectInitialCarouselItemIfNeeded() {
        if !carouselViewModel.images.isEmpty {
            let firstIndexPath = IndexPath(item: 0, section: 0)
            carouselCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
            collectionView(carouselCollectionView, didSelectItemAt: firstIndexPath)
        }
    }
    
    private func bindListViewModel() {
        listViewModel.filteredItemsPublisher
            .sink { [weak self] filteredItems in
                self?.filteredItems = filteredItems
                self?.updateTableViewHeightAndReload()
            }
            .store(in: &cancellables)
    }
    
    private func updateTableViewHeightAndReload() {
        DispatchQueue.main.async {
            self.tableViewHeightConstraint.constant = CGFloat(self.filteredItems.count * self.listItemHeight)
            self.tableView.reloadData()
        }
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
        configureCellAppearance(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        listViewModel.fetchItems(forIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        animateCellAppearance(cell, at: indexPath)
    }
    
    // MARK: - UIScrollViewDelegate (for paging and centering)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        
        let pageWidth = collectionView.bounds.width
        let targetXContentOffset = targetContentOffset.pointee.x
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        var newPage = targetXContentOffset / pageWidth
        
        if velocity.x == 0 {
            newPage = round(targetXContentOffset / pageWidth)
        } else {
            newPage = velocity.x > 0 ? ceil(targetXContentOffset / pageWidth) : floor(targetXContentOffset / pageWidth)
        }
        
        if newPage < 0 {
            newPage = 0
        } else if newPage >= CGFloat(numberOfItems) {
            newPage = CGFloat(numberOfItems - 1)
        }
        
        targetContentOffset.pointee = CGPoint(x: newPage * pageWidth, y: 0)
    }
    
    // MARK: - Private Methods
    
    private func configureCellAppearance(_ cell: UICollectionViewCell) {
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 2
        cell.layer.shadowOpacity = 0.3
    }
    
    private func animateCellAppearance(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.item), options: .curveEaseInOut, animations: {
            cell.alpha = 1
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
}




// MARK: - UISearchBar Delegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let sanitizedText = sanitize(searchText)
        listViewModel.filterItems(with: sanitizedText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func sanitize(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(listItemHeight)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        animateCellAppearance(cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredItems[indexPath.row]
        print("Selected item: \(selectedItem.label)")
        // Perform any additional actions here, e.g., navigation, detail view presentation
    }
    
    private func animateCellAppearance(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0 * Double(indexPath.row), options: .curveEaseInOut, animations: {
            cell.alpha = 1
        }, completion: nil)
    }
}


// MARK: - UIScrollView Delegate
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == carouselCollectionView {
            handleCarouselScroll(scrollView)
        } else if scrollView == self.scrollView {
            handleMainScroll(scrollView)
        } else if scrollView == tableView {
            handleTableViewScroll(scrollView)
        }
    }
    
    private func handleCarouselScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        
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
    
    private func handleMainScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 230 {
            tableViewHeightConstraint.constant = scrollView.bounds.height - 50 // 50 is the search bar height
            scrollView.setContentOffset(CGPoint(x: 0, y: 230), animated: false)
        } else {
            tableViewHeightConstraint.constant = CGFloat(filteredItems.count * listItemHeight)
        }
    }
    
    private func handleTableViewScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.setContentOffset(CGPoint(x: 0, y: tableView.bounds.minX), animated: false)
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            tableViewHeightConstraint.constant = CGFloat(filteredItems.count * listItemHeight)
        }
    }
    
    private func updateCurrentIndexAfterScroll() {
        guard let visibleIndexPath = carouselCollectionView.indexPathsForVisibleItems.first else { return }
        carouselViewModel.updateCurrentIndex(visibleIndexPath.item)
    }
}
