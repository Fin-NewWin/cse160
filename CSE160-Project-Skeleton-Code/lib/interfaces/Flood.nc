#include "../../includes/packet.h"

interface Flood{
    command void start();
    command void receiveFlood(pack* msg);
    command void ping(uint16_t dest);
}
