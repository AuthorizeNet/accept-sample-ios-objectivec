//
//  ViewController.m
//  accept-sample-objc
//
//  Created by Ramamurthy, Rakesh Ramamurthy on 12/23/16.
//  Copyright © 2016 Ramamurthy, Rakesh Ramamurthy. All rights reserved.
//

#import "ViewController.h"
#import <AuthorizeNetAccept/AuthorizeNetAccept-Swift.h>

#define kClientName @"5KP3u95bQpv"
#define kClientKey @"5FcB6WrfHGS76gHW3v7btBCE3HuuBuke9Pj96Ztfn5R32G5ep42vne7MCWZtAucY"

#define kAcceptSDKDemoCreditCardLength 16
#define kAcceptSDKDemoCreditCardLengthPlusSpaces (kAcceptSDKDemoCreditCardLength+3)
#define kAcceptSDKDemoExpirationLength 4
#define kAcceptSDKDemoExpirationMonthLength 2
#define kAcceptSDKDemoExpirationYearLength 2
#define kAcceptSDKDemoExpirationLengthPlusSlash (kAcceptSDKDemoExpirationLength+1)
#define kAcceptSDKDemoCVV2Length 4
#define kAcceptSDKDemoCreditCardObscureLength (kAcceptSDKDemoCreditCardLength-4)

#define kAcceptSDKDemoSpace @" "
#define kAcceptSDKDemoSlash @"/"


#define kInAppSDKCardNumberCharacterCountMin 12
#define kInAppSDKCardNumberCharacterCountMax 19
#define kInAppSDKCardExpirationMonthMin 1
#define kInAppSDKCardExpirationMonthMax 12
#define kInAppSDKCardExpirationYearMax 99
#define kInAppSDKSecurityCodeCharacterCountMin 3
#define kInAppSDKSecurityCodeCharacterCountMax 4
#define kInAppSDKZipCodeCharacterCountMax 5

#define kPrevSegmentIndex 0
#define kNextSegmentIndex 1

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextField *cardNumberTextField;
@property (nonatomic, weak) IBOutlet UITextField *expirationMonthTextField;
@property (nonatomic, weak) IBOutlet UITextField *expirationYearTextField;
@property (nonatomic, weak) IBOutlet UITextField *cardVerificationCodeTextField;
@property (nonatomic, weak) IBOutlet UIButton *getTokenButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorAcceptSDKDemo;
@property (nonatomic, weak) IBOutlet UITextView *textViewShowResults;
@property (nonatomic, weak) IBOutlet UIView *headerView;

@property (nonatomic, copy) NSString *cardNumber;
@property (nonatomic, copy) NSString *cardExpirationMonth;
@property (nonatomic, copy) NSString *cardExpirationYear;
@property (nonatomic, copy) NSString *cardVerificationCode;
@property (nonatomic, copy) NSString *cardNumberBuffer;
@property (nonatomic, strong) UITextField *currentField;
@property (nonatomic, strong) UIToolbar *toolBar;

@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:85.0/255.0 blue:112.0/255.0 alpha:1];
    
    [self setUIControlsTagValues];
    [self initializeUIControls];
    [self initializeMembers];
    [self updateTokenButton:false];
}

- (void)setUIControlsTagValues {
    self.cardNumberTextField.tag = 1;
    self.expirationMonthTextField.tag = 2;
    self.expirationYearTextField.tag = 3;
    self.cardVerificationCodeTextField.tag = 4;
}

- (void)initializeUIControls {
    self.cardNumberTextField.text = @"";
    self.expirationMonthTextField.text = @"";
    self.expirationYearTextField.text = @"";
    self.cardVerificationCodeTextField.text = @"";
    [self textChangeDelegate:self.cardNumberTextField];
    [self textChangeDelegate:self.expirationMonthTextField];
    [self textChangeDelegate:self.expirationYearTextField];
    [self textChangeDelegate:self.cardVerificationCodeTextField];
}

- (void)initializeMembers {
    self.cardNumber = nil;
    self.cardExpirationMonth = nil;
    self.cardExpirationYear = nil;
    self.cardVerificationCode = nil;
    self.cardNumberBuffer = @"";
}

- (void)updateTokenButton:(BOOL)isEnable {
    self.getTokenButton.enabled = isEnable;
    if (isEnable) {
        self.getTokenButton.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:85.0/255.0 blue:112.0/255.0 alpha:1];
    } else {
        self.getTokenButton.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:85.0/255.0 blue:112.0/255.0 alpha:0.2];
    }
}

