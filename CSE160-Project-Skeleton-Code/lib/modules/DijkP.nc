#include "../../includes/packet.h"
#include "../../includes/channels.h"

module DijkP{
    provides interface Dijk;

    uses interface Neigh;
}

implementation{

    uint16_t ttl = MAX_TTL;
    uint8_t i;
    bool change = FALSE;
    uint8_t* list;
    uint8_t* list2;

    uint8_t routeHop[20] = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};
    uint8_t routeAddr[20] = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};
    uint8_t newList;

    void printTable(){
        printf("me(%d):", TOS_NODE_ID);
        for(i = 0; i < 20; i++){
            if(routeHop[i] != 255){
                printf("%d(%d)%d, ", routeHop[i], routeAddr[i], i);
            }
        }
        printf("\n");
    }

    command uint8_t* Dijk.get(){
        return routeHop;
    }

    command void Dijk.change(){
        if(change){
            call Neigh.updateTab();
            call Neigh.discNeigh();
            printTable();
        }
        change = FALSE;
    }

    command void Dijk.algo(pack* msg){
        list2 = msg->payload;
        for(i = 0; i < 20; i++){
            if(list2[i] + 1 < routeHop[i] && i != TOS_NODE_ID){
                routeHop[i] = list2[i] + 1;
                routeAddr[i] = msg->src;
                change = TRUE;
            }
        }
        call Dijk.change();
    }

    command void Dijk.neigh(){
        // updates neighbor first
        list = call Neigh.get();
        for(i = 0; i < 20; i++){
            if(routeHop[i] != 1 && list[i] == 1){
                routeHop[i] = 1;
                routeAddr[i] = i;
                change = TRUE;
            }
        }
        call Dijk.change();

        // printf("me(%d):", TOS_NODE_ID);
        // for(i = 0; i < 20; i++){
        //     if(routeHop[i] == 1){
        //         printf("%d(%d):", routeHop[i], routeAddr[i]);
        //     }
        // }
        // printf("\n");
    }

}
