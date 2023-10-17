#include "../../includes/am_types.h"

configuration SimpleFloodC{
    provides interface SimpleFlood;
}

implementation{
    components SimpleFloodP;
    SimpleFlood = SimpleFloodP;

    components new TimerMilliC() as sendTimer;
    SimpleFloodP.sendTimer -> sendTimer;

    components new SimpleSendC(AM_PACK);
    SimpleFloodP.SimpleSend -> SimpleSendC;

}
