//
//  FilterViewController.swift
//  EcoShop
//
//  Created by Sayed Shubbar Qasim on 23/12/2024.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func applyFilters(minPrice: Double?, maxPrice: Double?, metric: String?, minRating: Int?)
}

class FilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var minPriceTextField: UITextField!
    @IBOutlet weak var maxPriceTextField: UITextField!
    @IBOutlet weak var metricsPicker: UIPickerView!
    @IBOutlet weak var starButtonsStackView: UIStackView!
    
    weak var delegate: FilterDelegate?
    var metrics: [String] = [] // Metrics data from ProductViewController
    private var selectedMetric: String?
    private var selectedRating: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metricsPicker.delegate = self
        metricsPicker.dataSource = self
        setupStarButtons()
    }
    
    private func setupStarButtons() {
        let starButtons = starButtonsStackView.arrangedSubviews.compactMap { $0 as? UIButton }
        for (index, button) in starButtons.enumerated() {
            button.tag = index + 1
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        let starButtons = starButtonsStackView.arrangedSubviews.compactMap { $0 as? UIButton }
        for button in starButtons {
            button.setImage(
                UIImage(systemName: button.tag <= selectedRating! ? "star.fill" : "star"),
                for: .normal
            )
        }
    }
    
    // MARK: - UIPickerViewDelegate & DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return metrics.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return metrics[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMetric = metrics[row]
    }
    
    @IBAction func applyFiltersButtonTapped(_ sender: UIButton) {
        let minPrice = Double(minPriceTextField.text ?? "")
        let maxPrice = Double(maxPriceTextField.text ?? "")
        delegate?.applyFilters(
            minPrice: minPrice,
            maxPrice: maxPrice,
            metric: selectedMetric,
            minRating: selectedRating
        )
        dismiss(animated: true, completion: nil)
    }
}
