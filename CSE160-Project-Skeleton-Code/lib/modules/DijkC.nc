#include "../../includes/am_types.h"

configuration DijkC{
    provides interface Dijk;
}

implementation{
    components DijkP;
    Dijk = DijkP;

    components NeighC as Neigh;
    DijkP.Neigh -> Neigh;

}
