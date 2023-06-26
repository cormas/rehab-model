Class {
	#name : #ReHabExplorerStrategy,
	#superclass : #ReHabFamilyStrategy,
	#category : #'ReHab-Model'
}

{ #category : #accessing }
ReHabExplorerStrategy >> possibleLocations [
	^ super possibleLocations select: [ :z | z biomass isZero not ]
]
