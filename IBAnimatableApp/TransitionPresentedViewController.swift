//
//  Created by Jake Lin on 5/16/16.
//  Copyright © 2016 Jake Lin. All rights reserved.
//

import UIKit
import IBAnimatable

class TransitionPresentedViewController: AnimatableViewController {

  @IBOutlet var gestureLabel: UILabel!
  @IBOutlet var presentViaSegueButton: AnimatableButton!
  @IBOutlet var presentViaDismissInteractionSegueButton: AnimatableButton!
  
  var presentingSegueClass: UIStoryboardSegue.Type?
  var presentingWithDismissInteractionSegueClass: UIStoryboardSegue.Type?
  
  // Intenal use for demo only
  var useDismissInteraction: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let animatableView = view as? AnimatableView {
      animatableView.predefinedGradient = String(generateRandomGradient())
    }
    
    configureGestureLabel()
    prepareSegues()
    hideButtonsIfNeeded()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepare(for: segue, sender: sender)
    
    // Set the transition animation type for `AnimatableViewController`, used for Present/Dismiss transitions
    if let toViewController = segue.destinationViewController as? AnimatableViewController {
      toViewController.transitionAnimationType = transitionAnimationType
      toViewController.interactiveGestureType = interactiveGestureType
    }
  }

  @IBAction func presentViaSegueDidTap(_ sender: AnyObject) {
    presentViaSegue(presentingSegueClass, useDismissInteraction: false)
  }
  
  @IBAction func presentViaDismissInteractionSegueDidTap(_ sender: AnyObject) {
    presentViaSegue(presentingWithDismissInteractionSegueClass, useDismissInteraction: true)
  }
}

private extension TransitionPresentedViewController {
  
  func configureGestureLabel() {
    // Shows nothing by default
    gestureLabel.text = ""
    
    // If `useDismissInteraction` is `false` then don't support gesture interaction
    guard useDismissInteraction else {
      return
    }
    
    // No gesture for this animator
    guard let interactiveGestureTypeString = self.interactiveGestureType,
      let interactiveGestureType = InteractiveGestureType.fromString(interactiveGestureTypeString),
      let transitionAnimationTypeString = self.transitionAnimationType,
      let transitionAnimationType = TransitionAnimationType.fromString(transitionAnimationTypeString) else {
        return
    }
    
    gestureLabel.text = retrieveGestureText(interactiveGestureType, transitionAnimationType: transitionAnimationType, exit: "dismiss")
  }
  
  func prepareSegues() {
    guard let transitionAnimationType = transitionAnimationType else {
      return
    }
    
    // Set up the segues without dismiss interaction
    var segueName = "IBAnimatable.Present" + extractAnimationType(transitionAnimationType) + "Segue"
    
    if let segueClass = NSClassFromString(segueName) as? UIStoryboardSegue.Type {
      presentingSegueClass = segueClass
    }
    
    // Set up the segues with dismiss interaction
    segueName = "IBAnimatable.Present" + extractAnimationType(transitionAnimationType) + "WithDismissInteractionSegue"
    
    if let segueClass = NSClassFromString(segueName) as? UIStoryboardSegue.Type {
      presentingWithDismissInteractionSegueClass = segueClass
    }
  }
  
  func hideButtonsIfNeeded() {
    // Hide them if the segue(s) don't exist
    if presentingSegueClass == nil {
      presentViaSegueButton.alpha = 0
    }
    
    if presentingWithDismissInteractionSegueClass == nil {
      presentViaDismissInteractionSegueButton.alpha = 0
    }
  }
  
  // To extract the type without parameters
  func extractAnimationType(_ animationType: String) -> String {
    if let range = animationType.range(of: "(") {
      return animationType.substring(to: range.lowerBound)
    }
    return animationType
  }
  
  func presentViaSegue(_ segueClass: UIStoryboardSegue.Type?, useDismissInteraction: Bool) {
    if let segueClass = segueClass, let toViewController = storyboard?.instantiateViewController(withIdentifier: "TransitionPresentedViewController") as? TransitionPresentedViewController {
      toViewController.useDismissInteraction = useDismissInteraction
      let segue = segueClass.init(identifier: String(segueClass), source: self, destination: toViewController)
      prepare(for: segue, sender: self)
      segue.perform()
    }
  }
 
}
