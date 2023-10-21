#include "../../includes/packet.h"
#include "../../includes/channels.h"
module FloodP{
    provides interface Flood;
    uses interface SimpleSend;
    uses interface Timer<TMilli> as sendTimer;
    uses interface Neigh;
    uses interface Dijk;
}

implementation{
    uint8_t i;
    uint8_t j;
    uint8_t packet = "";

    uint16_t ttl = MAX_TTL;
    uint16_t sequenceNum = 0;
    uint8_t* list;
    uint8_t* list2;

    pack floodPack;

    bool done = FALSE;

    uint8_t seqSeen[20] = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};

    uint8_t bestTTL[20] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};


    void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
        Package->src = src;
        Package->dest = dest;
        Package->TTL = TTL;
        Package->seq = seq;
        Package->protocol = protocol;
        memcpy(Package->payload, payload, length);
    }


    command void Flood.receiveFlood(pack* msg){
        // printf("me(%d)", msg->src);
        // for(i = 0; i < 20; i++){
        //     if(msg->payload[i] != 255){
        //         printf("%d,", msg->payload[i]);
                
        //     } else {
        //         printf("0,");
        //     }
        // }
        // printf("\n");
        
        printf("Me(%d) from:%d sending:%d\n", TOS_NODE_ID, msg->src, msg->dest);
        call Dijk.printTable();
        list2 = call Dijk.getAddr();
        if(TOS_NODE_ID != msg->dest){
            if (list2[msg->dest] != 255){
                msg->TTL--;
                call SimpleSend.send(*msg, list2[msg->dest]);
            }
        }
        // } else if (msg->src != TOS_NODE_ID && msg->TTL !=  0 && seqSeen[msg->src] != msg->seq){
        //     // if(msg->TTL > bestTTL[msg->src]){
        //     //     bestTTL[msg->src] = msg->TTL;
        //     //     printf("Me(%d) from:%d seq:%d with TTL: %d\n", TOS_NODE_ID, msg->src, msg->seq, msg->TTL);
        //     // }
        //     seqSeen[msg->src] = msg->seq;
        //     msg->TTL--;
        //     for(i = 0; i < 20; i++){
        //         if (list[i] == 1) {
        //             call SimpleSend.send(*msg, i);
        //         }
        //     }
        // }
    }

    command void Flood.start(){
        // printf("This shit from flood\n");
        // call Neigh.print();
        call sendTimer.startPeriodic(5000);
    }

    command void Flood.ping(uint16_t dest){
        list = call Neigh.get();
        list2 = call Dijk.getAddr();
        if (list2[dest] != 255){
            makePack(&floodPack, TOS_NODE_ID, dest, ttl, PROTOCOL_FLOOD, 0, list, packet); 
            call SimpleSend.send(floodPack, list2[dest]);
        } 
    }

    event void sendTimer.fired(){
        if(!done){
            if (sequenceNum == 20) {
                sequenceNum = 0;
            }
            list = call Neigh.get();
            for(i = 0; i < 20; i++){
                if (list[i] == 1) {
                    makePack(&floodPack, TOS_NODE_ID, i, ttl, PROTOCOL_FLOOD, sequenceNum, list, packet); 
                    call SimpleSend.send(floodPack, i);
                }
            }
            sequenceNum++;
        }
    }

}
