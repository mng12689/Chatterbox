//
//  SignUpOrLoginViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 10/24/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "SignUpOrLoginViewController.h"
#import <Parse/Parse.h>
#import "ChatterboxDataStore.h"

@interface SignUpOrLoginViewController ()

- (IBAction)doneButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property BOOL login;

@end

@implementation SignUpOrLoginViewController

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

@end
