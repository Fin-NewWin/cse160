#include "../../includes/am_types.h"

configuration NeighC{
    provides interface Neigh;
}

implementation{
    components NeighP;
    Neigh = NeighP;

    components new SimpleSendC(AM_PACK);
    NeighP.SimpleSend -> SimpleSendC;

    components DijkC as Dijk;
    NeighP.Dijk -> Dijk;
}
