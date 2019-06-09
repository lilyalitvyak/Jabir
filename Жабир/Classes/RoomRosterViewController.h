//
//	jrtplib-static
//	RoomRosterViewController
//
//	Created by: Lilya Litvyak on 09/06/2019
//	Copyright (c) 2018 ipse.im
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomRosterViewController : UITableViewController

- (void)setupConference:(NSString*)conference forAccount:(NSString*)accountNo;

@end

NS_ASSUME_NONNULL_END
