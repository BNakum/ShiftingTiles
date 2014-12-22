//
//  MainScreen.swift
//  TileGame
//
//  Created by Parker Lewis on 9/3/14.
//  Copyright (c) 2014 Parker Lewis. All rights reserved.
//


// ideas for more features:
// allow user to choose picture from camera or photo library
// enable hint button that will highlight the first piece out of position
// fix how the picture gets cut into pieces (some of the edges are not quite right)


import Foundation
import UIKit

class MainScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
                            
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var imageCycler: UIImageView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tilesPerRowLabel: UILabel!
    
    @IBOutlet weak var letsPlayButton: UIButton!
    
    var imageArray = [UIImage]()
    var imageToSolve = UIImage()
    var tilesPerRow = 3
    var drawGrid : DrawGrid?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
        
        
        // register the nibs for the two types of tableview cells
        let nib = UINib(nibName: "CollectionViewImageCell", bundle: NSBundle.mainBundle())
        self.imageCollection.registerNib(nib, forCellWithReuseIdentifier: "CELL")

        var imageGallery = ImageGallery()
        self.imageArray = imageGallery.imageArray
        self.imageToSolve = imageArray[0]
        self.imageCycler.image = imageArray[0]
        self.imageCycler.layer.borderColor = UIColor.blackColor().CGColor
        self.imageCycler.layer.borderWidth = 2


        stepper.value = 3
        self.tilesPerRow = Int(stepper.value)
        self.tilesPerRowLabel.text = "\(Int(stepper.value).description) Tiles Per Row"
        stepper.wraps = true
        stepper.autorepeat = true
        stepper.maximumValue = 10
        stepper.minimumValue = 2
        
        
        self.letsPlayButton.titleLabel?.adjustsFontSizeToFitWidth = true        
        self.letsPlayButton.layer.cornerRadius = 3
        self.letsPlayButton.layer.borderWidth = 2
        self.letsPlayButton.layer.borderColor = UIColor.blackColor().CGColor
        self.letsPlayButton.sizeToFit()
        
        
        
        
        
    }

    override func viewDidAppear(animated: Bool) {
        self.drawGrid?.removeFromSuperview()
        self.drawGrid = DrawGrid(frame: self.imageCycler.frame)
        self.drawGrid?.numRows = self.tilesPerRow
        self.drawGrid?.backgroundColor = UIColor.clearColor()
        self.drawGrid?.frame = self.imageCycler.frame
        self.view.addSubview(self.drawGrid!)
        

    }
    
    @IBAction func stepperPressed(sender: UIStepper) {
        self.tilesPerRowLabel.text = "\(Int(sender.value).description) Tiles Per Row"
        self.tilesPerRow = Int(sender.value)

        self.drawGrid?.removeFromSuperview()
        self.drawGrid = DrawGrid(frame: self.imageCycler.frame)
        self.drawGrid?.numRows = self.tilesPerRow
        self.drawGrid?.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.drawGrid!)

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var gameScreen = segue.destinationViewController as GameScreen

        gameScreen.imageToSolve = self.imageToSolve
        gameScreen.tilesPerRow = self.tilesPerRow
        
    }
    

    
    // Number of cells = number of images
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    // Cells will be square sized
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSize(width: self.imageCollection.frame.height * 0.9, height: self.imageCollection.frame.height * 0.9)

    }

    
    
    // Create cell from nib and load the appropriate image
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.imageCollection.dequeueReusableCellWithReuseIdentifier("CELL", forIndexPath: indexPath) as CollectionViewImageCell
        cell.imageView.image = self.imageArray[indexPath.row]
        return cell
        
    }
    
    // Selecting a cell loads the image to the main image view
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            println("selected item at index \(indexPath)")
        self.imageToSolve = imageArray[indexPath.row]
        self.imageCycler.image = imageArray[indexPath.row]

    }
    

    @IBAction func cameraButtonPressed(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            println("CAMERA AVAILABLE")
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            
            var noCameraAlert = UIAlertController(title: "", message: "No camera is available on this device", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            noCameraAlert.addAction(okAction)
            self.presentViewController(noCameraAlert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var imagePicked = info[UIImagePickerControllerEditedImage] as? UIImage
        
        
        var imageWidth  = imagePicked!.size.width
        var imageHeight  = imagePicked!.size.height
        var rect = CGRect()
        if ( imageWidth < imageHeight) {
            // Potrait mode
            rect = CGRectMake (0, (imageHeight - imageWidth) / 2, imageWidth, imageWidth);
        } else {
            // Landscape mode
            rect = CGRectMake ((imageWidth - imageHeight) / 2, 0, imageHeight, imageHeight);
        }
        
        var croppedCGImage = CGImageCreateWithImageInRect(imagePicked?.CGImage, rect)
        var croppedUIImage = UIImage(CGImage: croppedCGImage)
        
        self.imageToSolve = croppedUIImage!
        self.imageCycler.image = croppedUIImage!
        println("image selected from imagePicker")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        //this gets fired when the users cancel out of the process
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func gridButtonPressed(sender: AnyObject) {
        
        if self.drawGrid?.alpha == 0 {
            self.drawGrid?.alpha = 1
        } else {
            self.drawGrid?.alpha = 0
        }
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("MEMORY WARNING")
    }
    


}