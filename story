[S05] - [Epic2][SI.No2->No6] ILC -ILC+UI/UA request for Settlement should go to FTI as Outstanding Claim event instead of Correspondence


Objectives: Ensure that when ILC -ILC+UI/UA triggers a settlement request, The system sends

 The event to FTI system as an outstanding claim event instead of correspondence event



Features: Routing request for settlement event to FTI as outstanding claim event
.

Story :

FCC will create settlement request with claim reference then in that case TI will create outstanding claim event or else if claim reference is not there then in that case TI will create correspondence event in FTI

        ( This needs to be clarified, FCC must always send a valid CLAIM Reference. And they will have to provide the correct code to create an outstanding claim, otherwise they will have to pass a different code (no code) so that TICC will select a correspondence. Currently TICC will use a message to create an outstanding claim if tnxTypeCode = 13 and subTnxTypeCode in (08, 09, 62 & 63). )
.

Scenario#1 Request for settlement event should be sent as outstanding claim event

Given On TI Create an Issue ILC and release
   And On FCC an Issue ILC is created
   And On TI Create a Claim received event with Pay Action of "General request" and release
   And On FCC a ??? is created
   
When On FCC, request for an ILC+ UI/UA for Settlement and release
   And On TICC, it will receive the tnxTypeCode of "13" and subTnxTypeCode of "???"
   And On TICC, from the code, it will select TFILCPYR to TI for ILC Outstanding claim creation   

Then On TI, I can see that a Outstanding claim has been created  continuing the previous Claim
   And the customer instructions on settlement is mapped in narrative filed under response received
   And account information, FX contract shown as action item.



Scenario#2 Request for settlement event is sent as correspondence event in TI

Given On TI Create an Issue ILC and release
   And On FCC an Issue ILC is created
   And On TI Create a Claim received event with Pay Action of "General request" and release
   And On FCC a ??? is created
   
When On FCC, request for an ILC+ UI/UA for Settlement and release
   And On TICC, it will receive the tnxTypeCode of "13" and subTnxTypeCode is empty or not recognize by TICC
   And On TICC, from the code, it will select TFILCCOR to TI for ILC Correspondence

Then On TI, I can see that a Correspondence event is create
   And the Receive message narrative is populated



A correspondence event is created in FTI when ILC Outstanding claim / Settlement is requested by corporate. Bank has requested that a Outstanding claim event should be created instead of a Correspondence event. Changes required in FCC, TICC and FTI.
This could also be extended to integrated finance.
