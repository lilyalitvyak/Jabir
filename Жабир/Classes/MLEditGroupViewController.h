//
//  MLEditGroupViewController.h
//  Jabir
//
//  Created by Anurodh Pokharel on 4/1/18.
//  Copyright © 2018 Jabir.im. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEditGroupViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSDictionary *groupData; 

@end
