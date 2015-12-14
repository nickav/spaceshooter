//
//  MotionBlurLayer.cpp
//  cocos2d_libs
//
//  Created by Nick Aversano on 12/13/15.
//
//

#include "MotionBlurLayer.h"

USING_NS_CC;

MotionBlurLayer::MotionBlurLayer() {
}

MotionBlurLayer::~MotionBlurLayer() {
}

bool MotionBlurLayer::init(int count) {
    kRenderTextureCount = count;
    renderTextures = cocos2d::Vector<cocos2d::RenderTexture *>{kRenderTextureCount};
    
    Size winSize = getContentSize();
    for (int i = 0; i < kRenderTextureCount; i++) {
        RenderTexture *rtx = RenderTexture::create((int)winSize.width, (int)winSize.height);
        rtx->setPosition(ccp(winSize.width / 2, winSize.height / 2));
        
        Sprite *renderSprite = Sprite::createWithTexture(rtx->getSprite()->getTexture());
        renderSprite->setPosition(rtx->getPosition());
        this->addChild(renderSprite, 100 + i);
        rtx->setUserData(renderSprite);
        renderTextures.pushBack(rtx);
    }
    
    return true;
}

bool MotionBlurLayer::init() {
    return init(DEFAULT_COUNT);
}

void MotionBlurLayer::visit(Renderer *renderer, const Mat4& parentTransform, uint32_t parentFlags) {
    RenderTexture* rtx = (RenderTexture *)renderTextures.at(currentRenderTextureIndex);
    rtx->beginWithClear(0, 0, 0, 0);
    
    for (auto& node : this->getChildren()) {
        if (((Node *)node)->getTag() != NO_MOTION_BLUR) {
            ((Node *)node)->visit(renderer, parentTransform, parentFlags);
        }
    }

    rtx->end();

    // selectNextRenderTexture
    currentRenderTextureIndex ++;
    if (currentRenderTextureIndex >= kRenderTextureCount) {
        currentRenderTextureIndex = 0;
    }
    
    int index = currentRenderTextureIndex;
    for (int i = 0; i < kRenderTextureCount; i++) {
        RenderTexture* rtx = (RenderTexture*)renderTextures.at(currentRenderTextureIndex);
        Sprite* renderSprite = (Sprite*)rtx->getUserData();
        renderSprite->setOpacity((255.0f / kRenderTextureCount) * (i + 1));
        renderSprite->setScaleY(-1);
        this->reorderChild(renderSprite, 100 + i);

        // selectNextRenderTexture
        currentRenderTextureIndex ++;
        if (currentRenderTextureIndex >= kRenderTextureCount) {
            currentRenderTextureIndex = 0;
        }
        
        index++;
        if (index >= kRenderTextureCount) {
            index = 0;
        }
    }
    
    for (auto& node : this->getChildren()) {
        if (((Node *)node)->getTag() != NO_MOTION_BLUR) {
            ((Node *)node)->visit(renderer, parentTransform, parentFlags);
        }
    }
}