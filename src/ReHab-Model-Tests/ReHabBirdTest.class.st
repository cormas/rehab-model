Class {
	#name : #ReHabBirdTest,
	#superclass : #TestCase,
	#instVars : [
		'bird'
	],
	#category : #'ReHab-Model-Tests'
}

{ #category : #initialization }
ReHabBirdTest >> setUp [

	super setUp.
	bird := ReHabBird new.
]

{ #category : #tests }
ReHabBirdTest >> testInitialStatus [

	self assert: bird status equals: #adult
]
