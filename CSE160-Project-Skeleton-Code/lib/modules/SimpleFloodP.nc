#include "../../includes/packet.h"
#include "../../includes/channels.h"
module SimpleFloodP{
    provides interface SimpleFlood;
    uses interface SimpleSend;
    uses interface Timer<TMilli> as sendTimer;
}

implementation{
    uint8_t i;
    uint8_t j;
    uint8_t packet = "";

    uint16_t ttl = MAX_TTL;
    uint16_t sequenceNum = 0;
    uint8_t* list = "";

    pack floodPack;
    pack sendReq;

    bool done = FALSE;

    uint8_t seqSeen[20] = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};

    uint8_t bestTTL[20] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    uint8_t* payload[1] = {0};


    void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
        Package->src = src;
        Package->dest = dest;
        Package->TTL = TTL;
        Package->seq = seq;
        Package->protocol = protocol;
        memcpy(Package->payload, payload, length);
    }

     void sendNow(){
        if(done == FALSE){
            if(sequenceNum == 20){
                sequenceNum = 0;
            }
            makePack(&sendReq, TOS_NODE_ID, AM_BROADCAST_ADDR, ttl, PROTOCOL_FLOOD, sequenceNum, payload, packet); 
            call SimpleSend.send(sendReq, AM_BROADCAST_ADDR);
            sequenceNum++;  
        }
    }

    command void SimpleFlood.receiveSimpleFlood(pack* msg){
        if(msg->src != TOS_NODE_ID && seqSeen[msg->seq] != msg->seq && msg->TTL != 0){
            seqSeen[msg->seq] = msg->seq; //NOW WE SEE YOU
            msg->TTL--;
            call SimpleSend.send(*msg, AM_BROADCAST_ADDR); 
                //forward packets and not send the same thing
        }

        }
    

    command void SimpleFlood.start(){
        call sendTimer.startPeriodic(5000);
    }

    event void sendTimer.fired(){
        sendNow();

    }

}
