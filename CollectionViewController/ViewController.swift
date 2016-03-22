//
//  ViewController.swift
//  CollectionViewController
//
//  Created by Gonzalo on 21/03/16.
//  Copyright © 2016 doapps. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    @IBOutlet weak var universityImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    var university: NSManagedObject!{
        didSet{
            updateUI()
        }
    }
    func updateUI(){
        let name = university.valueForKey("name") as! String
        let id = university.valueForKey("id") as! String
        self.title = name
        self.universityImageView.image = UIImage(named: name)
        self.idLabel.text = id
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
