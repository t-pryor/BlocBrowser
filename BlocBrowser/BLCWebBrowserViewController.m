//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Tim on 2015-03-27.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "BLCAwesomeFloatingToolbar.h"

#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

// In order to use this VC as the delegate for the UIWebView, we need to confirm
// it conforms to the UIWebViewDelegate protocol
@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, BLCAwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) BLCAwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation BLCWebBrowserViewController

#pragma mark - UIViewController

// is this necessary?
// don't all view controllers do this automatically?
- (void)loadView
{
  UIView *mainView = [UIView new];
  
  self.webview = [[UIWebView alloc] init];
  self.webview.delegate = self;
  
  self.textField = [[UITextField alloc] init];
  self.textField.keyboardType = UIKeyboardTypeURL;
  self.textField.returnKeyType = UIReturnKeyDone;
  self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.textField.placeholder = NSLocalizedString(@"Search Google or type URL", @"Placeholder text for web browser URL field");
  self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
  self.textField.delegate = self;
  
  self.awesomeToolbar = [[BLCAwesomeFloatingToolbar alloc] initWithFourTitles:@[kBLCWebBrowserBackString, kBLCWebBrowserForwardString, kBLCWebBrowserStopString, kBLCWebBrowserRefreshString]];

  self.awesomeToolbar.delegate = self;
  
  for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar]) {
    [mainView addSubview:viewToAdd];
  }
  
  self.view = mainView;
  
  NSLog(@"NAV tVC: %@", self.navigationController.topViewController);
  NSLog(@"NAV rVC: %@", self.navigationController.viewControllers.firstObject);
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // some apps scroll their content up under the navigation bar and behind the status bar
  // setting this to None opts out of this behavior
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.activityIndicator = [[UIActivityIndicatorView alloc]
                            initWithActivityIndicatorStyle:
                            UIActivityIndicatorViewStyleGray];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithCustomView:self.activityIndicator];


}

// we do this here because before this point the main view is not guaranteeed
// to have adjusted to any rotation or resizing events

- (void) viewWillLayoutSubviews {
  // URL bar should have a height of 50
  // static keeps the value the same between invocations of the method
  // const tells the compiler this value won't change, allowing for additional speed optimizations
  
  static const CGFloat itemHeight = 50;
  // width should be the same as this view width
  CGFloat width = CGRectGetWidth(self.view.bounds);
  // calculate the height of the browser view to be the height of the entire main view, minus the height of the URL bar and minus height of the navigation buttons
  CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
  
  
  // text field is positioned at 0 x 0, and we use the width and itemHeight values we create for the size
  self.textField.frame = CGRectMake(0, 0, width, itemHeight);
  // (0, bottom of textfield)
  self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
  
  
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    self.awesomeToolbar.frame = CGRectMake(20, 150, 280, 60);
  } else {
    self.awesomeToolbar.frame = CGRectMake(70, 120, 320, 60);
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  // asks the text field to resign its first responder status
  [textField resignFirstResponder];
  
  // set URLString to the what the user typed in
  // This method expects URLString to contain only characters that are allowed in a properly formed URL.
   NSString *URLString = textField.text;
  
  /*
   ASSIGNMENT
   If the user's text includes a space, assume it's a search query instead of a URL
   If there's a search query, load a URL like this:
   google.com/search?q=<search query>
  
  */
  
  if ( [URLString rangeOfString:@" "].location != NSNotFound ) {
   // URLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    URLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    URLString = [NSString stringWithFormat: @"http://google.com/search?q=%@", URLString] ;
  }
  
  NSURL *URL = [NSURL URLWithString:URLString];
  
  // if the URL doesn't have a scheme we will assume they meant http:// and add it for them
  if (!URL.scheme) {
    // The user didn't type http: or https:
    URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
  }
  // An NSURLRequest holds all the data necessary to communicate with a web server
   if (URL) {
     // Creates and returns a URL request for a specified URL with default cache policy and timeout value.
     NSURLRequest *request = [NSURLRequest requestWithURL:URL];
     // UIWebView instance var loadRequest Connects to a given URL by initiating an asynchronous client request.
     [self.webview loadRequest:request];
   }
  
   return NO;
}

#pragma mark - UIWebViewDelegate

// NSError encapsulates richer and more extensible error info than possible with an error code or string
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  if (error.code != -999) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
  }
  
  [self updateButtonsAndTitle];
  self.frameCount--;
}

// Sent after a web view starts loading a frame
// a single webpage can sometimes be divided into several subpages
// sometimes used to display nav links or sidebars, or used for embedding media, such as vids
- (void)webViewDidStartLoad:(UIWebView *)webView
{
  // self.isLoading = YES;
  self.frameCount++;
  [self updateButtonsAndTitle];
}

// Sent after a web view finishes loading a frame
// Possible that when we visit a page with multiple frames, one of them will finish loading
// (causeing our webViewDidFinishLoad method to get triggered) and our activity indicator
// will stop spinning before the page has been entirely loaded
// need to keep a tally of the number of frames still loading
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//  self.isLoading = NO;
  self.frameCount--;
  [self updateButtonsAndTitle];
}


#pragma mark - Miscellaneous

// we need to call this method whenever a page starts or stops loading
- (void) updateButtonsAndTitle
{
  NSString *webpageTitle = [self.webview
                            stringByEvaluatingJavaScriptFromString:@"document.title"];
  
  if (webpageTitle) {
    self.navigationItem.title = webpageTitle;
  } else {
    self.title = self.webview.request.URL.absoluteString;
  }
  
  if (self.frameCount > 0) {
    [self.activityIndicator startAnimating];
  } else {
    [self.activityIndicator stopAnimating];
  }
  
  // $Ask Steve
  [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kBLCWebBrowserBackString];
  [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];
  [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kBLCWebBrowserStopString];
  [self.awesomeToolbar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kBLCWebBrowserRefreshString];
  

}


- (void) resetWebView
{
  // remove the old web view from the view hierarchy
  // Unlinks the view from its superview and its window and removes it from the responder chain.
  [self.webview removeFromSuperview];
  
  // create a new, empty web view and adds it back in
  UIWebView *newWebView = [[UIWebView alloc] init];
  newWebView.delegate = self;
  [self.view addSubview:newWebView];
  
  self.webview = newWebView;

  self.textField.text = nil;
  [self updateButtonsAndTitle];
  
}

// we need to tell the buttons to switch the web view, or else they will try to communicate
// with a web view that no longer exsts and cause a crash



#pragma mark - BLCAwesomeFloatingToolbarDelegate

- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title
{
  if ([title isEqual:kBLCWebBrowserBackString]) {
    [self.webview goBack];
  } else if ([title isEqual:kBLCWebBrowserForwardString]) {
    [self.webview goForward];
  } else if ([title isEqual:kBLCWebBrowserStopString]) {
    [self.webview stopLoading];
  } else if ([title isEqual:kBLCWebBrowserRefreshString]) {
    [self.webview reload];
  }
}


@end