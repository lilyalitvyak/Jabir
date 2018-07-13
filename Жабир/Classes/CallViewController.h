//
//  CallViewController.h
//  Jabir
//
//  Created by Anurodh Pokharel on 12/22/13.
//
//

#import <UIKit/UIKit.h>

@interface CallViewController : UIViewController

@property (nonatomic, strong)  NSDictionary* contact;

/**
Icon of the person being called
 */
@property (nonatomic, weak) IBOutlet UIImageView* userImage;

/**
 The name of the person being called.
 */
@property (nonatomic, weak) IBOutlet UILabel* userName;

/**
 cancels the call and dismisses window
 */
-(IBAction)cancelCall:(id)sender;

@end
