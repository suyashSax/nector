//  wordFeedVC.swift
//  Copyright © 2016 HackLAds. All rights reserved.
//  Nector

// ******** TO DO ************

//  1.
//  FIX CRASH ON LINE 256 (Array out of bounds exception):
//  You swipe left to delete your entry from other user's feeds. Then, you input a new word: their feed page crashes. Backend works correct.

/******* RESOLVED ^^^^ ********/

//  2.
//  Display error labels when feed has no words, esp. when children have been removed to empty the feed
//  HOW: self.err(state: true)
//  PROBLEM: Where to call the function? (how to check the feed is empty, given Firebase listeners are asynchronous?)

// ********************


import UIKit
import Firebase
import DeviceKit

var displayColor = UIColor.black

class wordFeedVC: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    var ArrayOfWords = [String]()
    var ArrayOfKeys = [String]()
    var count = 0
    var height: Int = 0
    var ArrayOfButtons = [UIButton]()
    var ArrayOfColors = [UIColor.black, UIColor.blue, UIColor.cyan, UIColor.gray, UIColor.green, UIColor.orange, UIColor.purple, UIColor.red]
    
    
    var whichButtonDeleted: Int = 0
    var whichButtonEmpty: Int = 0
    var buttonIsEmpty: Bool = false
    var colorGenerated: Int = 0
    
    
    var ref: FIRDatabaseReference = FIRDatabase.database().reference().child("Current")
    var myRef: FIRDatabaseReference = FIRDatabase.database().reference().child("Current").child(keys)
    var mySelected: FIRDatabaseReference = FIRDatabase.database().reference().child("Current").child(keys).child("selected")
    var myMatch: FIRDatabaseReference = FIRDatabase.database().reference().child("Current").child(keys).child("match")
    let storage: FIRDatabaseReference = FIRDatabase.database().reference().child("Data Store")
    
    
    @IBOutlet var errLabel1: UILabel!
    @IBOutlet var errLabel2: UILabel!
    @IBOutlet weak var gifImage: UIImageView!

    var errorState: Bool = true
    var timer: Timer = Timer()
    var whichGIFImageToDisplay: Int = 1
    
    var dataKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        err(state: true)
        
        ref.observe(.childAdded, with: {(snapshot) in
            
            let user = userObject(snapshot: snapshot)
            
            let userMessage = user.message as String?
            
            if userMessage != nil{
                
                if(user.key != keys && self.withinRadius(latx1: user.lat, lonx1: user.long, latx2: latitude, lonx2: longitude, rad: 35))
                {
                    
                    self.err(state: false)
                    
                    for index in 0...self.ArrayOfKeys.count-1{
                        if (self.ArrayOfKeys[index] == "0"){
                            self.whichButtonEmpty = index;
                            self.buttonIsEmpty = true
                            self.ArrayOfKeys[index] = user.key
                            self.ArrayOfWords[index] = userMessage!
                            break
                        }
                    }
                    
                    if(!self.buttonIsEmpty){
                        self.ArrayOfWords.append(userMessage!)
                        self.ArrayOfKeys.append(user.key)
                    }
                    
                    if (self.whichButtonEmpty != 0){
                        switch(self.whichColumn(argument: self.whichButtonEmpty)){
                        case 1:
                            self.createButton(xPos: 9, yPos: (((((self.whichButtonEmpty+1)/3)-1)*131)+90), message: userMessage!);
                            
                            self.height = (((((self.count+3)/4)-1)*266)+13) + 110;
                            break
                        case 2:
                            self.createButton(xPos: 117, yPos: (((((self.whichButtonEmpty+2)/3)-1)*131)+25), message: userMessage!);
                            
                            self.height = ((((self.count/2)-1)*130)+81) + 110
                            break
                        case 3:
                            self.createButton(xPos: 225, yPos: (((((self.whichButtonEmpty)/3)-1)*131)+90), message: userMessage!);
                            self.height = (((((self.count+1)/4)-1)*131)+80) + 110
                            break
                        default:
                            break
                        }
                        
                    }
                        
                    else{
                        self.count += 1
                        
                        switch(self.whichColumn(argument: self.count)){
                        case 1:
                            self.createButton(xPos: 9, yPos: (((((self.count+1)/3)-1)*131)+90), message: userMessage!);
                            
                            self.height = (((((self.count+3)/4)-1)*266)+13) + 110;
                            break
                        case 2:
                            self.createButton(xPos: 117, yPos: (((((self.count+2)/3)-1)*131)+25), message: userMessage!);
                            
                            self.height = ((((self.count/2)-1)*130)+81) + 110
                            break
                        case 3:
                            self.createButton(xPos: 225, yPos: (((((self.count)/3)-1)*131)+90), message: userMessage!);
                            self.height = (((((self.count+1)/4)-1)*266)+145) + 110
                            break
                        default:
                            break
                        }
                    }
                    
                    self.scrollView.contentSize.height = CGFloat(self.height)
                    self.buttonIsEmpty = false
                    
                }
            }
            
        })
        
        ref.observe(.childRemoved, with: {(snapshot) in
            
            let user = userObject(snapshot: snapshot)
            
            if user.key != keys && self.withinRadius(latx1: user.lat, lonx1: user.long, latx2: latitude, lonx2: longitude, rad: 25)
            {
                
                for index in 0...self.ArrayOfKeys.count-1{
                    if(user.key == self.ArrayOfKeys[index]){
                        
                        let buttonToDelete = self.ArrayOfButtons[index-1]
                        buttonToDelete.removeFromSuperview()
                        self.ArrayOfKeys[index] = "0"
                    }
                }
                
            }
            
        })
        
        self.myMatch.observe(FIRDataEventType.value, with: { (snapshot) in
            
            if !snapshot.exists(){
                print("waiting on color")
            }
                
            else{
                
                let color = snapshot.value as! String
                
                switch(color){
                case "0":
                    displayColor = self.ArrayOfColors[0]
                    break
                case "1":
                    displayColor = self.ArrayOfColors[1]
                    break
                case "2":
                    displayColor = self.ArrayOfColors[2]
                    break
                case "3":
                    displayColor = self.ArrayOfColors[3]
                    break
                case "4":
                    displayColor = self.ArrayOfColors[4]
                    break
                case "5":
                    displayColor = self.ArrayOfColors[5]
                    break
                case "6":
                    displayColor = self.ArrayOfColors[6]
                    break
                case "7":
                    displayColor = self.ArrayOfColors[7]
                    break
                default:
                    break
                    
                }
            }
        })
        
        mySelected.observe(FIRDataEventType.value, with: { (snapshot) in
            if !snapshot.exists()
            {
                print("Data snapshot doesn't exist...")
                return
            }
                
            else
            {
                let decision = snapshot.value as! Bool
                if (decision)
                {
                    print("Match Complete")
                    
                    displayMessage = self.ArrayOfWords[0]
                    
                    self.storage.child("\(self.dataKey)").child("foundMatch").setValue(true)
                    self.storage.child("\(self.dataKey)").child("wordSelected").setValue(true)
                    
                    self.performSegue(withIdentifier: "toMatch", sender: Any?.self)
                    self.ref.child(keys).removeValue()
                    
                }
                else
                {
                    print("No Matches... Yet")
                }
    
            }
            
        })
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background, target: nil)
        backgroundQueue.async {
            print("Run on background thread")
            
            // Updating Data Store
            self.dataKey = self.storage.childByAutoId().key
            
            self.myRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let me = userObject(snapshot: snapshot)
                
                //let post = dataStore(message: me.message, lat: me.lat, long: me.long,
                                     
                let post = dataStore(message: me.message, lat: me.lat, long: me.long, wordSelected: false, foundMatch: false)
                
                let childUpdates = ["/\(self.dataKey)/": post.getSnapshotValue()]
                
                self.storage.updateChildValues(childUpdates)
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            //
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func createButton(xPos: Int, yPos: Int, message: String){
        
        let button = UIButton(frame: CGRect(x: xPos, y: yPos, width: 139, height: 126))
        button.setBackgroundImage(#imageLiteral(resourceName: "HexagonLastScreen"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(buttonAction), for: UIControlEvents.touchUpInside)
        button.setTitle(message, for: UIControlState.normal)
        button.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        button.tag = self.count      //tag is the same as index positions in arrays
        //ArrayOfButtons.append(button)
        self.view.addSubview(button)
        
        if(self.buttonIsEmpty == true){
            button.tag = self.whichButtonEmpty
            ArrayOfButtons[self.whichButtonEmpty-1] = button
        }
        else{
            button.tag = self.count
            ArrayOfButtons.append(button)
        }
        
    }
    
    func buttonAction(sender: UIButton!){
        
        let buttonTag: UIButton = sender
        
        for index in 0...self.count{
            
            if((self.ArrayOfWords[index] == buttonTag.currentTitle) && buttonTag.tag == index){
                let key = ArrayOfKeys[index]
                
                displayMessage = ArrayOfWords[index]
                self.colorGenerated = Int(arc4random_uniform(8))
                displayColor = self.ArrayOfColors[colorGenerated]
                
                ref.child(key).child("match").setValue("\(self.colorGenerated)")
                ref.child(key).child("selected").setValue(true)
                ref.child(keys).removeValue()
                
                self.storage.child("\(dataKey)").child("foundMatch").setValue(true)
                
                performSegue(withIdentifier: "toMatch", sender: Any?.self)
            }
        }
        whichButtonDeleted = buttonTag.tag
    }
    
    func whichColumn(argument: Int)->Int{
        
        if((argument+2)%3 == 0){
            return 2
        }
        else if(argument%3 == 0) {
            return 3
        }
        return 1
    }
    
    func withinRadius(latx1: Double, lonx1: Double, latx2: Double, lonx2: Double, rad: Double) -> Bool
    {
        let R = 6371.0; // km
        
        // Rounding coordinates to 4 D.P. EXPERIMENTAL...
        
        var lat1 = round(latx1*10000)/10000
        var lat2 = round(latx2*10000)/10000
        let lon1 = round(lonx1*10000)/10000
        let lon2 = round(lonx2*10000)/10000
        
        print ("Rounded Lat 1 = \(lat1)")
        print ("Rounded Lat 2 = \(lat2)")
        
        let dLat = toRad(degrees: lat2-lat1);
        let dLon = toRad(degrees: lon2-lon1);
        lat1 = toRad(degrees: lat1);
        lat2 = toRad(degrees: lat2);
        
        let a1 = sin(dLat/2) * sin(dLat/2);
        let a2 = sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2)
        let a = a1 + a2
        let c = 2 * atan2(sqrt(a), sqrt(1-a));
        let d = R * c;
        
        print ("Distance: \(d*1000) meters.")
        
        //return true // EASY TESTING
        
        return (d*1000 < rad)
    }
    
    func toRad(degrees: Double) -> Double
    {
        return degrees * 22/7/180
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.ref.child(keys).removeValue()

        // Remove Firebase Observers
        ref.removeAllObservers()
        myRef.removeAllObservers()
        mySelected.removeAllObservers()
        myMatch.removeAllObservers()
    }
    
    func err(state: Bool)
    {
        self.errorState = state
        
        errLabel1.isHidden = !state
        errLabel2.isHidden = !state
        
        whichGIFImageToDisplay = 1
        
        let aSelector : Selector = #selector(wordFeedVC.updateTime) //calls the timer function
        timer = Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
    }
    
    func updateTime(){  //timer to animate the gif
        if (self.errorState == false){
            gifImage.image = nil
            self.timer.invalidate()
        }
        else{
            self.whichGIFImageToDisplay += 1
            
            gifImage.image = UIImage(named: "frame-\((self.whichGIFImageToDisplay % 119) + 1)")
            
        }
        
    }

    
}
