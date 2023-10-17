/*
 * ANDES Lab - University of California, Merced
 * This class provides the basic functions of a network node.
 *
 * @author UCM ANDES Lab
 * @date   2013/09/03
 *
 */
#include <Timer.h>
#include "includes/command.h"
#include "includes/packet.h"
#include "includes/CommandMsg.h"
#include "includes/sendInfo.h"
#include "includes/channels.h"

module Node{
    uses interface Boot;

    uses interface SplitControl as AMControl;
    uses interface Receive;

    uses interface SimpleSend as Sender;

    uses interface Neigh;
    uses interface Flood;
    uses interface SimpleFlood;
    uses interface Dijk;

    uses interface CommandHandler;

    uses interface Timer<TMilli> as neighborDisc;
}

implementation{
    pack sendPackage;

    bool done = FALSE;
    // Prototypes
    void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t Protocol, uint16_t seq, uint8_t *payload, uint8_t length);

    event void Boot.booted(){
        call AMControl.start();

        dbg(GENERAL_CHANNEL, "Booted\n");
    }

    event void AMControl.startDone(error_t err){
        if(err == SUCCESS){
            dbg(GENERAL_CHANNEL, "Radio On\n");
            call neighborDisc.startPeriodic(50000);
        }else{
            //Retry until successful
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err){}

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){

        // dbg(GENERAL_CHANNEL, "Packet Received\n");
        if(len==sizeof(pack)){
            pack* myMsg=(pack*) payload;
            // dbg(GENERAL_CHANNEL, "Packet Received with TTL: %d\n", myMsg->TTL);

            if(myMsg->protocol == PROTOCOL_NEIGHBOR_REQ){
                // dbg(GENERAL_CHANNEL, "Recieved Payload From: %d %d\n", myMsg->seq, myMsg->TTL);
                call Neigh.receiveNeighReq(myMsg->TTL, myMsg->src, myMsg);
            }

            if(myMsg->protocol == PROTOCOL_NEIGHBOR_ACK){
                // dbg(GENERAL_CHANNEL, "Neighbor Ack from: %d\n", myMsg->src);
                call Neigh.receiveNeighAck(myMsg->TTL, myMsg->src, myMsg);
            }

            if(myMsg->protocol == PROTOCOL_FLOOD){
                // dbg(GENERAL_CHANNEL, "Flood Packet from: %d\n", myMsg->src);
                call SimpleFlood.receiveSimpleFlood(myMsg);
                //call Flood.receiveFlood(myMsg);
            }

            return msg;
        }
        dbg(GENERAL_CHANNEL, "Unknown Packet Type %d\n", len);
        return msg;
    }


    event void CommandHandler.ping(uint16_t destination, uint8_t *payload){
        dbg(GENERAL_CHANNEL, "PING EVENT \n");
        makePack(&sendPackage, TOS_NODE_ID, destination, 0, 0, 0, payload, PACKET_MAX_PAYLOAD_SIZE);
    }

    event void neighborDisc.fired(){
        if(!done)
            dbg(FLOODING_CHANNEL, "FLOODING NETWORK\n");
            call Neigh.discNeigh();
            //call Flood.start();
            call SimpleFlood.start();
        done = TRUE;
    }

    

    event void CommandHandler.printNeighbors(){}

    event void CommandHandler.printRouteTable(){}

    event void CommandHandler.printLinkState(){}

    event void CommandHandler.printDistanceVector(){}

    event void CommandHandler.setTestServer(){}

    event void CommandHandler.setTestClient(){}

    event void CommandHandler.setAppServer(){}

    event void CommandHandler.setAppClient(){}

    void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
        Package->src = src;
        Package->dest = dest;
        Package->TTL = TTL;
        Package->seq = seq;
        Package->protocol = protocol;
        memcpy(Package->payload, payload, length);
    }
}
