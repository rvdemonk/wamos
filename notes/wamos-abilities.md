# WAM0S ABILITIES

dietyType \in [0,7] -> one of the gods  

effectType \in [0,2] -> meelee, range, magic  

power \in [0,99] -> magntitude of effect  

accuracy \in [0,99] -> influences prob of success  

range \in [0,6] -> radius of ability in adjacent squares  

cost \in [0,99] -> depletion to stamina (meelee), mana (magic), focus (range)  

cooldown \in [0,10] -> min number of turns before next use  

### buffs and debuffs

how to determine?
move is either offensive - damages health or other attribute
or defensive - buffs attribute


## eventually

abilities are nfts, some are soulbound, others can be traded

## comments written inside function code
        // require wamo to be in players party
        // require wamo to be alive
        // require movement to remain on board
        // require targetGridIndex to be between [0,255]
        // require targetGridIndex to be within radius of 
        //------//
        // mutate position index
        // set mapping gridIndex -> wamoId
        // get wamo on target gridindex
        // -> pseudo randomness injected into move outcome
        // calculate damage/ability effect
        // if effectype 1 -> meelee; if effect type2
        // mutate target wamos stats (or target gridindex stats)
        // increment turn
        // emit event
