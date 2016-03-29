//
//  ViewController.swift
//  CollectionViewController
//
//  Created by Gonzalo on 21/03/16.
//  Copyright © 2016 doapps. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate{
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var simulacroView: UIView!
    @IBOutlet weak var trainingView: UIView!
    var number = ["20","30","40","50","60","70","80","90","100"]
    @IBOutlet weak var periodosTF: UITextField!
    @IBOutlet weak var coursesTF: UITextField!
    @IBOutlet weak var numberTF: UITextField!
    var periodsPV = UIPickerView()
    var coursesPV = UIPickerView()
    var numbersPV = UIPickerView()
    var periodos: [NSManagedObject]?
    var courses: [NSManagedObject]?
    var recibido: toSend!{
        didSet{
            if let universityName = recibido.university.valueForKey("name") as? String{
                self.title = universityName
            }
            self.periodos = recibido.periods
            self.courses = recibido.courses
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        periodsPV.delegate = self
        periodsPV.dataSource = self
        coursesPV.delegate = self
        coursesPV.dataSource = self
        numbersPV.delegate = self
        numbersPV.dataSource = self
        periodosTF.inputView = periodsPV
        coursesTF.inputView = coursesPV
        numberTF.inputView = numbersPV
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped:")
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonTapped:")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        toolbar.setItems([cancelButton,flexibleSpace,doneButton], animated: true)
        periodosTF.inputAccessoryView = toolbar
        coursesTF.inputAccessoryView = toolbar
        numberTF.inputAccessoryView = toolbar
        self.trainingView.hidden = true
        if let periodosUnWrapped = periodos{
            for periodo in periodosUnWrapped{
                if let per = periodo.valueForKey("name") as? String{
                    print(per)
                }
            }
        }
        if let coursesUnWrapped = courses{
            for course in coursesUnWrapped{
                if let cour = course.valueForKey("name") as? String{
                    print(cour)
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    func cancelButtonTapped(sender: UIBarButtonItem){
        self.view.endEditing(true)
    }
    func doneButtonTapped(sender: UIBarButtonItem){
        self.view.endEditing(true)
    }

    
    @IBAction func categoryTapped(sender: UISegmentedControl) {
        self.view.endEditing(true)
        if sender.selectedSegmentIndex == 0{
            simulacroView.hidden = false
            trainingView.hidden = true
        }else if sender.selectedSegmentIndex == 1{
            simulacroView.hidden = true
            trainingView.hidden = false
        }
    }
    //DataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == periodsPV{
            if let periodosUnWrapped = periodos{
                return periodosUnWrapped.count
            }
        }else if pickerView == coursesPV{
            if let coursesUnWrapped = courses{
                return coursesUnWrapped.count
            }
        }
        return number.count
    }
    //Delegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        if pickerView == periodsPV{
            if let periodosUnWrapped = periodos{
                return periodosUnWrapped[row].valueForKey("name") as! String
            }
        }else if pickerView == coursesPV{
            if let coursesUnWrapped = courses{
                return coursesUnWrapped[row].valueForKey("name") as! String
            }
        }
        return number[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == periodsPV{
            if let periodosUnWrapped = periodos{
                self.periodosTF.text = periodosUnWrapped[row].valueForKey("name") as! String
            }
        }else if pickerView == coursesPV{
            if let coursesUnWrapped = courses{
                self.coursesTF.text = coursesUnWrapped[row].valueForKey("name") as! String
            }
        }else{
            self.numberTF.text = number[row]
        }
        

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