- (UIColor *)darkBlueColor {
    return [UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0];
}

- (IBAction)getTokenButtonTapped {
    [self.activityIndicatorAcceptSDKDemo startAnimating];
    [self updateTokenButton:false];
    [self getToken];
}

- (void)getToken {
    AcceptSDKHandler *handler = [[AcceptSDKHandler alloc] initWithEnvironment:AcceptSDKEnvironmentENV_TEST];
    AcceptSDKRequest *request = [[AcceptSDKRequest alloc] init];
    request.merchantAuthentication.name = kClientName;
    request.merchantAuthentication.clientKey = kClientKey;
    
    //AcceptSDKRequest class does not have "securePaymentContainerRequest" property
    request.securePaymentContainerRequest.webCheckOutDataType.token.cardNumber = self.cardNumberBuffer;
    request.securePaymentContainerRequest.webCheckOutDataType.token.expirationMonth = self.cardExpirationMonth;
    request.securePaymentContainerRequest.webCheckOutDataType.token.expirationYear = self.cardExpirationYear;
    request.securePaymentContainerRequest.webCheckOutDataType.token.cardCode = self.cardVerificationCode;
    
    [handler getTokenWithRequest:request successHandler:^(AcceptSDKTokenResponse * _Nonnull inResponse) {
        NSLog(@"success %@", inResponse.getOpaqueData.getDataValue);
        [self updateTokenButton:true];
        [self.activityIndicatorAcceptSDKDemo stopAnimating];
        NSString *output = [NSString stringWithFormat:@"Response: %@\nData Value: %@ \nDescription: %@", [[inResponse getMessages] getResultCode], [[inResponse getOpaqueData] getDataValue], [[inResponse getOpaqueData] getDataDescriptor]];
        self.textViewShowResults.text = output;
        self.textViewShowResults.textColor = [UIColor greenColor];

    } failureHandler:^(AcceptSDKErrorResponse * _Nonnull inError) {
        //do something
        Message *msg = [[inError getMessages] getMessages][0];
        NSLog(@"failed...%@", [msg getText]);
        [self updateTokenButton:true];
        [self.activityIndicatorAcceptSDKDemo stopAnimating];
        
        NSString *output = [NSString stringWithFormat:@"Response:  %@\nError code: %@\nError text:   %@", [[inError getMessages] getResultCode], [[[[inError getMessages] getMessages] objectAtIndex:0] getCode], [[[[inError getMessages] getMessages] objectAtIndex:0] getText]];
        self.textViewShowResults.text = output;
        self.textViewShowResults.textColor = [UIColor redColor];
    }];
}

- (void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 )
    {
        NSRange bottom = NSMakeRange(textView.text.length-1, 1);//NSMakeRange(textView.text.length-1, 1);
        [textView scrollRangeToVisible:bottom];
    }
}

- (void)updateTextViewWithMessage:(NSString *)message {
    if (message.length > 0) {
        self.textViewShowResults.text = [NSString stringWithFormat:@"%@\n", self.textViewShowResults.text];
    } else {
        self.textViewShowResults.text = [NSString stringWithFormat:@"%@ Empty Message\n", self.textViewShowResults.text];
    }
    
    [self scrollTextViewToBottom:self.textViewShowResults];
}

- (IBAction)hideKeyBoard:(id)sender {
    [self.view endEditing:true];
}

- (void)formatCardNumber:(UITextField *)textField {
    NSMutableString *value = [NSMutableString string];
    
    if (textField == self.cardNumberTextField )
    {
        NSInteger length = [self.cardNumberBuffer length];
        
        for (int i = 0; i < length; i++)
        {
            
            // Reveal only the last character.
            if (length <= kAcceptSDKDemoCreditCardObscureLength)
            {
                
                if (i == (length - 1))
                {
                    [value appendString:[self.cardNumberBuffer substringWithRange:NSMakeRange(i,1)]];
                }
                else
                {
                    [value appendString:@"●"];
                }
            }
            // Reveal the last 4 characters
            else
            {
                
                if (i < kAcceptSDKDemoCreditCardObscureLength)
                {
                    [value appendString:@"●"];
                }
                else
                {
                    [value appendString:[self.cardNumberBuffer substringWithRange:NSMakeRange(i,1)]];
                }
            }
            
            //After 4 characters add a space
            if ((i +1) % 4 == 0 &&  ([value length] < kAcceptSDKDemoCreditCardLengthPlusSpaces))
            {
                [value appendString:kAcceptSDKDemoSpace];
            }
        }
        
        textField.text =  value;
    }
}

