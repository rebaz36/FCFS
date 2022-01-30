#create a simulator object
set ns [new Simulator]

#Define different colors for Data Flows
$ns color 1 Blue
$ns color 2 Red

#Open the nam trace file

set nf [open out.nam w]
$ns namtrace-all $nf

set nt [open test.tr w]
$ns trace-all $nt

#Define a 'finish' procedure

proc finish {} {
	global ns nf nt
	$ns flush-trace
	#closeing the trace file
	close $nf
	close $nt
	#Execute nam on the trace file
	#exec nam out.nam &
	exit 0	
}

#Create four nodes

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Create links between the nodes
Queue set limit_ 100
$ns duplex-link $n0 $n2 5Mb 10ms DropTail
$ns duplex-link $n1 $n2 5Mb 10ms DropTail
$ns duplex-link $n3 $n2 1Mb 10ms PBRR

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

$ns at 0.0 "$n0 label node0"
$ns at 0.0 "$n1 label node1"
$ns at 0.0 "$n2 label node2"
$ns at 0.0 "$n3 label node3"

#Monitor the Queue for the link between node 2 and node 3
$ns duplex-link-op $n2 $n3 queuePos 0.5


#Creating a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0

#Creating a CBR(Constant Bit rate) traffic source and attach it to udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.001
$cbr0 attach-agent $udp0


#Creating a UDP agent and attach it to node n1
set udp1 [new Agent/UDP]
$udp0 set class_ 2
$ns attach-agent $n1 $udp1

#Creating a CBR(Constant Bit rate) traffic source and attach it to udp1

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.001
$cbr1 attach-agent $udp1


#Creating a null agent (a traffic sink) and attach it to node n3
set null0 [new Agent/Null]
$ns attach-agent $n3 $null0

#Connect the traffic source with traffic sink 

$ns connect $udp0 $null0
$udp0 set fid_ 1
$udp0 set prio_ 1
$ns connect $udp1 $null0
$udp1 set fid_ 2
$udp1 set prio_ 99

#Schedule events for the CBR agents

$ns at 0.5 "$cbr0 start"
$ns at 0.5 "$cbr1 start"
$ns at 4.0 "$cbr1 stop"
$ns at 4.0 "$cbr0 stop"

# Calling finish procedure

$ns at 4.5 "finish"

#Running the simulator
$ns run
