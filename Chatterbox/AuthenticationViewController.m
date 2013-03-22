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
#import "CBCommons.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "NSError+ParseErrorCodes.h"

#define kUsernameTextFieldTag 48239
#define kPasswordTextFieldTag 99320

@interface AuthenticationViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
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
        [self loadViewData:login];
    }
    return self;
}

- (void)loadViewData:(BOOL)login
{
    self.login = login;
    self.title = self.login ? @"Log In" : @"Sign Up";
}

-(void)loadView
{
    [super loadView];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper_bg"]];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *clearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    clearView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = clearView;
    
    UIButton *footer = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    footer.backgroundColor = [UIColor clearColor];
    [footer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [footer setTitleColor:[CBCommons chatterboxOrange] forState:UIControlStateHighlighted];
    footer.titleLabel.font = [UIFont fontWithName:@"Cochin" size:16];
    footer.titleLabel.numberOfLines = 0;
    __weak AuthenticationViewController *weakAuthVC = self;
    [footer removeAllBlockObservers];
    [footer addEventHandler:^(id sender) {
        [weakAuthVC loadViewData:!weakAuthVC.login];
        [weakAuthVC loadView];
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setDuration:.25];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:@"extended"];
        [weakAuthVC.view.layer addAnimation:animation forKey:@"reloadAnimation"];
    } forControlEvents:UIControlEventTouchUpInside];
    if (!self.login) {
        [footer setTitle:NSLocalizedString(@"Already have an account? Log in here.", @"change to log in") forState:UIControlStateNormal];
    }else{
        [footer setTitle:NSLocalizedString(@"Don't have an account yet? Sign up here.", @"change to sign up") forState:UIControlStateNormal];
    }
    self.tableView.tableFooterView = footer;
    [self.view addSubview:self.tableView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Cochin" size:24.0];
    label.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor]; // change this color
    self.navigationItem.titleView = label;
    self.navigationItem.titleView.opaque = NO;
    label.text = NSLocalizedString(self.title, @"title for nav bar");
    [label sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
        [weakAuthVC dismissModalViewControllerAnimated:YES];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
- (void)authenticate
{
    __weak AuthenticationViewController *weakSelf = self;
    [self.tableView endEditing:YES];
    if (self.login) {
        [SVProgressHUD showWithStatus:@"Attempting log in..."];
        [PFUser logInWithUsernameInBackground:self.username password:self.password block:^(PFUser *user, NSError *error){
            if (user){
                [weakSelf loadUserConversations];
                [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"U%@",[PFUser currentUser].objectId]];
                [weakSelf dismissModalViewControllerAnimated:YES];
                [SVProgressHUD showSuccessWithStatus:@"Log in successful"];
            }
            else{
                [SVProgressHUD dismiss];
                [error handleErrorWithAlert:YES];
            }
        }];
    }
    else{
        PFUser *user = [PFUser user];
        user.username = self.username;
        user.password = self.password;
        if (self.username.length && self.password.length) {
            [SVProgressHUD showWithStatus:@"Attempting sign up..."];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"U%@",[PFUser currentUser].objectId]];
                    [weakSelf dismissModalViewControllerAnimated:YES];
                    [SVProgressHUD showSuccessWithStatus:@"Sign up successful"];
                } else {
                    [SVProgressHUD dismiss];
                    [error handleErrorWithAlert:YES];
                }
            }];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Must provide both a username and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)loadUserConversations
{
    __weak AuthenticationViewController *weakSelf = self;
    PFQuery *query = [[[PFUser currentUser]relationforKey:ParseUserConversationsKey]query];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeUserLoaded object:weakSelf];
    }];
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
            eCell.textField.tag = kUsernameTextFieldTag;
        }else if (indexPath.row == 1){
            eCell.textField.placeholder = @"Password";
            eCell.textField.secureTextEntry = YES;
            eCell.textField.tag = kPasswordTextFieldTag;
        }
        cell = eCell;
    }else if (indexPath.section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:doneButtonCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doneButtonCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        cell.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];

        cell.textLabel.text = @"Done";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"Cochin" size:22];
        cell.textLabel.textColor = [CBCommons chatterboxOrange];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self authenticate];
    }
}

#pragma mark - UIKeyboardNotifications
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.tableView.bounds.size.height - keyboardBounds.size.height;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
    self.tableView.frame = tableFrame;
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height)];
    
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
	// get a rect for the textView frame
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.bounds.size.height;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
    self.tableView.frame = tableFrame;
    [self.tableView setContentOffset:CGPointMake(0, 0)];

	// commit animations
	[UIView commitAnimations];
}

#pragma mark - NSNotificationCenter observers
- (void)textFieldDidChange:(NSNotification*)note
{
    UITextField *textField = (UITextField*)note.object;
    NSString *newText = textField.text;
    switch (textField.tag) {
        case kUsernameTextFieldTag:
            self.username = newText;
            break;
        case kPasswordTextFieldTag:
            self.password = newText;
            break;
        default:
            break;
    }
}

@end
