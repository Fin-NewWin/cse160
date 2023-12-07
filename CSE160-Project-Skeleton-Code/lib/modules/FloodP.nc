#include "../../includes/packet.h"
#include "../../includes/channels.h"
module FloodP{
	provides interface Flood;
	uses interface SimpleSend;
	uses interface Timer<TMilli> as sendTimer;
	uses interface Neigh;
	uses interface Dijk;
}

implementation{
	uint8_t i;
	uint8_t j;
	uint8_t packet = "";

	uint16_t ttl = MAX_TTL;
	uint16_t sequenceNum = 0;
	uint16_t seq2 = 0;
	uint8_t* list;
	uint8_t* list2;

	pack floodPack;

	bool done = FALSE;
	bool wait = FALSE;
	bool sender = TRUE;

	uint8_t dst;

	uint8_t seqSeen[20] = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};

	uint8_t bestTTL[20] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	bool sendFlag[20] = {FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE};
	bool senderFlag[20] = {TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE};
	bool conClient[20] = {FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE};

	uint16_t seqSend = 1;
	uint16_t sendAck = 1;

	uint8_t* pay[] = {"Hello", "World!", "My", "name's", "Phien :)"};

	uint8_t iter = 0;

	uint8_t* message = "Hello ";





	void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
		Package->src = src;
		Package->dest = dest;
		Package->TTL = TTL;
		Package->seq = seq;
		Package->protocol = protocol;
		memcpy(Package->payload, payload, length);
	}

	void makeNew(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
		Package->src = src;
		Package->dest = dest;
		Package->TTL = TTL;
		Package->seq = seq;
		Package->protocol = protocol;
		memcpy(Package->payload, payload, length);
	}


	command void Flood.receiveFlood(pack* msg){
		// printf("me(%d)", msg->src);
		// for(i = 0; i < 20; i++){
		//     if(msg->payload[i] != 255){
		//         printf("%d,", msg->payload[i]);

		//     } else {
		//         printf("0,");
		//     }
		// }
		// printf("\n");

		// printf("Me(%d) from:%d sending:%d\n", TOS_NODE_ID, msg->src, msg->dest);
		call Dijk.printTable();
		list2 = call Dijk.getAddr();
		if(TOS_NODE_ID != msg->dest){

			if (list2[msg->dest] != 255){
				msg->TTL--;
				call SimpleSend.send(*msg, list2[msg->dest]);
			}
		}
		// } else if (msg->src != TOS_NODE_ID && msg->TTL !=  0 && seqSeen[msg->src] != msg->seq){
		//     // if(msg->TTL > bestTTL[msg->src]){
		//     //     bestTTL[msg->src] = msg->TTL;
		//     //     printf("Me(%d) from:%d seq:%d with TTL: %d\n", TOS_NODE_ID, msg->src, msg->seq, msg->TTL);
		//     // }
		//     seqSeen[msg->src] = msg->seq;
		//     msg->TTL--;
		//     for(i = 0; i < 20; i++){
		//         if (list[i] == 1) {
		//             call SimpleSend.send(*msg, i);
		//         }
		//     }
		// }
	}

	command void Flood.start(){
		// printf("This shit from flood\n");
		// call Neigh.print();
		call sendTimer.startPeriodic(5000);
	}

	command void Flood.ping(uint16_t dest){
		list = call Neigh.get();
		list2 = call Dijk.getAddr();
		if (list2[dest] != 255){
			makePack(&floodPack, TOS_NODE_ID, dest, ttl, PROTOCOL_FLOOD, 0, list, packet);
			call SimpleSend.send(floodPack, list2[dest]);
		}
	}

	command void Flood.sendFun(uint16_t dest){
		printf("Sending in the clowns %d\n", TOS_NODE_ID);
		list = call Neigh.get();
		list2 = call Dijk.getAddr();
		makeNew(&floodPack, TOS_NODE_ID, dest, ttl, PROTOCOL_TCP, seqSend, pay[seqSend - 1], packet);
		call SimpleSend.send(floodPack, list2[dest]);
		seqSend++;
	}

	command void Flood.sendAckFun(pack* msg){
		if(msg->dest == TOS_NODE_ID ){
			list = call Neigh.get();
			list2 = call Dijk.getAddr();
			if(sendAck == msg->seq && seqSend <= 5){
				makeNew(&floodPack, TOS_NODE_ID, msg->src, ttl, PROTOCOL_TCP, seqSend, pay[seqSend - 1], packet);
				call SimpleSend.send(floodPack, list2[msg->src]);
				sendAck++;
				seqSend++;
			} else if(seqSend > 5) {
				printf("Closing connection sending FIN\n");
				makePack(&floodPack, TOS_NODE_ID, msg->src, ttl, PROTOCOL_TCP_FIN, seqSend, pay[seqSend - 1], packet);
				call SimpleSend.send(floodPack, list2[msg->src]);
			}
		} else {
			call Flood.receiveFlood(msg);
		}
	}

	command void Flood.ackFIN(pack* msg){
		if(msg->dest == TOS_NODE_ID ){ //checks is source node
			list = call Neigh.get();
			list2 = call Dijk.getAddr();
			if(sendAck == msg->seq){
				makePack(&floodPack, TOS_NODE_ID, msg->src, ttl, PROTOCOL_TCP_FIN, 0, list, packet);
				call SimpleSend.send(floodPack, list2[msg->src]);
			}
		} else {
			call Flood.receiveFlood(msg);
		}
	}

	command void Flood.ackFun(pack* msg){
		if(msg->dest == TOS_NODE_ID ){
			if (sendAck == msg->seq){
				iter = 0;
				printf("Message %d: ", sendAck);
				while(*(msg->payload + sizeof(uint8_t) * iter) != '\0'){
					printf("%c", *(msg->payload + sizeof(uint8_t) * iter));
					iter++;
				}
				printf("\n");

				makePack(&floodPack, TOS_NODE_ID, msg->src, ttl, PROTOCOL_TCP_DATA, sendAck, list, packet);
				call SimpleSend.send(floodPack, list2[msg->src]);
				sendAck++;
			}
		} else {
			call Flood.receiveFlood(msg);
		}
	}

	command void Flood.threeWayHandAck(pack* msg){
		if (TOS_NODE_ID != msg->dest){ //checks if current node is nto as dest
			call Flood.receiveFlood(msg); // if not, then call to send to next pack
		} else {
			list = call Neigh.get(); // get list of neighbors
			list2 = call Dijk.getAddr(); // get list of addresses
			dst = msg->src;
			if(!sendFlag[dst]){ // checks if
				printf("Got that from %d\n", msg->src);
				if (list2[dst] != 255){ //checks if th current dst is valid
					sendFlag[dst] = TRUE; //setting the flags as true
					senderFlag[dst] = FALSE;
					//this means that the node has sent and doesnt need to send anymore
					makePack(&floodPack, TOS_NODE_ID, dst, ttl, PROTOCOL_TCP_ACK, 0, list, packet);
					call SimpleSend.send(floodPack, list2[dst]);
					//send the packet next
					seq2++;
					call Flood.threeWayHandshake(dst);
				}
			} else if (sendFlag[dst] && senderFlag[dst]){
				makePack(&floodPack, TOS_NODE_ID, dst, ttl, PROTOCOL_TCP_ACK, 0, list, packet);
				call SimpleSend.send(floodPack, list2[dst]);

				printf("Preparing to send packets\n");
				call Flood.sendFun(dst);
			}
		}
	}

	command void Flood.sendBackMsg(uint8_t* payload){
		list = call Neigh.get();
		list2 = call Dijk.getAddr();
		for(i = 0; i < 10; i++){
			if(conClient[i] == TRUE){
				printf("Sending to %d\n", i);
				makePack(&floodPack, TOS_NODE_ID, i, ttl, PROTOCOL_MSG, 0, payload, packet);
				call SimpleSend.send(floodPack, list2[i]);
			}

		}
	}

	command void Flood.receiveBackMsg(pack* msg){
		if(msg->dest == TOS_NODE_ID ){
			iter = 0;
			while(*(msg->payload + sizeof(uint8_t) * iter) != '\0'){
				printf("%c", *(msg->payload + sizeof(uint8_t) * iter));
				iter++;
			}
			printf("\n");

		} else {
			call Flood.receiveFlood(msg);
		}
	}

	command void Flood.receiveMsg(pack* msg){
		if(msg->dest == TOS_NODE_ID ){
			conClient[msg->src] = TRUE;
			iter = 0;
			while(*(msg->payload + sizeof(uint8_t) * iter) != '\0'){
				printf("%c", *(msg->payload + sizeof(uint8_t) * iter));
				iter++;
			}
			printf("\n");

			call Flood.sendBackMsg(message);

			// list = call Neigh.get();
			// list2 = call Dijk.getAddr();
			// makePack(&floodPack, TOS_NODE_ID, msg->src, ttl, PROTOCOL_TCP_ACK, 0, , packet);
			// call SimpleSend.send(floodPack, list2[msg->src]);
		} else {
			call Flood.receiveFlood(msg);
		}
	}

	command void Flood.sendMsg(uint8_t* payload){
		if(!wait){
			list = call Neigh.get();
			list2 = call Dijk.getAddr();
			if (list2[(uint8_t) 1] != 255){
				wait = TRUE;
				makePack(&floodPack, TOS_NODE_ID, (uint8_t) 1, ttl, PROTOCOL_MESSAGE, seq2, payload, packet);
				call SimpleSend.send(floodPack, list2[(uint8_t) 1]);
			}
		}
	}


	command void Flood.threeWayHandshake(uint16_t dest){

		sendFlag[dest] = TRUE;
		//this indicates that the node has sent
		if(!wait){
			printf("Starting node: %d to node: %d\n", TOS_NODE_ID, dest);
			list = call Neigh.get();
			//list of nieghbors
			list2 = call Dijk.getAddr();
			//list of addresses using dijkstra
			if (list2[dest] != 255){
				//check to see if dest is valid
				makePack(&floodPack, TOS_NODE_ID, dest, ttl, PROTOCOL_TCP_SYN, seq2, list, packet);
				call SimpleSend.send(floodPack, list2[dest]);
				wait = TRUE;
			}
		}
	}
	event void sendTimer.fired(){
		if(!done){
			if (sequenceNum == 20) {
				sequenceNum = 0;
			}
			list = call Neigh.get();
			for(i = 0; i < 20; i++){
				if (list[i] == 1) {
					makePack(&floodPack, TOS_NODE_ID, i, ttl, PROTOCOL_FLOOD, sequenceNum, list, packet);
					call SimpleSend.send(floodPack, i);
				}
			}
			sequenceNum++;
		}
	}

}
