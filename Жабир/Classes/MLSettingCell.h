//
//  MLSettingCell.h
//  Jabir
//
//  Created by Anurodh Pokharel on 7/23/13.
//
//

#import <UIKit/UIKit.h>

@interface MLSettingCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, assign) BOOL switchEnabled;
@property (nonatomic, assign) BOOL switchActive;
@property (nonatomic, assign) BOOL textEnabled;
@property (nonatomic, weak) UIViewController *parent; 

/**
 NSuserdefault key to use
 */
@property (nonatomic, strong) NSString* defaultKey;

/**
 UIswitch
 */
@property (nonatomic, strong) UISwitch* toggleSwitch;

/**
 Textinput field
 */
@property (nonatomic, strong) UITextField* textInputField;

@end
