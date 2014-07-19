//
//  IPInputViewController.m
//  InputPhoneNumber
//
//  Created by Zelic on 7/19/14.
//  Copyright (c) 2014 Zelic. All rights reserved.
//

#import "IPInputViewController.h"

@interface IPInputViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *tfCountry;
@property (weak, nonatomic) IBOutlet UIImageView *ivFlag;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView *ivResult;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (strong, nonatomic) CountryPicker *picker;
@property (strong, nonatomic) NBAsYouTypeFormatter *formatter;
@property (strong, nonatomic) NBPhoneNumberUtil *phoneUtil;
@property (strong, nonatomic) NSString *code;
@end

@implementation IPInputViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerKeyboardEvents];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init country picker
    _picker                 = [[CountryPicker alloc] init];
    _picker.delegate        = self;
    _tfCountry.inputView    = _picker;
    
    //Set up delegate for textfields
    _tfCountry.delegate     = self;
    _tfPhoneNumber.delegate = self;
    _ivResult.image         = nil;
    
    //Styling button
    [_btnCheck applyRoundedCorner:5];
    
    //Get phone util
    _phoneUtil              = [NBPhoneNumberUtil sharedInstance];
    [self initToolbarForInputView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterKeyboardEvents];
}

#pragma mark - Init input view
- (void)initToolbarForInputView
{
    UIToolbar *toolBar                = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.backgroundColor           = [UIColor whiteColor];
    //Add flexible space to set the Done button to the right
    UIBarButtonItem *space            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *btnDone          = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTouch:)];
    toolBar.items                     = @[space, btnDone];
    //Set toolbar for textfield
    _tfCountry.inputAccessoryView     = toolBar;
    _tfPhoneNumber.inputAccessoryView = toolBar;
}

#pragma mark - Done button handler in toolbar
- (void)doneButtonDidTouch:(id)sender
{
    if ([_tfCountry isFirstResponder]) {
        _code = [_picker selectedCountryCode];
        _formatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:_code];
        _ivResult.image = nil;
        //Update country field
        [self updateCountryField];
        //Move to phone number field
        [_tfPhoneNumber becomeFirstResponder];
    } else {
        //Hide keyboard
        [_tfPhoneNumber resignFirstResponder];
    }
}

#pragma mark - Country Picker Delegate // Change country
- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    _code = code;
    _formatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:code];
    _ivResult.image = nil;
    [self updateCountryField];
    
    //Recheck the number if it exists
    if (_tfPhoneNumber.text.length>0) {
        _tfPhoneNumber.text = @"";
    }
}

//Helper method: update country text and image
- (void)updateCountryField {
    _ivFlag.image = [UIImage imageNamed:[_picker selectedCountryCode]];
    _ivFlag.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _ivFlag.layer.borderWidth = 1;
    _tfCountry.text = [_picker selectedCountryName];
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //Validate if country is selected or not
    if (textField == _tfPhoneNumber && _code == nil) {
        //Show error dialog and move back to country spinner
        [self showAlertViewWithTitle:@"Country" andMessage:@"Please select a country before inputing phone number." andHandler:^{
            [textField resignFirstResponder];
            [_tfCountry becomeFirstResponder];
        }];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _tfPhoneNumber) {
        //Get the full string when user edits the textfield
        NSString *numberString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        //Clear current result if user clears the field
        if (numberString.length == 0) {
            _ivResult.image = nil;
        }
        
        //Format as you type
        if (numberString.length > textField.text.length) {
            //Type a digit
            textField.text = [_formatter inputDigit:string];
        } else {
            //Clear a digit
            textField.text = [_formatter removeLastDigit];
        }
        //Check valid phone number
        [self checkValidPhoneNumber:numberString];
        
        return NO;
    }
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [_formatter clear];
    _ivResult.image = nil;
    return YES;
}

#pragma mark - Check valid phone number
- (BOOL)checkValidPhoneNumber:(NSString *)numberString
{
    if (numberString.length > 0) {
        NSError *error;
        //Parse string to phone number
        NBPhoneNumber *phoneNumber = [_phoneUtil parse:numberString defaultRegion:_code error:&error];
        //If there is no error
        if (!error) {
            //Show valid image if phone number is valid
            if ([_phoneUtil isValidNumber:phoneNumber]) {
                _ivResult.image = [UIImage imageNamed:@"valid"];
                _tfPhoneNumber.text = [_phoneUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:&error];
                return YES;
            } else {
                //Else show invalid image
                _ivResult.image = [UIImage imageNamed:@"invalid"];
                return NO;
            }
        } else {
            _ivResult.image = [UIImage imageNamed:@"invalid"];
        }
    }
    return NO;
}

#pragma mark - Check button did touch
- (IBAction)checkButtonDidTouch:(id)sender
{
    [self.view endEditing:YES];
    //Check if country is selected or not
    if (!_code) {
        [self showAlertViewWithTitle:@"Country" andMessage:@"Please select a country before inputing phone number." andHandler:^{
            [_tfCountry becomeFirstResponder];
        }];
    } else if (_tfPhoneNumber.text.length == 0) {
        [self showAlertViewWithTitle:@"Phone number" andMessage:@"Please enter your phone number." andHandler:^{
            [_tfPhoneNumber becomeFirstResponder];
        }];
    } else if ([self checkValidPhoneNumber:_tfPhoneNumber.text]) {
        //Check valid phone number and inform user
        [self showAlertViewWithTitle:@"Valid number" andMessage:@"Your input phone number is valid." andHandler:nil];
    } else {
        [self showAlertViewWithTitle:@"Invalid number" andMessage:@"Your input phone number is invalid." andHandler:nil];
    }
}

#pragma mark - Alert View helper method
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message andHandler:(void (^)(void))handler
{
    //Create, styling and show a message dialog
    SIAlertView *ret = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [ret addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        if (handler) {
            handler();
        }
    }];
    //Bouncing effect for dialog
    ret.transitionStyle = SIAlertViewTransitionStyleBounce;
    [ret show];
}

#pragma mark - Keyboard manipulation
- (void)registerKeyboardEvents
{
    //Register to handle showing and hiding event of keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)unregisterKeyboardEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    NSDictionary *info        = notification.userInfo;
    CGSize keyboardSize       = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat screenSize        = [UIScreen mainScreen].bounds.size.height;
    CGFloat checkButtonPosX   = _btnCheck.frame.origin.y;
    CGFloat checkButtonHeight = _btnCheck.frame.size.height;
    //Move the scrollview up so that check button is above the input view
    CGPoint scrollPoint       = CGPointMake(0, (checkButtonPosX + checkButtonHeight - (screenSize - keyboardSize.height)));
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)keyboardWasHide:(NSNotification *)notification
{
    //Move scrollview to default offset
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (IBAction)scrollViewDidTouch:(id)sender {
    //Hide keyboard when touch outside of textfields
    [self.scrollView endEditing:YES];
}

@end
