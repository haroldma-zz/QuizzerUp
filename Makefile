include theos/makefiles/common.mk

TWEAK_NAME = QuizzerUp
QuizzerUp_FILES = Tweak.xm
QuizzerUp_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 com.plainvanillacorp.quizup"
