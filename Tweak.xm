#import "GoogleMobileAdsSdkiOS/GADBannerView.h"
#import "GoogleMobileAdsSdkiOS/GADRequest.h"
#import "GoogleMobileAdsSdkiOS/GADAdSize.h"

////////////////////////////
//Interfaces
////////////////////////////

@interface Question : NSObject {}

//index to the correct answer ;)
@property(assign, nonatomic) int correctAnswerIndex;

//answers array
@property(retain, nonatomic) NSMutableArray* answers;

@end

@interface Answer : NSObject {}

//answer id
@property(retain, nonatomic) NSString* ID;

@end

@interface MatchScene : NSObject {}
//called when the user selects an answer. the parameter is for the id.
-(void)playerChoseAnswer:(id)answer;
-(void)showCorrectAnswer;
@end

@interface MatchLogic : NSObject {}
-(void)endMatch;
-(void)endRound;
@end

@interface SceneController : NSObject {}
+(id)sharedInstance;
-(void)showAlertWithTitle:(id)title message:(id)message;
-(void)runMatchupPreambleScene:(id)scene source:(id)source;
@end

@interface NavigationController : UINavigationController {}
@end

////////////////////////////
////////////////////////////

//local variable use for storing the current question
Question *currentQuestion;

//for saving current topic for auto-finding matches
NSObject *match_scene;

//advertisement
GADBannerView *bannerView;

//Hooking to the match scene (where all the magic happens)
%hook MatchScene

//display the answers (using it to get the question object)
-(void)showAnswersForQuestion:(id)question animationTime:(float)time{
	%orig;
	[self showCorrectAnswer];

	//update the current question
	currentQuestion = question;
}

//user can now chose an answer, we do it for them ;)
-(void)answerPeriodStarted:(double)started{
	%orig;

	//get the correct answer
	Answer *correctAnswer = [currentQuestion.answers
															objectAtIndex:currentQuestion.correctAnswerIndex];

  //call the following method to select it (passing the id only)
  [self playerChoseAnswer:correctAnswer.ID];
}

%end

BOOL test= false;

%hook MatchLogic

//instead of showing error, just end it, when in bot mode.

-(void)opponentLeft{
	[self endMatch];
}

-(void)opponentDisappeared{
	[self endMatch];
}

-(void)opponentSurrendered{
	[self endMatch];
}

-(void)networkErrorHappened{
	[self endMatch];
}

%end

%hook EndGameScene

//called when the transition ends
-(void)enterTransitionDidEnd{
	%orig;

	//perfect time for a match up
	[[%c(SceneController) sharedInstance]
		runMatchupPreambleScene:match_scene source:nil];
}

%end

%hook AppDelegate

-(BOOL)application:(id)application didFinishLaunchingWithOptions:(id)options{

	//need to call the original method, where it initiates the SceneController
	BOOL result = %orig;

	//by using the scenecontroller we can show a QuizUp alert
	//making it look official :)
	[[%c(SceneController) sharedInstance]
		showAlertWithTitle:@"QuizzerUp v2.0"
		message:@"Enjoy the hack and follow @zumicts for updates and requests. Check out the site at quizzerup.com"];

	//now return the original result
	return result;
}

%end

BOOL adLoaded = NO;

%hook SceneController

-(void)runMatchupPreambleScene:(id)scene source:(id)source{
	//saving the topic for re-matchup at the end
	match_scene = scene;
	%orig;

	if (!adLoaded){
		//add as subview
		[bannerView.rootViewController.view addSubview:bannerView];

		GADRequest *request = [%c(GADRequest) request];
		[bannerView loadRequest:request];
		adLoaded = YES;
	}
}

%end

%hook NavigationController

-(id)initWithRootViewController:(id)rootViewController firstScene:(id)scene{
	id result = %orig;

  // Create a banner ad and add it to the view hierarchy.
  bannerView = [[%c(GADBannerView) alloc] initWithFrame:CGRectMake(0,
                                              self.view.frame.size.height - 50,
                                              320,
                                              50)];
	bannerView.adUnitID = @"ca-app-pub-2032082174805601/4616841378";
  bannerView.rootViewController = self;

	return result;
}

%end
