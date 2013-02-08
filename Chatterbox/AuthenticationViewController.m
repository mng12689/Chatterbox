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

@interface AuthenticationViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper_bg"]];
    
    if (self.login) {
        self.doneButton.titleLabel.text = @"Login";
        self.titleLabel.text = @"Login";
    }
    else{
        self.doneButton.titleLabel.text = @"Sign Up";
        self.titleLabel.text = @"Sign Up";
    }
    self.passwordTextField.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setDoneButton:nil];
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [super viewDidUnload];
}
- (IBAction)doneButton:(id)sender
{
    if (self.login) {
        [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error){
            if (user)
            {
                [self loadCoreDataObjectsForUser:[PFUser currentUser]];
                [self dismissModalViewControllerAnimated:YES];
            }
            else
            {
                NSString *errorString = [[error userInfo]objectForKey:@"error"];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else{
        PFUser *user = [PFUser user];
        user.username = self.usernameTextField.text;
        user.password = self.passwordTextField.text;
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
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
    static NSString *usernameCellIdentifier = @"usernameCell";
    static NSString *passwordCellIdentifier = @"passwordCell";
    static NSString *doneButtonCellIdentifier = @"doneButtonCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:usernameCellIdentifier];
    
    if (indexPath.section == 0) {
        UITextField *textField = [[UITextField alloc]initWithFrame:cell.frame];
        if (indexPath.row == 0) {
            textField.placeholder = @"Username";
        }else if (indexPath.row == 1){
            textField.placeholder = @"Password";
        }
    }else if (indexPath.section == 1){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Done" forState:UIControlStateNormal];
    }
    return cell;
}

@end
