﻿----------------------------------------------------------------------
    
    local moveLeft  = CCMoveBy:create(0.05, ccp(15,0))
	local moveRight = CCMoveBy:create(0.05, ccp(-15,0))
	local action = CCRepeat:create(CCSequence:createWithTwoActions(moveLeft, moveRight), 10)
    self.mMoveNode:runAction(action)