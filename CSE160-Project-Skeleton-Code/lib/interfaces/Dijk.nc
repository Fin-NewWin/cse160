#include "../../includes/packet.h"

interface Dijk{
    command void neigh();
    command void algo(pack* msg);
    command void change();
    command uint8_t* get();
}
