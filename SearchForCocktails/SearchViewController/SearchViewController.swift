//
//  SearchViewController.swift
//  SearchForCocktails
//
//  Created by Евгений Таракин on 01.04.2022.
//

import UIKit
import SnapKit
import TagListView

class SearchViewController: UIViewController {

    // MARK: Property
    private let networkService = NetworkService()
    private var cocktailsArray: [Drink] = []
    private var searchedData: [Drink] = []
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    private lazy var tagListView: TagListView = {
        let tagListView = TagListView(frame: .zero)
        tagListView.tagBackgroundColor = .lightGray
        if view.frame.height < 850 {
            tagListView.textFont = .systemFont(ofSize: 11)
        } else {
            tagListView.textFont = .systemFont(ofSize: 14)
        }
        tagListView.cornerRadius = 8
        tagListView.delegate = self
        
        return tagListView
    }()
    
    private lazy var backViewTextField: UIView = {
        let backView = UIView()
        backView.backgroundColor = .white
        
        if view.frame.height > 600 {
            backView.addSubview(textField)
            textField.snp.makeConstraints { make in
                make.top.bottom.left.right.equalToSuperview()
            }
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(showAlert))
            backView.addGestureRecognizer(tap)
        }
        
        return backView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.placeholder = "Cocktail name"
        textField.textAlignment = .center
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var alertView: UIAlertController = {
        let view = UIAlertController(title: nil, message: "Поиск не поддерживается на данной модели iPhone", preferredStyle: .alert)
        view.addAction(UIAlertAction(title: "Продолжить", style: .default, handler: nil))
        return view
    }()
    
    // MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configurate()
        loadDrinks()
        searchedData = cocktailsArray
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        backViewTextField.layer.cornerRadius = 8
        backViewTextField.layer.shadowColor = UIColor.black.cgColor
        backViewTextField.layer.shadowRadius = 8
        backViewTextField.layer.shadowOffset = CGSize(width: 1, height: 1)
        backViewTextField.layer.shadowOpacity = 0.5
    }
    
    // MARK: Private func
    private func configurate() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(tagListView)
        tagListView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(12)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
            make.height.width.equalToSuperview()
        }
        
        contentView.addSubview(backViewTextField)
        backViewTextField.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(100)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(32)
        }
        
        registerForKeyboardNotifications()
    }
    
    private func loadDrinks() {
        networkService.getDrinksList { [self] (response, error) in
            guard let results = response?.drinks
            else { return }
            
            cocktailsArray.append(contentsOf: results.map({ (drinkResponse) -> Drink in
                return Drink(name: drinkResponse.strDrink ?? "")
            }))
            
            for i in 0...cocktailsArray.count - 1 {
                tagListView.addTag(cocktailsArray[i].name)
            }
        }
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func changeTextField(_ state: StateTextField) {
        switch state {
        case .active:
            backViewTextField.layer.cornerRadius = 0
            backViewTextField.snp.updateConstraints { make in
                make.left.right.equalToSuperview().inset(0)
            }
        case .notActive:
            backViewTextField.layer.cornerRadius = 8
            backViewTextField.snp.updateConstraints { make in
                make.left.right.equalToSuperview().inset(24)
            }
        }
    }
    
    // MARK: Obj-C
    @objc private func tapOnView() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var inset = scrollView.contentInset
            inset.bottom = keyboardSize.height
            scrollView.contentInset = inset
            changeTextField(.active)
        }
    }
    
    @objc private func keyboardWillHide() {
        scrollView.contentInset = .zero
        changeTextField(.notActive)
    }
    
    @objc private func showAlert() {
        self.present(alertView, animated: true, completion: nil)
    }
    
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchedData.removeAll()
        if textField.text?.count != 0 {
            for i in self.cocktailsArray {
                let isMachingWorker : NSString = (i.name) as NSString
                let range = isMachingWorker.lowercased.range(of: textField.text ?? "", options: NSString.CompareOptions.caseInsensitive, range: nil,   locale: nil)
                if range != nil {
                    searchedData.append(i)
                }
            }
        } else {
            searchedData = cocktailsArray
        }
        
        tapOnView()
        
        return true
    }
}

extension SearchViewController: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        let gradient = CAGradientLayer()
        gradient.frame = tagView.bounds
        gradient.masksToBounds = true
        tagView.isSelected.toggle()
        
        if tagView.isSelected {
            gradient.colors = [UIColor.red.cgColor, UIColor.systemPurple.cgColor]
            tagView.layer.insertSublayer(gradient, at: 0)
        } else {
            tagView.layer.sublayers?.remove(at: 0)
        }
    }
    
}
