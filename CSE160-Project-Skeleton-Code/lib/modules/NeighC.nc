#include "../../includes/am_types.h"

configuration NeighC{
    provides interface Neigh;
}

implementation{
    components new SimpleSendC(AM_PACK);
    components NeighP;
    Neigh = NeighP;

    NeighP.SimpleSend -> SimpleSendC;
}
