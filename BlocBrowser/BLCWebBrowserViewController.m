//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Tim on 2015-03-27.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "BLCWebBrowserViewController.h"

// In order to use this VC as the delegate for the UIWebView, we need to confirm
// it conforms to the UIWebViewDelegate protocol
@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
// @property (nonatomic, assign) BOOL isLoading;
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
  self.textField. delegate = self;
  
  self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.backButton setEnabled:NO];
  
  self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.forwardButton setEnabled:NO];
  
  self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.stopButton setEnabled:NO];
  
  self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.reloadButton setEnabled:NO];
  
  [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
  
  [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
  
  [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
  
  [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload command") forState:UIControlStateNormal];
  
  [self addButtonTargets];

  for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton,
                              self.forwardButton, self.stopButton, self.reloadButton]) {
  [mainView addSubview:viewToAdd];
  }
  
  self.view = mainView;
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
  CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
  CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
  
  // text field is positioned at 0 x 0, and we use the width and itemHeight values we create for the size
  self.textField.frame = CGRectMake(0, 0, width, itemHeight);
  // (0, bottom of textfield)
  self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
  
  CGFloat currentButtonX = 0;
  
  for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
    thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
    currentButtonX += buttonWidth;
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
  
  self.backButton.enabled = [self.webview canGoBack];
  self.forwardButton.enabled = [self.webview canGoForward];
  self.stopButton.enabled = (self.frameCount > 0);
  self.reloadButton.enabled = (self.webview.request.URL && self.frameCount == 0);
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
  
  [self addButtonTargets];
  
  self.textField.text = nil;
  [self updateButtonsAndTitle];
  
}

// we need to tell the buttons to switch the web view, or else they will try to communicate
// with a web view that no longer exsts and cause a crash

-(void) addButtonTargets
{
  // the for loop will loop through all the buttons and remove the reference to the old web view
  // the web view is added as a target to each button, just like in load view
  for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
  }
  
  [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
  [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
  [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
  [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
}


@end