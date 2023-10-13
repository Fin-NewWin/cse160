#include "../../includes/am_types.h"

configuration FloodC{
    provides interface Flood;
}

implementation{
    components FloodP;
    Flood = FloodP;

    components new TimerMilliC() as sendTimer;
    FloodP.sendTimer -> sendTimer;

    components new SimpleSendC(AM_PACK);
    FloodP.SimpleSend -> SimpleSendC;

    components NeighC as Neigh;
    FloodP.Neigh -> Neigh;


}
