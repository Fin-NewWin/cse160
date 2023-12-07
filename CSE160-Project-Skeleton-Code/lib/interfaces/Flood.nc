#include "../../includes/packet.h"

interface Flood{
    command void start();
    command void receiveFlood(pack* msg);
    command void ping(uint16_t dest);
    command void threeWayHandshake(uint16_t dest);
    command void threeWayHandAck(pack* msg);
    command void sendFun(uint16_t dest);
    command void ackFun(pack* msg);
    command void sendAckFun(pack* msg);
    command void ackFIN(pack* msg);
    command void sendMsg(uint8_t *payload);
    command void receiveMsg(pack* msg);
    command void sendBackMsg(uint8_t* payload);
    command void receiveBackMsg(pack* msg);

    // command void gotFromClient(pack* msg);
}
