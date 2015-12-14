all: bindings completion
bindings:
	cd frameworks/cocos2d-x/tools/tolua/ && python genbindings.py

completion:
	zip frameworks/cocos2d-x/MotionBlurLayer.zip frameworks/cocos2d-x/cocos/scripting/lua-bindings/auto/api/MotionBlurLayer.lua
