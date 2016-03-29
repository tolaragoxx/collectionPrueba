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
class toSend{
    var university: NSManagedObject!
    var courses: [NSManagedObject]?
    var periods: [NSManagedObject]?
    init(university: NSManagedObject,courses: [NSManagedObject],periods: [NSManagedObject]){
        self.university = university
        self.courses = courses
        self.periods = periods
    }
}

class CollectionViewController: UICollectionViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var loading = UIActivityIndicatorView()
    var universities = [NSManagedObject]()
    var periods = [NSManagedObject]()
    var courses = [NSManagedObject]()
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        if !NSUserDefaults.standardUserDefaults().boolForKey("periods"){
            self.downloadPeriods()
        }else{
            getPeriods()
        }
        if !NSUserDefaults.standardUserDefaults().boolForKey("courses"){
            self.downloadCourses()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "courses")
        }else{
            getCourses()
        }
        if !NSUserDefaults.standardUserDefaults().boolForKey("universities"){
             self.initLoading()
            self.downloadUniversities()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "universities")
        }else{
            getUniversities()
        }
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    func initLoading(){
        self.loading.center = self.view.center
        self.loading.activityIndicatorViewStyle = .Gray
        self.loading.hidesWhenStopped = true
        self.loading.startAnimating()
        self.view.addSubview(self.loading)
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    func configureCollectionView(){
         let leftAndRightPaddings : CGFloat = 12.0
         let numberOfItemsPerRow: CGFloat = 2.0
        let width = (CGRectGetWidth(collectionView!.frame) / numberOfItemsPerRow) - leftAndRightPaddings
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(width, 1.5 * width)
    }
    
    //MARK: - Download Universities
    func downloadUniversities(){
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        let session = NSURLSession(configuration: configuration)
        if let url = NSURL(string: "http://107.170.194.145:3000/api/Universities"){
            let urlRequest = NSURLRequest(URL: url)
            let task = self.session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
                guard let responseData = data else{
                    print("Could not get data on Universities")
                    return
                }
                guard error == nil else{
                    print("There was an error in universities",error?.localizedFailureReason)
                    return
                }
                var universities: NSArray
                do{
                    universities = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as! NSArray
                }catch let error as NSError{
                    print(error.localizedFailureReason)
                    return
                }
                for(var i = 0;i < universities.count;i++){
                    guard let university = universities[i] as? NSDictionary else{
                           print("One of the universities could not be downloaded restart the application please")
                            return
                    }
                    self.saveUniversities(university)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView?.reloadData()
                    self.loading.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                })
            }
                task.resume()
        }
    }
    func saveUniversities(university: NSDictionary){
        if let name = university.valueForKey("universityName") as? String,
        let id = university.valueForKey("id") as? String{
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
                print("Could not save a university \(error.localizedFailureReason)")
            }
        }
    }
    func getUniversities(){
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Universities")
        do{
            self.universities = try context.executeFetchRequest(request) as! [NSManagedObject]
        }catch let error as NSError  {
            print("Could not retrieve universities \(error.localizedFailureReason)")

        }
    }
    //MARK: - Download Periods
    func downloadPeriods(){
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        let session = NSURLSession(configuration: configuration)
        if let url = NSURL(string: "http://107.170.194.145:3000/api/Periods"){
            let urlRequest = NSURLRequest(URL: url)
            let task = self.session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
                guard let responseData = data else{
                    print("Could not get data in periods")
                    return
                }
                guard error == nil else{
                    print("There was an error in periods",error?.localizedFailureReason)
                    return
                }
                var periods: NSArray
                do{
                     periods = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as! NSArray
                }catch let error as NSError{
                    print(error.localizedFailureReason)
                    return
                }
                for(var i = 0;i < periods.count;i++){
                    guard let period = periods[i] as? NSDictionary else{
                        print("One of the periods could not be downloaded restart the application please")
                        return
                    }
                    self.savePeriods(period)
                }
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "periods")
            }
            task.resume()
        }
        else{
            print("Could not download periods check the URL")
        }
    }
    func savePeriods(period: NSDictionary){
        if let name = period.valueForKey("periodName") as? String,
            let id = period.valueForKey("id") as? String,
        let universityId = period.valueForKey("universityId") as? String{
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context: NSManagedObjectContext = appDel.managedObjectContext
                let entity = NSEntityDescription.entityForName("Periods", inManagedObjectContext: context)
                let newPeriod = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
                newPeriod.setValue(id, forKey: "id")
                newPeriod.setValue(name, forKey: "name")
                newPeriod.setValue(universityId, forKey: "universityId")
                do {
                    try context.save()
                    self.periods.append(newPeriod)
                    print(name,id,universityId)
                } catch let error as NSError  {
                    print("Could not save a period \(error.localizedFailureReason)")
                }
        }
        else{
            print("Wrong data from a period")
        }
    }
    func getPeriods(){
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Periods")
        do{
            self.periods = try context.executeFetchRequest(request) as! [NSManagedObject]
        }catch let error as NSError  {
            print("Could not retrieve periods \(error.localizedFailureReason)")
        }
    }
    //MARK: - Download Courses
    func downloadCourses(){
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        let session = NSURLSession(configuration: configuration)
        if let url = NSURL(string: "http://107.170.194.145:3000/api/Courses"){
            let urlRequest = NSURLRequest(URL: url)
            let task = self.session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
                guard let responseData = data else{
                    print("Could not get data in courses")
                    return
                }
                guard error == nil else{
                    print("There was an error in courses",error?.localizedFailureReason)
                    return
                }
                var courses: NSArray
                do{
                    courses = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as! NSArray
                }catch let error as NSError{
                    print(error.localizedFailureReason)
                    return
                }
                for(var i = 0;i < courses.count;i++){
                    guard let course = courses[i] as? NSDictionary else{
                        print("One of the courses could not be downloaded restart the application please")
                        return
                    }
                    self.saveCourses(course)
                }
            }
                task.resume()
        }
    }
    func saveCourses(course: NSDictionary){
        if let name = course.valueForKey("name") as? String,
            let id = course.valueForKey("id") as? String,
            let universityId = course.valueForKey("universityId") as? String{
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context: NSManagedObjectContext = appDel.managedObjectContext
                let entity = NSEntityDescription.entityForName("Courses", inManagedObjectContext: context)
                let newCourse = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
                newCourse.setValue(id, forKey: "id")
                newCourse.setValue(name, forKey: "name")
                newCourse.setValue(universityId, forKey: "universityId")
                do {
                    try context.save()
                    self.courses.append(newCourse)
                    print(name,id,universityId)
                } catch let error as NSError  {
                    print("Could not save a course \(error.localizedFailureReason)")
                }
        }
    }
    func getCourses(){
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Courses")
        do{
            self.courses = try context.executeFetchRequest(request) as! [NSManagedObject]
        }catch let error as NSError  {
            print("Could not retrieve periods \(error.localizedFailureReason)")
        }
    }

    //MARK: - Pass data to ViewController
    func periodsToSend(university: NSManagedObject) -> [NSManagedObject]{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Periods")
        request.predicate = NSPredicate(format: "universityId = %@", university.valueForKey("id") as! String)
        var periods: [NSManagedObject]!
        do{
            periods = try context.executeFetchRequest(request) as! [NSManagedObject]
        }catch let error as NSError  {
            print("Could not retrieve periods with predicate \(error.localizedFailureReason)")
        }
        return periods
    }
    func coursesToSend(university: NSManagedObject) -> [NSManagedObject]{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Courses")
        request.predicate = NSPredicate(format: "universityId = %@", university.valueForKey("id") as! String)
        var courses: [NSManagedObject]!
        do{
            courses = try context.executeFetchRequest(request) as! [NSManagedObject]
        }catch let error as NSError  {
            print("Could not retrieve courses with predicate \(error.localizedFailureReason)")
        }
        return courses
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
        let university = universities[indexPath.item]
        print(indexPath.item,university.valueForKey("name") as! String,university.valueForKey("id") as! String)
        let periods = periodsToSend(university)
        let courses = coursesToSend(university)
        let mandar = toSend(university: university, courses: courses, periods: periods)
        self.performSegueWithIdentifier("showCell", sender: mandar)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == cellShow{
            let vc = segue.destinationViewController as! ViewController
            vc.recibido = sender as? toSend
        }
    }
}
