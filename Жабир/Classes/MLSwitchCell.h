//
//  MLAccountCell.h
//  Jabir
//
//  Created by Anurodh Pokharel on 2/8/15.
//  Copyright (c) 2015 Jabir.im. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLSwitchCell : UITableViewCell

/**
 Label to the right
 */
@property  (nonatomic, weak) IBOutlet UILabel* cellLabel;

/**
 UIswitch
 */
@property  (nonatomic, weak) IBOutlet  UISwitch* toggleSwitch;

/**
 Textinput field
 */
@property  (nonatomic, weak) IBOutlet UITextField* textInputField;

@end
