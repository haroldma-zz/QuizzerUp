#define PLIST_PATH @"/var/mobile/Library/Preferences/com.zumicts.quizzerupprefs.plist"

#import "includes/Application.h"
#import "includes/AlertService.h"
#import "includes/MatchLogic.h"
#import "includes/GameScene.h"
#import "includes/Answer.h"
#import "includes/ChooseOpponentOverlay.h"
#import "includes/GameResultsCellViewModel.h"
#import "includes/ErrorPanel.h"
#import "includes/Question.h"

//local variables
bool isBotMode;
bool isEndlessMatching;
bool showIndicator;
int currentRound;
Question *currentQuestion;
GameScene *currentGameScene;


//prefs bundle
inline bool GetPrefBool(NSString *key)
{
	NSDictionary *quizzerUpTweakSettings = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	NSNumber *value = quizzerUpTweakSettings[key];
	return value ? [value boolValue] : YES;
}

inline Application* GetApp()
{
	return [%c(Application) sharedInstance];
}


%hook GameScene

-(void)viewDidLoad {
	%orig;
	currentGameScene = self;	
}

%end

//Hooking to the match logic (where all the magic happens)

%hook MatchLogic

-(id)showAnswersForRound:(int)round question:(id)question {
	//update the current question
	currentQuestion = question;
	currentRound = round;
	return %orig;
}

//user can now chose an answer, we do it for them ;)
-(id)startAnswerPeriodForRound:(int)round answerPeriod:(id)period {
	id result = %orig;

	// anything smaller than 3.0f will not work (time that it takes for the scene to be ready)
	double indicatorDelay = 1.0f;
	double delay = 3.0f;
	UIView *mainView = currentGameScene.contentPanel;
	Answer *answer = [currentQuestion.answers objectAtIndex:[currentQuestion indexForAnswerID:currentQuestion.correctAnswerID]];


	// before v2.0 this was called exactly when the answers were viewable.
	// now it takes around 2-3 secs for them to be viewable (and selectable)
	// hence, we need to wait without blocking the thread.
	// dispatch a queue on the bg thread, wait, switch to ui and proceed.
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	if (isBotMode){
		dispatch_async(queue, ^{
			[NSThread sleepForTimeInterval:delay]; 
			dispatch_async(dispatch_get_main_queue(), ^{
				[self playerChoseAnswer:answer];
			});
		});
	}	
	if(isEndlessMatching) {	
		dispatch_async(queue, ^{
			[NSThread sleepForTimeInterval:indicatorDelay]; 
			dispatch_async(dispatch_get_main_queue(), ^{
				CGRect frame = CGRectMake(0, 0, CGRectGetWidth(mainView.frame), 200);

				// create a custom black view
				UIView *overlayView = [[UIView alloc] initWithFrame:frame];
				overlayView.backgroundColor = [UIColor blackColor];
				overlayView.alpha = 0.7;
				overlayView.tag = 777;

				// create a label
				UILabel *message = [[UILabel alloc] initWithFrame:frame];
				[message setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
				message.text = answer.text;
				message.textColor = [UIColor whiteColor];
				message.numberOfLines = 4;
				message.lineBreakMode = UILineBreakModeWordWrap;
				message.textAlignment = NSTextAlignmentCenter;
				message.tag = 778;

				// TODO: donate button
				// UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
			 //    [button setTitle:@"Donate!" forState:UIControlStateNormal];
			 //    button.layer.cornerRadius = 2;
				// button.layer.borderWidth = 1;
				// button.layer.borderColor = [UIColor blueColor].CGColor;
			 //    [button sizeToFit];
			 //    button.center = CGPointMake(320/2, 60);

			    // Add an action in current code file (i.e. target)
			    //[button addTarget:self action:@selector(buttonPressed:)
			     //forControlEvents:UIControlEventTouchUpInside];

				// and just add them to navigationbar view
				[mainView addSubview:overlayView];
				[mainView addSubview:message];
				//[mainView addSubview:button];
			});
});
}
return result;
}

%end

%hook MatchEvent

+(id)endAnswerPeriodEventForRound:(int)round{
	// clean up
	UIView *mainView = currentGameScene.contentPanel;

	UIView *viewToRemove = [mainView viewWithTag:777];
	if (viewToRemove != nil)
		[viewToRemove removeFromSuperview];
	viewToRemove = [mainView viewWithTag:778];
	if (viewToRemove != nil)
		[viewToRemove removeFromSuperview];

	return %orig;
}

+(id)networkError{
	if(isBotMode && isEndlessMatching) {
		[currentGameScene.viewModel endGame];
		return 0;
	}
	else {
		return %orig;
	}
}

+(id)surrenderEventWithPlayer:(id)player{
	if(isBotMode && isEndlessMatching) {
		[currentGameScene.viewModel endGame];
		return 0;
	}
	else {
		return %orig;
	}
}

%end

%hook GameResultsCellViewModel

-(void)setup{
	%orig;

	if (isBotMode && isEndlessMatching) {
		// Let's play another game!
		[self play];
	}
}

-(void)opponentSentRematchRequest{
	// in bot mode we don't care about rematches
	if(!isBotMode || !isEndlessMatching) {
		%orig;
	}
}

%end

%hook ChooseOpponentOverlay

-(void)viewDidAppear:(BOOL)view{
	%orig;
	if (isBotMode && isEndlessMatching) {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_async(queue, ^{
			[NSThread sleepForTimeInterval:1]; 
			dispatch_async(dispatch_get_main_queue(), ^{
				[self playNow:self.playNowButton];
			});
		});
	}
}


%end

%hook ErrorPanel

-(void)viewDidAppear:(BOOL)view{
	%orig;

	if (isBotMode && isEndlessMatching) {
		[self tryAgain:self.tryAgainButton];
	}
}

%end

%hook AppDelegate

-(BOOL)application:(id)application didFinishLaunchingWithOptions:(id)options{

	//need to call the original method, where it initiates the Application object
	BOOL result = %orig;

	// With 2.0 they overhaul the whole app, so alerts don't work like before
	// but now is much easier, since, they have a singleton object to access everything ;)
	[GetApp().alertService
		showAlertWithTitle:@"QuizzerUp v3.0"
		message:@"Configure the bot in the settings app. Enjoy the hack and follow @zumicts for updates and requests. Check out the site at quizzerup.com"];

	isBotMode = GetPrefBool(@"BotMode");
	isEndlessMatching = GetPrefBool(@"EndlessMatching");
	showIndicator = GetPrefBool(@"AnswerIndicator");

	//now return the original result
	return result;
}

%end
