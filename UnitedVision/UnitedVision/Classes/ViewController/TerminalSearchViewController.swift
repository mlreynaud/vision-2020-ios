//
//  MapViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import MapKit

class TerminalSearchViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var mapView: MapView!

    @IBOutlet weak var radiusTextField : UITextField!
    
    var selectedRadius =  50
    
    var radiusList : [String] = []

    var matchingItems: [MKMapItem] = []

    var locationArray: [LocationInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var value = 25
        for i in 0...20
        {
            radiusList.append(String(value))
            value += 25
        }
        
        self.title = "Terminal Search"
        mapView.initialSetup()
        
        self.fetchTerminalLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.navigationController?.viewControllers[0].isKind(of: TerminalSearchViewController.self) )!
        {
            self.setNavigationBarItem()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK-
        
    func fetchTerminalLocations()
    {
        LoadingView.shared.showOverlay()
        DataManager.sharedInstance.requestToFetchTractorLocations(completionHandler: {( status, tractorList) in
            
            LoadingView.shared.hideOverlayView()

            self.locationArray = tractorList! //DataManager.sharedInstance.tractorList
            self.addAnnotations()
            
            self.mapView.moveMapToCurrentLocation()
            
            let currentLocation = self.mapView.getCurrentLocation()
            self.mapView.addRadiusCircle(location: currentLocation)

        })
    }
    
    func addAnnotations(){
        
        var annotationList = [MKPointAnnotation]()
        
        for info in locationArray
        {
            let annotation = mapView.createAnnotation(coordinate: CLLocationCoordinate2DMake(info.latitude, info.longitude))
            
            annotation.title =  "Tractor ID - 1"
            annotation.subtitle = info.detail
            
            annotationList.append(annotation)
        }
        
        mapView.addAnnotationList(annotationList)
    }
   
}

extension TerminalSearchViewController : UITextFieldDelegate
{
    func createPickerView()
    {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.darkGray //UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(TerminalSearchViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(TerminalSearchViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        radiusTextField.inputView = pickerView
        radiusTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        
        radiusTextField.text = String("Radius: \(selectedRadius) mi")
        radiusTextField.resignFirstResponder()
        
        DataManager.sharedInstance.radius = selectedRadius
        
        let currentLocation = mapView.getCurrentLocation()
        mapView.addRadiusCircle(location: currentLocation)
//        self.view.endEditing(true)
    }
    @objc func cancelClick() {
        radiusTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.createPickerView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return radiusList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRadius =  Int(radiusList[row])!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return radiusList[row]
    }
}
