//
//  AuthenticationViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 2/8/13.
//  Copyright (c) 2013 Michael Ng. All rights reserved.
//

#import "AuthenticationViewController.h"
#import <Parse/Parse.h>
#import "ChatterboxDataStore.h"
#import "EditableCell.h"
#import "BlocksKit.h"

@interface AuthenticationViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property BOOL login;

- (IBAction)doneButton:(id)sender;

@end

@implementation AuthenticationViewController

-(id)initForLogin:(BOOL)login
{
    self = [super init];
    if (self) {
        self.login = login;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper_bg"]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 50)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont fontWithName:@"Cochin" size:24.0];
    self.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if (self.login) {
        self.doneButton.titleLabel.text = @"Login";
        self.titleLabel.text = @"Login";
    }
    else{
        self.doneButton.titleLabel.text = @"Sign Up";
        self.titleLabel.text = @"Sign Up";
    }
    
    self.tableView.tableHeaderView = self.titleLabel;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}
- (void)authenticate:(id)sender
{
    [self.tableView endEditing:YES];
    if (self.login) {
        [PFUser logInWithUsernameInBackground:self.username password:self.password block:^(PFUser *user, NSError *error){
            if (user){
                [self loadCoreDataObjectsForUser:[PFUser currentUser]];
                [self dismissModalViewControllerAnimated:YES];
            }
            else{
                NSString *errorString = [[error userInfo]objectForKey:@"error"];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else{
        PFUser *user = [PFUser user];
        user.username = self.username;
        user.password = self.password;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self dismissModalViewControllerAnimated:YES];
            } else {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (void)loadCoreDataObjectsForUser:(PFUser*)user
{
    /*PFUser *user = [ChatterboxDataStore fetchUser:user];
     if (!user) {
     PFQuery *query = [PFQuery queryWithClassName:@"User"];
     [query includeKey:@"conversations"];
     [query includeKey:@"]
     }*/
}

#pragma mark - UITableView data source methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            return 2;
            break;
        }
        case 1:{
            return 1;
            break;
        }
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *editableCellIdentifier = @"editableCell";
    static NSString *doneButtonCellIdentifier = @"doneButtonCell";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        EditableCell *eCell = [tableView dequeueReusableCellWithIdentifier:editableCellIdentifier];
        if (!cell) {
            eCell = [[EditableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editableCellIdentifier];
        }
        if (indexPath.row == 0) {
            eCell.textField.placeholder = @"Username";
            eCell.textField.secureTextEntry = NO;
            [eCell.textField removeAllBlockObservers];
            [eCell.textField addObserverForKeyPath:@"text" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
                self.username = [change valueForKey:NSKeyValueChangeNewKey];
            }];
        }else if (indexPath.row == 1){
            eCell.textField.placeholder = @"Password";
            eCell.textField.secureTextEntry = YES;
            [eCell.textField removeAllBlockObservers];
            [eCell.textField addObserverForKeyPath:@"text" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
                self.password = [change valueForKey:NSKeyValueChangeNewKey];
            }];
        }
        cell = eCell;
    }else if (indexPath.section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:doneButtonCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doneButtonCellIdentifier];
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(authenticate:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end
