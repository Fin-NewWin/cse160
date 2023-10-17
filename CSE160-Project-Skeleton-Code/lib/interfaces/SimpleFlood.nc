#include "../../includes/packet.h"

interface SimpleFlood{
    command void start();
    command void receiveSimpleFlood(pack *msg);
}
