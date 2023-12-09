/**
 * ANDES Lab - University of California, Merced
 * This class provides the basic functions of a network node.
 *
 * @author UCM ANDES Lab
 * @date   2013/09/03
 *
 */

#include <Timer.h>
#include "includes/CommandMsg.h"
#include "includes/packet.h"

configuration NodeC{
}
implementation {
    components MainC;
    components Node;
    components new AMReceiverC(AM_PACK) as GeneralReceive;
    components new TimerMilliC() as neighborDisc;

    Node -> MainC.Boot;

    Node.Receive -> GeneralReceive;

    components ActiveMessageC;
    Node.AMControl -> ActiveMessageC;

    components new SimpleSendC(AM_PACK);
    Node.Sender -> SimpleSendC;

    components FloodC;
    Node.Flood -> FloodC;

    components NeighC;
    Node.Neigh -> NeighC;
    Node.neighborDisc -> neighborDisc;

    components DijkC;
    Node.Dijk -> DijkC;

    components SimpleFloodC;
    Node.SimpleFlood -> SimpleFloodC;

    components CommandHandlerC;
    Node.CommandHandler -> CommandHandlerC;

}
