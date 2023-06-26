Class {
	#name : #ReHabLoneRiderStrategy,
	#superclass : #ReHabFamilyStrategy,
	#category : #'ReHab-Model'
}

{ #category : #accessing }
ReHabLoneRiderStrategy >> possibleLocations [
	| minBiomass |
	minBiomass := Cormas
		minOf: #biomass
		amongObjects: (super possibleLocations select: [ :z | z biomass isZero not ]).
	^ super possibleLocations select: [ :z | z biomass = minBiomass ]
]
