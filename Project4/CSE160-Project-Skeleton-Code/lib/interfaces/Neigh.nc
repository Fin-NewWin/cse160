#include "../../includes/packet.h"

interface Neigh{
	command void discNeigh();
    command void receiveNeighReq(uint16_t ttl, uint16_t src, pack* msg);
    command void receiveNeighAck(uint16_t ttl, uint16_t src, pack* msg);
    command void print();
    command uint8_t* get();
    command void updateTab();
}
