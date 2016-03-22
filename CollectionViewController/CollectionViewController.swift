//
//  CollectionViewController.swift
//  CollectionViewController
//
//  Created by Gonzalo on 17/03/16.
//  Copyright © 2016 doapps. All rights reserved.
//

import UIKit
import CoreData
private let reuseIdentifier = "cell collection"
private let cellShow = "showCell"
class CollectionViewController: UICollectionViewController {
    private let leftAndRightPaddings : CGFloat = 12.0
    private let numberOfItemsPerRow: CGFloat = 2.0
    var universities = [NSManagedObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        if !NSUserDefaults.standardUserDefaults().boolForKey("universities"){
            self.dowloadUniversities()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "universities")
        }else{
            getUniversities()
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    func dowloadUniversities(){
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        let url = NSURL(string: "http://107.170.194.145:3000/api/Universities")
        let urlRequest = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
            guard let responseData = data else{
                print("Not could get data")
                return
            }
            guard error == nil else{
                print(error?.localizedDescription)
                return
            }
            var universities: NSArray
            do{
                universities = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as! NSArray
            }catch let error as NSError{
                print(error.localizedDescription)
                return
            }
            for(var i = 0;i < universities.count;i++){
                guard let university = universities[i] as? NSDictionary else{
                        break
                }
                self.saveUniversities(university)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView?.reloadData()
            })
        }
        task.resume()
    }
    func saveUniversities(university: NSDictionary){
        let name = university.valueForKey("universityName") as? String
        let id = university.valueForKey("id") as? String
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let entity = NSEntityDescription.entityForName("Universities", inManagedObjectContext: context)
        let newUniversity = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        newUniversity.setValue(name, forKey: "name")
        newUniversity.setValue(id, forKey: "id")
        do {
            try context.save()
            self.universities.append(newUniversity)
            print(name,id)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    func getUniversities(){
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Universities")
        do{
            self.universities = try context.executeFetchRequest(request) as! [NSManagedObject]
        }catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    func configureCollectionView(){
        let width = (CGRectGetWidth(collectionView!.frame) / numberOfItemsPerRow) - leftAndRightPaddings
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(width, 1.5 * width)
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return universities.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        cell.configureCellWith(universities[indexPath.item])
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.item)
//        let university = universities[indexPath.item]
//        print(university.valueForKey("id") as! String)
//        
//        self.performSegueWithIdentifier("showCell", sender: university)
    }
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showCell"{
//            if let vc = segue.destinationViewController as? ViewController{
//                 vc.university = sender as? NSManagedObject
//            }
//        }
//    }
}