- (BOOL) isMaxLength:(UITextField *)textField
{
    
    if (textField == self.cardNumberTextField && [textField.text length] >= kAcceptSDKDemoCreditCardLengthPlusSpaces)
    {
        return YES;
    }
    
    if (textField == self.expirationMonthTextField && [textField.text length] >= kAcceptSDKDemoExpirationMonthLength)
    {
        return YES;
    }
    
    if (textField == self.expirationYearTextField && [textField.text length] >= kAcceptSDKDemoExpirationYearLength)
    {
        return YES;
    }
    if (textField == self.cardVerificationCodeTextField && [textField.text length] >= kAcceptSDKDemoCVV2Length)
    {
        return YES;
    }
    return NO;
}

#pragma UITextViewDelegate delegate

- (void) prevNextSegmentedControlChanged:(UISegmentedControl *)uiSegment {
    if (uiSegment.selectedSegmentIndex == kPrevSegmentIndex) {
        if (self.currentField == self.cardNumberTextField) {
            self.currentField = self.cardVerificationCodeTextField;
        } else if (self.currentField == self.cardVerificationCodeTextField) {
            self.currentField = self.expirationYearTextField;
        } else if (self.currentField == self.expirationYearTextField) {
            self.currentField = self.expirationMonthTextField;
        } else if (self.currentField == self.expirationMonthTextField) {
            self.currentField = self.cardNumberTextField;
        }
        
    } else if (uiSegment.selectedSegmentIndex == kNextSegmentIndex) {
        if (self.currentField == self.cardNumberTextField) {
            self.currentField = self.expirationMonthTextField;
        } else if (self.currentField == self.expirationMonthTextField) {
            self.currentField = self.expirationYearTextField;
        } else if (self.currentField == self.expirationYearTextField) {
            self.currentField = self.cardVerificationCodeTextField;
        } else if (self.currentField == self.cardVerificationCodeTextField) {
            self.currentField = self.cardNumberTextField;
        }
    }
    [self.currentField becomeFirstResponder];
}

- (void) donePressed {
    [self dismissKeyboard];
}

