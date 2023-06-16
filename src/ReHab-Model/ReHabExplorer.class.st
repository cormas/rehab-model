Class {
	#name : #ReHabExplorer,
	#superclass : #ReHabStrategyFamily,
	#category : #'ReHab-Model'
}

{ #category : #accessing }
ReHabExplorer >> possibleLocations [
	^ super possibleLocations select: [ :z | z biomass isZero not ]
]
