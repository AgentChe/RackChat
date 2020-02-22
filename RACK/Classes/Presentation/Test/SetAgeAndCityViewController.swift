//
//  SetAgeAndCityViewController.swift
//  RACK
//
//  Created by Alexey Prazhenik on 2/11/20.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import Foundation
import Amplitude_iOS
import NotificationBannerSwift

class SetAgeAndCityViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var topOffsetConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomOffsetConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var continueButton: UIButton!

    @IBOutlet private weak var dateOfBirthTextField: UITextField!
    @IBOutlet private weak var dateOfBirthTitleLabel: UILabel!
    
    @IBOutlet private weak var cityTextField: UITextField!
    @IBOutlet private weak var cityTitleLabel: UILabel!
        
    @IBOutlet private weak var citiesTableView: UITableView!
    @IBOutlet private weak var citiesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var citiesTableViewBottomConstraint: NSLayoutConstraint!

    private var citiesResults: [CityItem] = []
    private var selectedCityID: Int? = nil
    
    private var dateOfBirth: Int? {
        guard let dateOfBirthText = dateOfBirthTextField.text, let dateOfBirth = Int(dateOfBirthText) else {
            return nil
        }
        return dateOfBirth
    }

    var isDateOfBirthSelected: Bool {
        guard let yearOfBirth =  dateOfBirth else { return false }
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        return yearOfBirth > 1900 && yearOfBirth <= currentYear
    }
    
    var isCitySelected: Bool {
        guard let cityText = cityTextField.text else { return false }
        return cityText.count >= 3
    }

    private var keyboardHeight: CGFloat = 0.0
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(ScreenManager.ScreenManagerEntryTypes.showTest, forKey: ScreenManager.showKey)
        UserDefaults.standard.set(ScreenManager.ScreenManagerTestEntryScreen.birthdayAndCity, forKey: ScreenManager.currentScreen)

        ScreenManager.shared.onScreenController = self
        
        if UIDevice.current.small {
            topOffsetConstraint.constant = 20
            bottomOffsetConstraint.constant = 20
        }
        
        titleLabel.font = titleLabel.font.properForDevice
        subtitleLabel.font = subtitleLabel.font.properForDevice

        dateOfBirthTextField.delegate = self
        dateOfBirthTextField.setLeftPaddingPoints(12)
        
        cityTextField.delegate = self
        cityTextField.setLeftPaddingPoints(12)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapToHideKeyboard))
        tap.delegate = self
        scrollView.addGestureRecognizer(tap)
        
        activityIndicator.isHidden = true
        
        continueButton(disable: true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        dateOfBirthTextField.addTarget(self, action: #selector(ageValueChanged), for: .editingChanged)
        cityTextField.addTarget(self, action: #selector(cityValueChanged), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Amplitude.instance()?.log(event: .birthdayAndCityScr)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        dateOfBirthTextField.isHidden = false
        cityTextField.isHidden = false
        continueButton.isHidden = false
        activityIndicator.isHidden = true
    }
    
    // MARK: - UI
    
    private func continueButton(disable: Bool) {
        continueButton.isEnabled = !disable
        continueButton.alpha = disable ? 0.5 : 1.0
    }
            
    private func showCitiesPromts() {
        citiesTableView.isHidden = false
        citiesTableViewHeightConstraint.constant = CGFloat(min(citiesResults.count, 3)) * CGFloat(60.0)
        citiesTableViewBottomConstraint.constant = keyboardHeight
        citiesTableView.reloadData()
    }

    private func hideCitiesPromts() {
        DatingKit.cities.stopAll()

        citiesResults = []
        citiesTableView.isHidden = true
        citiesTableView.reloadData()
    }

    private func searchCity(withName name: String) {
        DatingKit.cities.stopAll()
        
        DatingKit.cities.startSearchCity(city: name) { [weak self] (items, status) in
            guard status == .succses else {
                self?.hideCitiesPromts()
                return
            }
            
            guard let cities = items, cities.count > 0 else {
                self?.hideCitiesPromts()
                return
            }
            
            self?.citiesResults = cities
            self?.showCitiesPromts()
        }

    }
            
    private func updateContinueButtonAvailability() {
        continueButton(disable: !(isDateOfBirthSelected && isCitySelected))
    }
    
    @IBAction func tapOnContinue(_ sender: UIButton) {
        if let _ = selectedCityID {
            updateUsersInfo()
        } else {
            guard let cityName = cityTextField.text, cityName.count >= 3 else { return }
            
            startLoading()
            DatingKit.cities.addCity(city: cityName) { [weak self] (cityID, status) in
                guard let self = self else { return }
                self.stopLoading()

                self.selectedCityID = cityID
                
                switch status {
                case .succses:
                    self.updateUsersInfo()
                    
                case .noInternetConnection:
                    self.showConnectionError()
                    
                default:
                    self.showErrorMessage()
                }
            }
            
        }
    }
    
    private func updateUsersInfo() {
        guard let yearOfBirth = dateOfBirth, let cityID = selectedCityID else { return }
        
        startLoading()
        DatingKit.user.set(birthYear: yearOfBirth, cityID: cityID) { [weak self] (status) in
            guard let self = self else { return }
            
            switch status {
            case .succses:
                self.performSegue(withIdentifier: "setGender", sender: nil)

            case .banned:
                self.stopLoading()
                self.performSegue(withIdentifier: "toYong", sender: nil)
                
            case .noInternetConnection:
                self.stopLoading()
                self.showConnectionError()
                
            default:
                self.stopLoading()
                self.showErrorMessage()
            }
        }
    }
            
    @objc func tapToHideKeyboard() {
        dateOfBirthTextField.resignFirstResponder()
        cityTextField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        hideCitiesPromts()
    }

    // MARK: - Helpers
    
    private func startLoading() {
        continueButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func stopLoading() {
        self.continueButton.isHidden = false
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }

    private func showErrorMessage() {
        let alertController = UIAlertController(title: "ERROR", message: "Can't Create account", preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    private func showConnectionError() {
        let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
        banner.show(on: self.navigationController)
    }

    private func showDateOfBirth(invalid: Bool) {
        dateOfBirthTextField.layer.borderWidth = invalid ? 1.0 : 0.0
    }

    private func showCity(invalid: Bool) {
        cityTextField.layer.borderWidth = invalid ? 1.0 : 0.0
    }
    
}

extension SetAgeAndCityViewController: UITextFieldDelegate {
    
    @objc func ageValueChanged() {
    }

    @objc func cityValueChanged() {
        selectedCityID = nil
        
        let text = cityTextField.text ?? ""
        if text.count > 0 {
            searchCity(withName: text)
        } else {
            hideCitiesPromts()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cityTextField, selectedCityID == nil, let text = textField.text, text.count > 0 {
            searchCity(withName: text)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == dateOfBirthTextField {
            showDateOfBirth(invalid: !isDateOfBirthSelected)
        } else if textField == cityTextField {
            showCity(invalid: !isCitySelected)
        }
        updateContinueButtonAvailability()
    }
    
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension SetAgeAndCityViewController {
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        keyboardHeight = keyboardFrame.size.height - self.view.safeAreaInsets.bottom
        
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardHeight + 100.0
        
        if cityTextField.isFirstResponder {
            contentInset.bottom += 100
        }
        
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }

}


extension SetAgeAndCityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = citiesResults[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityPromtCell") as! CityPromtCell
        cell.configure(with: city.name, highlightedText: cityTextField.text ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCity = citiesResults[indexPath.row]
        cityTextField.text = selectedCity.name

        selectedCityID = selectedCity.cityID
        
        cityTextField.resignFirstResponder()
        hideCitiesPromts()
    }
    
}


class CityPromtCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
        
    func configure(with name: String, highlightedText: String) {
        let attrString = NSMutableAttributedString(string: name)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.5)],
                                 range: NSMakeRange(0, name.count))

        let selectionRange = NSString(string: name.lowercased()).range(of: highlightedText.lowercased())
        attrString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                 range: selectionRange)
        
        nameLabel.attributedText = attrString
    }
    
}
