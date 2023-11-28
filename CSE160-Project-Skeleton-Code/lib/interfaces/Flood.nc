#include "../../includes/packet.h"

interface Flood{
    command void start();
    command void receiveFlood(pack* msg);
    command void ping(uint16_t dest);
    command void threeWayHandshake(uint16_t dest);
    command void threeWayHandAck(pack* msg);
    command void sendFun(uint16_t dest);
    command void ackFun(pack* msg);
    // command void sendAckFun(pack* msg);
}
