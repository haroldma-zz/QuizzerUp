ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = QuizzerUp
QuizzerUp_FILES = Tweak.xm
QuizzerUp_LDFLAGS = -L./GoogleMobileAdsSdkiOS
QuizzerUp_FRAMEWORKS = UIKit AdSupport AudioToolbox AVFoundation CoreGraphics CoreTelephony EventKit EventKitUI MessageUI StoreKit SystemConfiguration
QuizzerUp_LIBS = libGoogleAdMobAds

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 com.plainvanillacorp.quizup"
SUBPROJECTS += quizzerupprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
