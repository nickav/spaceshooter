//
//  MotionBlurLayer.h
//  cocos2d_libs
//
//  Created by Nick Aversano on 12/13/15.
//
//

#ifndef __MOTION_BLUR_LAYER__
#define __MOTION_BLUR_LAYER__

#include "cocos2d.h"

namespace cocos2d {

    class MotionBlurLayer : public cocos2d::Layer {
    public:
        static const int NO_MOTION_BLUR = 99999998;
        static const int DEFAULT_COUNT  = 10;

        CREATE_FUNC(MotionBlurLayer);
        static MotionBlurLayer* create(int count) {
            MotionBlurLayer *pRet = new MotionBlurLayer();
            if (pRet && pRet->init(count)) {
                pRet->autorelease();
                return pRet;
            } else {
                delete pRet;
                pRet = NULL;
                return NULL;
            }
        }
        
        MotionBlurLayer();
        ~MotionBlurLayer();
        bool init();
        bool init(int count);
        virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);

    protected:
        cocos2d::Vector<cocos2d::RenderTexture*> renderTextures;
        int kRenderTextureCount;
        int currentRenderTextureIndex;
    };

} // namespace cocos2d

#endif // __MOTION_BLUR_LAYER__