- (IBAction) dismissKeyboard {
    [self.currentField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentField = textField;
    
    if (textField.inputAccessoryView == nil) {
        CGRect aScreenSize = [[UIScreen mainScreen] bounds];
        self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(aScreenSize.origin.x, aScreenSize.origin.y, aScreenSize.size.width, 44)];
        UIBarButtonItem *aSecondButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
        UISegmentedControl *aSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Prev", @"Next"]];
        aSegmentControl.momentary = YES;
        [aSegmentControl addTarget:self action:@selector(prevNextSegmentedControlChanged:) forControlEvents:(UIControlEventValueChanged)];
        UIBarButtonItem *aFirstButton = [[UIBarButtonItem alloc] initWithCustomView:aSegmentControl];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self.toolBar setItems:[NSArray arrayWithObjects:aFirstButton, flexibleItem, aSecondButton, nil]];
        [self.toolBar setTranslucent:YES];
        [self.toolBar setBarStyle:UIBarStyleBlack];
        textField.inputAccessoryView = self.toolBar;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    switch (textField.tag)
    {
        case 1:
        {
            if ([string length] > 0)
            {
                if ([self isMaxLength:textField])
                    return NO;
                
                self.cardNumberBuffer  = [NSString stringWithFormat:@"%@%@", self.cardNumberBuffer, string];
            }
            else
            {
                if ([self.cardNumberBuffer length] > 1)
                {
                    self.cardNumberBuffer = [self.cardNumberBuffer substringWithRange:NSMakeRange(0, [self.cardNumberBuffer length] - 1)];
                }
                else
                {
                    self.cardNumberBuffer = @"";
                }
            }
            [self formatCardNumber:textField];
            
            
            return NO;
            
        }
            break;
        case 2:
        {
            if ([string length] > 0)
            {
                if ([self isMaxLength:textField])
                    return NO;
            }
        }
            break;
        case 3:
        {
            if ([string length] > 0)
            {
                if ([self isMaxLength:textField])
                    return NO;
            }
        }
            break;
        case 4:
        {
            if ([string length] > 0)
            {
                if ([self isMaxLength:textField])
                    return NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)validInputs {
    BOOL inputsAreOKToProceed = NO;
    AcceptSDKCardFieldsValidator *validator = [[AcceptSDKCardFieldsValidator alloc]init];
    
    if (([validator validateSecurityCodeWithString:self.cardVerificationCodeTextField.text] &&
         [validator validateExpirationDate:self.expirationMonthTextField.text inYear:self.expirationYearTextField.text] &&
         [validator validateCardWithLuhnAlgorithm:self.cardNumberBuffer]))
    {
        inputsAreOKToProceed = YES;
    }
    
    return inputsAreOKToProceed;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    AcceptSDKCardFieldsValidator *validator = [[AcceptSDKCardFieldsValidator alloc]init];

    switch (textField.tag)
    {
        case 1:
        {
            self.cardNumber = self.cardNumberBuffer;
            
            BOOL luhnResult = [validator validateCardWithLuhnAlgorithm:self.cardNumberBuffer];
            
            if ((luhnResult == NO) || (textField.text.length < kInAppSDKCardNumberCharacterCountMin))
            {
                self.cardNumberTextField.textColor = [UIColor redColor];
            }
            else
            {
                self.cardNumberTextField.textColor = [self darkBlueColor]; //[UIColor greenColor];
            }
            
            
            if ([self validInputs])
            {
                [self updateTokenButton:true];
            }
            else
            {
                [self updateTokenButton:false];
            }
        }
            break;
        case 2:
        {
            [self validateMonth:textField];
            if (self.expirationYearTextField.text.length) {
                [self validateYear:self.expirationYearTextField.text];
            }
        }
            break;
        case 3:
        {
            [self validateYear:textField.text];
        }
            break;
        case 4:
        {
            self.cardVerificationCode = textField.text;
            
            if ([validator validateSecurityCodeWithString:self.cardVerificationCodeTextField.text])
            {
                self.cardVerificationCodeTextField.textColor = [self darkBlueColor];
            }
            else
            {
                self.cardVerificationCodeTextField.textColor = [UIColor redColor];
            }
            
            if ([self validInputs])
            {
                [self updateTokenButton:true];
            }
            else
            {
                [self updateTokenButton:false];
            }
            
        }
            break;
            
        default:
            break;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.cardNumberTextField)
    {
        self.cardNumberBuffer = [NSString string];
    }
    
    return YES;
}

- (void)validateMonth:(UITextField *)textField {
    self.cardExpirationMonth = textField.text;
    
    if (self.expirationMonthTextField.text.length == 1)
    {
        if (![textField.text isEqualToString:@"0"]) {
            self.expirationMonthTextField.text = [NSString stringWithFormat:@"0%@", self.expirationMonthTextField.text];
        }
    }
    
    int newMonth = textField.text.intValue;
    
    if ((newMonth >= kInAppSDKCardExpirationMonthMin)  && (newMonth <= kInAppSDKCardExpirationMonthMax))
    {
        self.expirationMonthTextField.textColor = [self darkBlueColor]; //[UIColor greenColor]
        
    } else {
        self.expirationMonthTextField.textColor = [UIColor redColor];
    }
    
    if ([self validInputs]) {
        [self updateTokenButton:true];
    } else {
        [self updateTokenButton:false];
    }

}

- (void)validateYear:(NSString *)textFieldText {
    self.cardExpirationYear = textFieldText;
    
    AcceptSDKCardFieldsValidator *validator = [[AcceptSDKCardFieldsValidator alloc]init];
    int newYear = textFieldText.intValue;
    
    if ((newYear >= [validator cardExpirationYearMin])  && (newYear <= kInAppSDKCardExpirationYearMax))
    {
        self.expirationYearTextField.textColor = [self darkBlueColor]; //[UIColor greenColor]
    }
    else
    {
        self.expirationYearTextField.textColor = [UIColor redColor];
    }
    if (self.expirationYearTextField.text.length == 0)
    {
        return;
    }
    if (self.expirationMonthTextField.text.length == 0)
    {
        return;
    }
    if ([validator validateExpirationDate:self.expirationMonthTextField.text inYear:self.expirationYearTextField.text])
    {
        self.expirationMonthTextField.textColor = [self darkBlueColor];
        self.expirationYearTextField.textColor = [self darkBlueColor];
    }
    else
    {
        self.expirationMonthTextField.textColor = [UIColor redColor];
        self.expirationYearTextField.textColor = [UIColor redColor];
    }
    if ([self validInputs])
    {
        [self updateTokenButton:true];
    }
    else
    {
        [self updateTokenButton:false];
    }
}

- (void)textChangeDelegate:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if ([self validInputs]) {
            [self updateTokenButton:true];
        } else {
            [self updateTokenButton:false];
        }
    }];
}


@end
