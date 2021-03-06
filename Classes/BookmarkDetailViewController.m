//
//  BookmarkDetailViewController.m
//  LinGEO

#import "BookmarkDetailViewController.h"
#import "LinGEOAppDelegate.h"
#import "BookmarkViewController.h"



@implementation BookmarkDetailViewController

@synthesize webView, bookmark;
@synthesize adViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (NSMutableString*)generateHTMLoutput
{
    NSMutableString *string = [NSMutableString new];
    
    [string appendFormat:@"<html>"
     "<style>"
     "body {"
     "margin: 10 40 20 40;"
     "}"
     "#word {"
     "font-family: Georgia;"
     "font-size: 78px;"
     "font-weight: bold;"
     "}"
     "#transcript {"
     "font-family: Georgia;"
     "font-size: 74px;"
     "}"
     ".s3 {"
     "font-family: Georgia;"
     "font-size: 60px;"
     "font-weight: bold;"
     "}"
     ".s7 {"
     "border-bottom: 1px solid #c0c0c0;"
     "}"
     "i {"
     "color: #72c53e;"
     "}"
     "</style>"
     "<body bgcolor='#FFF3E0'>" ];
    // "<div id='word'>%@</div>"
    // "<div id='transcript'>&nbsp;%@</div>", [trn eng], [trn transcription]];
    
     
    // [string appendFormat:@"<div class='s3 s4'>Added - %@</div>", [bookmark date]];
     [string appendString:@"<div class='s5'>"];
     [string appendFormat:@"<div id='word'>%@</div>"
     "<div id='transcript'>&nbsp;%@</div>", [bookmark eng], [bookmark transcription] ];
    
    for(int i = 0; i < [bookmark.types count]; i++) {
        //[string appendFormat:@"<div class='s3'>%d.&nbsp;<i>%@</i></div>", i + 1, [[bookmark.types objectAtIndex:i] lowercaseString]];
        //[string appendFormat:@"<div class='s3'>&nbsp;&nbsp;&nbsp;&nbsp;%@</div>", [bookmark.geoArray objectAtIndex:i]];

        [string appendFormat:@"<div class='s3'>%d.&nbsp;<i>%@</i></div>", i + 1, [[bookmark.types objectAtIndex:i] lowercaseString]];
        [string appendFormat:@"<div class='s3'>&nbsp;&nbsp;&nbsp;&nbsp;%@</div>"
         "<div class='s7'><a href='callback:%d'><img id=\"mplayer%d\" src=\"Play-icon.png\" /></a></div>", [bookmark.geoArray objectAtIndex:i], i, i];
    }
    
    [string appendString:@"</div>"];
    [string appendString:@"</body></html>"];
    
    return string;
}


-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    if ( [[[inRequest URL] scheme] isEqualToString:@"callback"] ) {
        
        if([[PTeSpeak sharedPTeSpeak] isSpeak]) {
            [[PTeSpeak sharedPTeSpeak] stop];
            return NO;
        }
        
        NSString *indexStr = [[[inRequest URL] absoluteString ] substringFromIndex:[[[inRequest URL] scheme] length] + 1];
        
        int inx = [indexStr intValue];
        
        if(inx > -1) {
            
            selectedWord = inx;
            [[PTeSpeak sharedPTeSpeak] speak:[bookmark.geoArray objectAtIndex:inx]];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)speakDidStart:(PTeSpeak *)espeak
{
    [self.webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"var mid = document.getElementById(\"mplayer%d\");"    
      "mid.src = \"Stop-icon.png\";", selectedWord]];
}

- (void)speakDidEnd:(PTeSpeak *)espeak
{
    [self.webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"var mid = document.getElementById(\"mplayer%d\");"    
      "mid.src = \"Play-icon.png\";", selectedWord]];
}

- (void)speakWithError:(PTeSpeak *)espeak error:(OSStatus)error
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"alert('Unable to create Audio queue')"];
}


//If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
	self.title = @"Details";
    
    //  Configure the Action button
    UIBarButtonItem *action = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action)];
    
    
    self.navigationItem.rightBarButtonItem = action;
    
    [[PTeSpeak sharedPTeSpeak] setDelegate:self];
    [[PTeSpeak sharedPTeSpeak] setupWithVoice:@"ka" volume:100 rate:150 pitch:40];
    
    // to make html content transparent to its parent view -
	// 1) set the webview's backgroundColor property to [UIColor clearColor]
	// 2) use the content in the html: <body style="background-color: transparent">
	// 3) opaque property set to NO
	//
	webView.opaque = NO;
	webView.backgroundColor = [UIColor clearColor];
    webView.delegate = self;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSMutableString *output = [self generateHTMLoutput];
    [webView loadHTMLString:output baseURL:baseURL];
    [output release];
    
    
    self.adViewController = [[AdViewController alloc] initWithController:self]; 
    
    // If the banner wasn't included in the nib, create one.
    [adViewController createADBannerView];
    
    [adViewController layoutForCurrentOrientation:NO];
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[PTeSpeak sharedPTeSpeak] stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [adViewController layoutForCurrentOrientation:NO];  
}


#pragma mark -
#pragma mark Action

- (NSMutableString*)generateHTMLoutputForEmail
{
    NSMutableString *string = [NSMutableString new];
    
    [string appendFormat:@"<html><body bgcolor='#FFF3E0'>"];
        
    [string appendFormat:@"<div class='word'><b>%@</b></div>"
     "<div class='transcript'>&nbsp;%@</div>", [bookmark eng], [bookmark transcription] ];
    
    for(int i = 0; i < [bookmark.types count]; i++) {
        [string appendFormat:@"<div class='s3'>%d.&nbsp;<i>%@</i></div>", i + 1, [[bookmark.types objectAtIndex:i] lowercaseString]];
        [string appendFormat:@"<div class='s3'>&nbsp;&nbsp;&nbsp;&nbsp;%@</div>", [bookmark.geoArray objectAtIndex:i]];
    }
    
    [string appendString:@"<br>"];
    [string appendString:@"</body></html>"];
    
    return string;
}

-(void) emailBookmarks {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) cancel {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) action
{
    
	// open a dialog with Reload and Cabcel button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                               destructiveButtonTitle:NSLocalizedString(@"Delete", @"") 
                                                    otherButtonTitles:NSLocalizedString(@"Email", @""), nil];
    
    
	[actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"My LinGEO bookmarks"];
        [controller setMessageBody:[self generateHTMLoutputForEmail] isHTML:YES]; 
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }    
    if(buttonIndex == 0) {
        LinGEOAppDelegate *delegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
		[delegate deleteBookmark:self.bookmark];
		[self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email sent successfully" message:[bookmark eng]
                                                       delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [adViewController layoutForCurrentOrientation:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Warning in BookmarkDetailView");
}


- (void)dealloc {
    [adViewController release];
	[webView release];
	[bookmark release];
	[super dealloc];
}


@end
