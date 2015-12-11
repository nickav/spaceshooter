// CustomClass.h

#ifndef __CUSTOM__CLASS

#define __CUSTOM__CLASS

#include "cocos2d.h"

namespace cocos2d {
    class CustomClass : public cocos2d::Ref
    {
    public:
        
        CustomClass();
        
        ~CustomClass();
        
        bool init();
        
        std::string helloMsg();
        
        CREATE_FUNC(CustomClass);
    };
} //namespace cocos2d

#endif // __CUSTOM__CLASS