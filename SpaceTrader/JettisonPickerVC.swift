//
//  JettisonPickerVC.swift
//  SpaceTrader
//
//  Created by Marc Auger on 3/19/16.
//  Copyright © 2016 Marc Auger. All rights reserved.
//

import UIKit

class JettisonPickerVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLabel: StandardLabel!
    @IBOutlet weak var secondLabel: StandardLabel!
    @IBOutlet weak var quantityLabel: PurpleHeader!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var cancelButtonOutlet: GrayButtonTurnsLighter!
    @IBOutlet weak var plunderButtonOutlet: PurpleButtonTurnsGray!

    
    let commodity = buySellCommodity!                      // this is stored as a global
    var max = 0                                             // set in viewDidLoad, based on operation
    // reference global "plunderAsOpposedToJettison"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set color of slider
        slider.tintColor = mainPurple
        
        // set page title & button name
        let controlState = UIControlState()
        if plunderAsOpposedToJettison {
            titleLabel.text = "Plunder \(commodity.rawValue)"
            plunderButtonOutlet.setTitle("Plunder", forState: controlState)
        } else {
            titleLabel.text = "Jettison \(commodity.rawValue)"
            plunderButtonOutlet.setTitle("Dump", forState: controlState)
        }
        
        // set max based on operation
        if plunderAsOpposedToJettison {
            // if plunder, get quantity of commodity on board opponent ship, player bays, take min
            let quantityAvailable = galaxy.currentJourney!.currentEncounter!.opponent.ship.getQuantity(commodity)
            let baysAvailable = player.commanderShip.baysAvailable
            max = min(quantityAvailable, baysAvailable)
        } else {
            // if jettison, get quantity on board player ship
            max = player.commanderShip.getQuantity(commodity)
        }
        
        // set slider max and min
        slider.minimumValue = 0
        slider.maximumValue = Float(max)
        slider.value = 0
        
        updateUI()
    }
    
    // set dark statusBar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func updateUI() {
        // set labels
        if plunderAsOpposedToJettison {
            firstLabel.text = "You can take up to \(max) bays of \(commodity.rawValue)."
            secondLabel.text = "How many would you like to take?"
            quantityLabel.text = "\(Int(slider.value)) bays"
        } else {
            firstLabel.text = "You can jettison up to \(max) bays of \(commodity.rawValue)."
            secondLabel.text = "How many would you like to jettison?"
            quantityLabel.text = "\(Int(slider.value)) bays"
        }
        
        
        // disable sell if quantity is zero
        if slider.value == 0 {
            plunderButtonOutlet.enabled = false
        } else {
            plunderButtonOutlet.enabled = true
        }
    }
    
    @IBAction func sliderMoved(sender: AnyObject) {
        updateUI()
    }
    
    
    @IBAction func plunderPressed(sender: AnyObject) {
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    @IBAction func plunderPressedOLD(sender: AnyObject) {
        if plunderAsOpposedToJettison {
            // add to player's ship
            player.commanderShip.addCargo(commodity, quantity: Int(slider.value), pricePaid: 0)
            
            // remove from opponent's ship
            galaxy.currentJourney!.currentEncounter!.opponent.ship.removeCargo(commodity, quantity: Int(slider.value))
            
            // close
            self.dismissViewControllerAnimated(false, completion: nil)
        } else {
            // confirm littering
            if !player.hasLitteredThisTrip {
                let title = "Space Littering"
                let message = "Dumping cargo in space is considered littering. If the police find your dumped goods and track them to you, this will influence your record. Do you really wish to dump?"
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive ,handler: {
                    (alert: UIAlertAction!) -> Void in
                    // dump, set littering flag, close
                    player.commanderShip.removeCargo(self.commodity, quantity: Int(self.slider.value))
                    player.hasLitteredThisTrip = true
                    self.dismissViewControllerAnimated(false, completion: nil)
                }))
                alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default ,handler: {
                    (alert: UIAlertAction!) -> Void in
                    // close window
                    self.dismissViewControllerAnimated(false, completion: nil)
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // don't bother if the player's already done it
                player.commanderShip.removeCargo(self.commodity, quantity: Int(self.slider.value))
                player.hasLitteredThisTrip = true
                self.dismissViewControllerAnimated(false, completion: nil)
            }
            
            
        }
    }
}