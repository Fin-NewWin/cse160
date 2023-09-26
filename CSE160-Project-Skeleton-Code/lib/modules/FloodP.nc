#include "../../includes/packet.h"
#include "../../includes/channels.h"
module FloodP{
    provides interface Flood;
    uses interface SimpleSend;
    uses interface Timer<TMilli> as sendTimer;
}
implementation{
    uint8_t storedSeq[20] = {
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    };
    uint8_t i;
    uint8_t j = 0;
    pack* floodPack;
    command void Flood.start(pack* msg) {
        floodPack = msg;
        call sendTimer.startPeriodic(5000);
    }
    event void sendTimer.fired(){
        floodPack->TTL = floodPack->TTL - 1;
        floodPack->src = TOS_NODE_ID;
        for(i = 0; i < 20; i++) {
            if (floodPack->seq == storedSeq[i]){
                return;
            }
        }
        if(floodPack->dest != TOS_NODE_ID){
            if (j == 20){
                j = 0;
            }
            storedSeq[j] = floodPack->seq;
            j++;
            call SimpleSend.send(*floodPack, AM_BROADCAST_ADDR);
        }
    }
}
