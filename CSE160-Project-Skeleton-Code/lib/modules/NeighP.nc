#include "../../includes/packet.h"
#include "../../includes/sendInfo.h"
#include "../../includes/channels.h"

module NeighP{
    provides interface Neigh;

    uses interface SimpleSend;
    uses interface Dijk;
}

implementation{
    pack sendReq;
    pack sendAck;
    uint8_t* packet = "";

    uint16_t ttl = MAX_TTL;
    uint16_t ttl2 = MAX_TTL;
    uint8_t i;
    uint16_t sequenceNum = 0;

    uint8_t* list;
    uint8_t NeighborList[20] = { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };

    void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
        Package->src = src;
        Package->dest = dest;
        Package->TTL = TTL;
        Package->seq = seq;
        Package->protocol = protocol;
        memcpy(Package->payload, payload, length);
    }

    void printNeigh(){
        printf("My(%d) current neighbors: [", TOS_NODE_ID);
        for(i = 0; i < 20; i++){
            if(NeighborList[i] != 255 && NeighborList[i] != 0)
            printf("%d, ", i);
        }
        printf("]\n");
    }

    command void Neigh.print(){
        printNeigh();
    }

    command uint8_t* Neigh.get(){
        return NeighborList;
    }

    command void Neigh.updateTab(){
        list = call Dijk.get();
        for(i = 0; i < 20; i++){
            if(list[i] != 255 && NeighborList[i] != 1){
                NeighborList[i] = list[i];
            }
        }
    }


    command void Neigh.receiveNeighAck(uint16_t ttl, uint16_t src, pack* msg){
        if(NeighborList[src] == 255){
            NeighborList[src] = 1;
            call Dijk.neigh();
            printNeigh();
        } 
        call Dijk.algo(msg);

    }

    command void Neigh.receiveNeighReq(uint16_t ttl, uint16_t src, pack* msg){
        if(ttl2 != 0){
            ttl2--;
            makePack(&sendAck, TOS_NODE_ID, src, ttl2, PROTOCOL_NEIGHBOR_ACK, TOS_NODE_ID, NeighborList, packet);
            call SimpleSend.send(sendAck, src);
        }
        call Dijk.algo(msg);
    }

    command void Neigh.discNeigh(){
        NeighborList[TOS_NODE_ID] = 0;
        if(ttl == 0){
            ttl = MAX_TTL;
        } else {
            ttl--;
            makePack(&sendReq, TOS_NODE_ID, AM_BROADCAST_ADDR, ttl, PROTOCOL_NEIGHBOR_REQ, sequenceNum, NeighborList, packet); 
            call SimpleSend.send(sendReq, AM_BROADCAST_ADDR);
            sequenceNum++;
        }
    }

}

