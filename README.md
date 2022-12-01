# starkNetCCIndia-ZKX-Hackathon

The track I took for the hackathon is a ZKS sponsored.
Write Cairo smart contract that allows users to propose a feature for a voting and for users to vote (in your favour of voting)



Inittiate the project with the following protostar command

$ protostar init {name of your project}

Install the openzeppeling dependencies from the below command

$ protostar install OpenZeppelin/cairo-contracts@v0.4.0

I have three source files
src
  |_>
    Interfaces
              \_>
              ITimelocak.cairo
  |_>
    Libraries
              |_>
                Approver.cairo
  |_>
    zkx-hack.cairo
    
  
  zkx-hack.cairo is the main contract file.
  
  The openzeppelin contracts are installed on upper level src directory. For compilation need to copy the Interfaces and Libraries folder from src to the openzeppelin src folder
  
  Compile the contract with the following command passing where your external libs are
  
  protostar build --cairo-path ./lib/cairo_contracts/src
  
  
  The laree part of the code is influenced from DolvenLabs contract which has the functionality for proposal submission and voting
  
  
