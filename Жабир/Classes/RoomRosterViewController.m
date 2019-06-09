//
//	jrtplib-static
//	RoomRosterViewController
//
//	Created by: Lilya Litvyak on 09/06/2019
//	Copyright (c) 2018 ipse.im
//


#import "RoomRosterViewController.h"
#import "DataLayer.h"

@interface RoomRosterViewController ()

@property (nonatomic, weak) IBOutlet UINavigationItem *titleItem;

@property (nonatomic, strong) NSArray* userNames;
@property (nonatomic, strong) NSString* conference;

@end

@implementation RoomRosterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.barController setTabBarWithHidden:YES animated:YES along:nil];
    [self makeTitle];
}

- (void)makeTitle {
    CGFloat width = self.view.frame.size.width - 60;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.font = [UIFont boldSystemFontOfSize: 14.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"Участники конференции\n%@", self.conference];
    
    self.titleItem.titleView = label;
}

- (void)setupConference:(NSString*)conference forAccount:(NSString*)accountNo {
    
    self.conference = conference;
    
    [[DataLayer sharedInstance] userNamesForConference:conference forAccount:accountNo withCompletion:^(NSArray *names) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userNames = names;
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mucUserNameCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.userNames objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

@end
