Class {
	#name : #ReHabModel,
	#superclass : #CMAbstractModel,
	#instVars : [
		'nbFamilies',
		'birdNewborns',
		'strategy_Family',
		'poaching',
		'restrained',
		'strategy_ParkManager',
		'theBirds',
		'theParkManagers',
		'theFamilies',
		'theCells',
		'theHarvesters'
	],
	#category : #'ReHab-Model'
}

{ #category : #description }
ReHabModel class >> aboutThisModel [
	" Answer a <String> which is the main description of the receiver's purpose "

	^ 'This model is supporting a Role-Playing Game. A virtual ecosystem is the reproductive habitat of an endangered species of animal, and at the same time it provides a source of income for local people who are havesting the dominant plant. The spatial setting is set as 20 regular space units holding 0,1,2 or 3 units of plant biomass. A constant number of 20 plant harvesters are competing to harvest the plant while a national park is trying to monitor the reproduction of the endangered species. Most of the players (5 to 20) are clans made of 1 to 4 members per clan (the number of members is set to make a total of 20). 1 to 3 players are National Park Officers"
'
]

{ #category : #description }
ReHabModel class >> howToRunIt [

	^ 'The documents needed to organize a gaming session are freely downloadable here: http://www.commod.org/modeles/rehab

You can play ReHab with a minimum of 6 participants up to about thirty (above that limit, it is better to split the group to play different sessions). With less than 10 participants, allocate just one of them to play the National Park manager; up to 20 (resp. more than 30) participants, allocate 2 (resp. 3) of them to interact in playing the National Park. All the other participants will play households made of harvesting members. The total number of individual harvesters (households'' members) HAS TO BE 20. The number of households can be set from 5 up to 20, with the corresponding distributions of individual members:
5 households   => 5*4 members
6 households   => 2*4 + 4*3 members
7 households   => 6*3 + 1*2 members
8 households   => 4*3 + 4*2 members
9 households   => 2*3 + 7*2 members
10 households => 10*2 members
11 households => 9*2 + 2*1 members
12 households => 8*2 + 4*1 members
13 households => 7*2 + 6*1 members
14 households => 6*2 + 8*1 members
15 households => 5*2 + 10*1 members
16 households => 4*2 + 12*1 members
17 households => 3*2 + 14*1 members
18 households => 2*2 + 16*1 members
19 households => 1*2 + 18*1 members
20 households => 20*1 members

You can group participants by households, to manage having all of them playing the game. A household made of i members (1 <= i <= 4) can be played by a group of n participants, with n possibly different from i. Use the right Excel decision sheet to distribute to each household according to its number of members.

To initialize a gaming session, clic on "Initialize", then select ("init_newGame" and "run_newGame:") and apply. Enter the name of your session. Enter the number of households. Two windows are poping up: a small one and a big one. Both represent the initial configuration of the environment. Switch your laptop display mode from "Duplicate" to "Extend" (Fn F8 or whatever it is encoded on your laptop). Move the bigger window to the public view and resize it so that it fits nicely within the available display box. Keep the smaller one on the private laptop screen. Participants playing the National Park have to be seated behind the laptop, so they can see the grid with the "bird" viewpoint activated. Other participants, playing the harvesting households, have to be dispersed around the room. They will be able to watch only the public neutral display. The operator in charge of entering players'' decisions and writting results is also seated behind the laptop.

Click on "execute one step" to move to the next round.

When 5 rounds have been played, to visualize the results of the scenario, select "Probes" from the "Visualization" main menu.

During the debriefing, it is often useful to replay a session. Clic on "Initialize", then select ("init_replay" and "run_replay:") and apply. Choose the name of the session you want to replay. If you decide to highlight one household, its members will be coloured, the darker the more biomass they have harvested.

'
]

{ #category : #probes }
ReHabModel >> birdNewborns [
	"Getter accessor with default value = 0 "
<probe>
	^ birdNewborns ifNil: [ birdNewborns := 0 ]
]

{ #category : #accessing }
ReHabModel >> birdNewborns: x [
	birdNewborns := x
]

{ #category : #birds }
ReHabModel >> birdsMigrating [

	self theCells do: [ :zone |
		(zone occupantsType: ReHabBird) do: [ :bird |
			bird leave; die ] ]
]

{ #category : #birds }
ReHabModel >> birdsNesting [
	| newBird |
	self theBirds: OrderedCollection new.
	self theCells
		do: [ :z | 
			z biomass >= ReHabBird habitatSuitabilityThreshold
				ifTrue: [
					newBird := self newEntity: ReHabBird.
					newBird moveTo: z ] ]
]

{ #category : #'instance-creation' }
ReHabModel >> createFamiliesFromDistributionMembers [

	(ReHabFamily membersDistribution at: self nbFamilies)
		do: [:nbMembers | self createFamilyWithNbMembers: nbMembers]
]

{ #category : #'instance-creation' }
ReHabModel >> createFamilyWithNbMembers: anInteger [
	| newClan newMember |
	newClan := self newEntity: ReHabFamily.
	newClan zones: self theCells.
	1 to: anInteger
		do:
			[:index |
			newMember := self newEntity: ReHabHarvester.
			newClan addComponent: newMember.
			newMember myClan: newClan.
			newMember label: 'H' , newClan id printString , 'M' , index printString]
]

{ #category : #probes }
ReHabModel >> harvest [
<probe>
	^ self theFamilies
		inject: 0
		into: [ :sum :aFamily | sum + aFamily harvest ]
]

{ #category : #init }
ReHabModel >> init [
	self
		createGridLines: 4
		columns: 5
		neighbourhood: 8
		closed: true.
	self setInitialBiomasses.
	self theCells do: [ :aZone | aZone noHarvestPeriod: 0 ].
	self initAgents_Autonomous
]

{ #category : #'instance-creation' }
ReHabModel >> initAgents_Autonomous [
	"self poaching: 0." "0 (default) or 1"
	"self restrained: 0.5." "float from 0 (default) to 1"
	"self nbFamilies: 10." "integer from 1 to 20 (5 by default)"
	"self strategy_Family: 4." "integer from 1 (default) to nb subclasses Strategy_Family (4 in this version)"
	"self strategy_ParkManager: 2." "integer from 1 (default) to nb subclasses Strategy_ParkManager (2 in this version)"

	self createFamiliesFromDistributionMembers.
	self theFamilies
		do:
			[:f |
			f zones: self theCells.
			f strategy: (self newEntity: (ReHabFamilyStrategy allSubclasses at: self strategy_Family)).
			f strategy holder: f.
			f strategy poacher: self poaching.
			f strategy restrained: self restrained].
	self initAnimals.
	self initParkManager.
	self parkManager strategy: (self newEntity: (ReHabParkManagerStrategy allSubclasses at: self strategy_ParkManager)).
	self parkManager strategy holder: self parkManager
]

{ #category : #'instance-creation' }
ReHabModel >> initAnimals [
	self birdNewborns: 0.
]

{ #category : #'instance-creation' }
ReHabModel >> initParkManager [
	self newEntity: ReHabParkManager.
	self parkManager zones: self theCells
]

{ #category : #accessing }
ReHabModel >> nbFamilies [
	"Getter accessor with initial value = 5.
	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !! "
	^nbFamilies ifNil:[nbFamilies := 5]
]

{ #category : #accessing }
ReHabModel >> nbFamilies: aSmallInteger [
	"Setter accessor of attribute nbFamilies	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !!  "
	nbFamilies := aSmallInteger
]

{ #category : #accessing }
ReHabModel >> parkManager [
	^self theParkManagers first
]

{ #category : #accessing }
ReHabModel >> poaching [
	"Getter accessor with initial value = 0.
	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !! "
	^poaching ifNil:[poaching := 0]
]

{ #category : #accessing }
ReHabModel >> poaching: aSmallInteger [
	"Setter accessor of attribute poaching	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !!  "
	poaching := aSmallInteger
]

{ #category : #probes }
ReHabModel >> resourceBiomass [
<probe>
	^ self theCells inject: 0 into: [ :sum :aZone | sum + aZone biomass ]
]

{ #category : #accessing }
ReHabModel >> restrained [
	"Getter accessor with initial value = 0.
	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !! "
	^restrained ifNil:[restrained := 0]
]

{ #category : #accessing }
ReHabModel >> restrained: aSmallInteger [
	"Setter accessor of attribute restrained	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !!  "
	restrained := aSmallInteger
]

{ #category : #'instance-creation' }
ReHabModel >> setInitialBiomasses [

	| initialPlantBiomasses |
	initialPlantBiomasses := #(1 1 2 1 1 2 0 2 3 2 1 3 1 2 1 1 3 1 0 2).
	self theCells
		with: initialPlantBiomasses
		do: [:z :i | z biomass: i]
]

{ #category : #control }
ReHabModel >> step: t [
	| newBirds |
	self birdsNesting.
	t > 1
		ifTrue: [ self parkManager decideAccess ].
	self theFamilies
		do: [ :f | 
			f
				decideHarvestersLocations;
				sendMembersHarvesting ].
	self theCells do: [ :aZone | aZone allocateHarvests ].
	newBirds := Set new.
	self theBirds do: [ :aBird | newBirds addAll: aBird reproduce ].
	self theBirds addAll: newBirds.
	self birdNewborns: self birdNewborns + newBirds size.
	self theCells do: [ :aZone | aZone renewBiomass ].
	self theHarvesters do: [ :ph | ph leave ].
	self theFamilies do: [ :h | h updateHarvest ].
	self birdsMigrating.
	t > 1
		ifTrue: [ self theCells do: [ :z | z access: true ] ]
]

{ #category : #accessing }
ReHabModel >> strategy_Family [
	"Getter accessor with initial value = 1.
	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !! "
	^strategy_Family ifNil:[strategy_Family := 1]
]

{ #category : #accessing }
ReHabModel >> strategy_Family: aSmallInteger [
	"Setter accessor of attribute strategy	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !!  "
	strategy_Family := aSmallInteger
]

{ #category : #accessing }
ReHabModel >> strategy_ParkManager [
	"Getter accessor with initial value = 1.
	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !! "
	^strategy_ParkManager ifNil:[strategy_ParkManager := 1]
]

{ #category : #accessing }
ReHabModel >> strategy_ParkManager: aSmallInteger [
	"Setter accessor of attribute strategy_ParkManager	This method was automatically generated by Cormas.
	!! BECAREFUL, You should not modify this method as it can be generated again when changing the value (Sensitivity Analysis for ex) !!  "
	strategy_ParkManager := aSmallInteger
]

{ #category : #accessing }
ReHabModel >> theBirds [
	"Returns a collection of all the instances of the sub classes collected by cormasModel.
	!! This method was automatically generated by Cormas !!"

	^ theBirds ifNil: [ theBirds := OrderedCollection new ]
]

{ #category : #accessing }
ReHabModel >> theBirds: aNewCollection [
	"Set a new collection for theXXXs attribute.
	!! This method was automatically generated by Cormas !!"

	theBirds := aNewCollection
]

{ #category : #accessing }
ReHabModel >> theBlinds [
	"Returns a collection of all the instances of aClass (and sub classes) collected by cormasModel.
	!! This method was automatically generated by Cormas !! "

   ^self allTheEntities: ReHabBlindStrategy
]

{ #category : #accessing }
ReHabModel >> theCells [
	"Returns a collection of all the instances of the sub classes collected by cormasModel.
	!! This method was automatically generated by Cormas !!"

	^ theCells ifNil: [ theCells := OrderedCollection new ]
]

{ #category : #accessing }
ReHabModel >> theCells: aNewCollection [
	"Set a new collection for theXXXs attribute.
	!! This method was automatically generated by Cormas !!"

	theCells := aNewCollection
]

{ #category : #accessing }
ReHabModel >> theExplorers [
	"Returns a collection of all the instances of aClass (and sub classes) collected by cormasModel.
	!! This method was automatically generated by Cormas !! "

   ^self allTheEntities: ReHabExplorerStrategy
]

{ #category : #accessing }
ReHabModel >> theFamilies [
	"Returns a collection of all the instances of the sub classes collected by cormasModel.
	!! This method was automatically generated by Cormas !!"

	^ theFamilies ifNil: [ theFamilies := OrderedCollection new ]
]

{ #category : #accessing }
ReHabModel >> theFamilies: aNewCollection [
	"Set a new collection for theXXXs attribute.
	!! This method was automatically generated by Cormas !!"

	theFamilies := aNewCollection
]

{ #category : #accessing }
ReHabModel >> theHarvesters [
	"Returns a collection of all the instances of the sub classes collected by cormasModel.
	!! This method was automatically generated by Cormas !!"

	^ theHarvesters ifNil: [ theHarvesters := OrderedCollection new ]
]

{ #category : #accessing }
ReHabModel >> theHarvesters: aNewCollection [
	"Set a new collection for theXXXs attribute.
	!! This method was automatically generated by Cormas !!"

	theHarvesters := aNewCollection
]

{ #category : #accessing }
ReHabModel >> theLoneRiders [
	"Returns a collection of all the instances of aClass (and sub classes) collected by cormasModel.
	!! This method was automatically generated by Cormas !! "

   ^self allTheEntities: ReHabLoneRiderStrategy
]

{ #category : #accessing }
ReHabModel >> theMaximizers [
	"Returns a collection of all the instances of aClass (and sub classes) collected by cormasModel.
	!! This method was automatically generated by Cormas !! "

   ^self allTheEntities: ReHabMaximizerStrategy
]

{ #category : #accessing }
ReHabModel >> theParkManagers [
	"Returns a collection of all the instances of the sub classes collected by cormasModel.
	!! This method was automatically generated by Cormas !!"

	^ theParkManagers ifNil: [ theParkManagers := OrderedCollection new ]
]

{ #category : #accessing }
ReHabModel >> theParkManagers: aNewCollection [
	"Set a new collection for theXXXs attribute.
	!! This method was automatically generated by Cormas !!"

	theParkManagers := aNewCollection
]

{ #category : #accessing }
ReHabModel >> theStrategies [
	"Returns a collection of all the instances of aClass (and sub classes) collected by cormasModel.
	!! This method was automatically generated by Cormas !! "

   ^self allTheEntities: ReHabStrategy
]

{ #category : #accessing }
ReHabModel >> theStrategyFamilies [
	"Returns a collection of all the instances of aClass (and sub classes) collected by cormasModel.
	!! This method was automatically generated by Cormas !! "

   ^self allTheEntities: ReHabFamilyStrategy
]

{ #category : #accessing }
ReHabModel >> theStrategyParkManagers [
	"Returns a collection of all the instances of aClass (and sub classes) collected by cormasModel.
	!! This method was automatically generated by Cormas !! "

   ^self allTheEntities: ReHabParkManagerStrategy
]
