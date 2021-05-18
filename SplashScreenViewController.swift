//
//  SplashScreenViewController.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 17/05/2021.
//

import Foundation
import UIKit

class SplashScreenViewController : UIViewController {
    
    var destination: UIViewController?
    var logoImageView: UIImageView? // This is the image view from before
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedLaunch" {
            destination = segue.destination
            destination?.view.backgroundColor = UIColor(red: 255, green: 230, blue: 0, alpha: 1.0)
            logoImageView = destination?.view.subviews.first(where: { $0 is UIImageView }) as? UIImageView
            logoImageView?.image = UIImage(named:"ML_Logo")
        }
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "EmbedLaunch" { // put this string in your Constants, or something...
        destination = segue.destination
        logoImageView = destination?.subviews.first(where: { $0 as? UIImageView }) ?? nil
      }
    }*/
}
