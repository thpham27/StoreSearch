//
//  ViewController.swift
//  StoreSearch
//
//  Created by Thanh Pham on 10/4/20.
//  Copyright © 2020 Thanh Pham. All rights reserved.
//


import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    struct TableView {
    struct CellIdentifiers {
        static let loadingCell = "LoadingCell"
      static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName:TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName:
            TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        searchBar.becomeFirstResponder()
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
    }


}
    extension SearchViewController: UISearchBarDelegate {
        
        func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
            
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()
                isLoading = true
                tableView.reloadData()
            hasSearched = true
            searchResults = []
                
        // 1
        let queue = DispatchQueue.global()
                // 2
        queue.async {
            let url = self.iTunesURL(searchText: searchBar.text!)

        if let data = self.performStoreRequest(with: url) {
            self.searchResults = self.parse(data: data)
            self.searchResults.sort(by: <)
        // 3
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData() }
        return
        } }
        }
        }
}
            /*
            . . . the networking code (commented out) . . . */

    extension SearchViewController: UITableViewDelegate,
                                     UITableViewDataSource {
        
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if isLoading {
         return 1
       } else if !hasSearched {
         return 0
       } else if searchResults.count == 0 {
         return 1
       } else {
         return searchResults.count
       }
     }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) }
        
        func tableView(_ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath) -> IndexPath? {
            if searchResults.count == 0 || isLoading {
                return nil
        } else {
            return indexPath
          }
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
        let cell = tableView.dequeueReusableCell(withIdentifier:
        TableView.CellIdentifiers.loadingCell, for: indexPath)
        let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
        spinner.startAnimating()
            return cell
          } else
       if searchResults.count == 0 {
         return tableView.dequeueReusableCell(withIdentifier:
           TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
       } else {
         let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
         let searchResult = searchResults[indexPath.row]
         cell.nameLabel.text = searchResult.name
        
         cell.artistNameLabel.text = searchResult.artistName
         return cell
       }
     }
        
        // MARK:- Helper Methods
        func iTunesURL(searchText: String) -> URL {
            let encodedText = searchText.addingPercentEncoding(
                withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
            let url = URL(string: urlString)
        return url!
        }
        
        func performStoreRequest(with url: URL) -> Data? {
            do {
                return try Data(contentsOf:url)
            }
            catch {
        print("Download Error: \(error.localizedDescription)")
                   showNetworkError()
        return nil
        } }
        
        func parse(data: Data) -> [SearchResult] {
            do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(ResultArray.self, from:data)
                return result.results
          } catch {
            print("JSON Error: \(error)")
        return [] }
        }
        
        func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...",
        message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default,
                                 handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        }
}



