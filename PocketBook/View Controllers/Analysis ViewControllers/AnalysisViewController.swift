//
//  AnalysisViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    var timeFrames: [String] {
        var array: [String] = []
        array.append(TimeFrame.pastYear.rawValue)
        array.append(TimeFrame.yearToDate.rawValue)
        array.append(TimeFrame.lastMonth.rawValue)
        array.append(TimeFrame.thisMonth.rawValue)
        return array
    }
    
    // MARK: - Outlets
    @IBOutlet weak var timeFrameButton: UIButton!
    @IBOutlet weak var timeFramePickerView: UIPickerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeFramePickerView.dataSource = self
        timeFramePickerView.delegate = self
        timeFramePickerView.isHidden = true
        timeFrameButton.setTitle(timeFrames[0], for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendTimeFrame), name: Notifications.viewControllerHasFinishedLoading, object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //sendTimeFrame()
    }
    
    // MARK: - Actions
    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        timeFramePickerView.isHidden = false
    }
    
    
    // MARK: - Notifications
    @objc func sendTimeFrame() {
        let userInfo = [Keys.timeFrameKey: timeFrameButton.titleLabel?.text]
        NotificationCenter.default.post(name: Notifications.sendingTimeFrameInfoToVCs, object: nil, userInfo: userInfo)
    }
    
    // MARK: - UIPickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeFrames.count
    }

    // MARK: - UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeFrames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let timeFrame = timeFrames[row]
        timeFrameButton.setTitle(timeFrame, for: .normal)
        sendTimeFrame()
        timeFramePickerView.isHidden = true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
 
}










