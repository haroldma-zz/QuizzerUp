@protocol ViewModel
@end

@protocol View <NSObject>
@property(retain, nonatomic) id<ViewModel> viewModel;
@end

@protocol Scene <NSObject, View>
-(id)navigationItemConfiguration;
-(unsigned)minimumAlertPriority;
-(id)analyticsName;
-(BOOL)canOpenSideBar;
-(BOOL)goesInStack;
-(BOOL)hideTopBar;
@optional
-(void)willDisappear;
-(id)analyticsTopicSlug;
-(id)analyticsUserID;
-(id)nameSignal;
@end


@interface GameSceneViewModel : NSObject <ViewModel> {}

-(void)start;
-(void)endGame;

@end

@interface GameScene <Scene>

@property(assign, nonatomic) __weak UIView* contentPanel;
@property(retain, nonatomic) UIViewController* activePanel;
@property(retain, nonatomic) GameSceneViewModel* viewModel;

@end