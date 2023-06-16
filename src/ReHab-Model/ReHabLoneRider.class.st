Class {
	#name : #ReHabLoneRider,
	#superclass : #ReHabStrategyFamily,
	#category : #'ReHab-Model'
}

{ #category : #accessing }
ReHabLoneRider >> possibleLocations [
	| minBiomass |
	minBiomass := Cormas
		minOf: #biomass
		amongObjects: (super possibleLocations select: [ :z | z biomass isZero not ]).
	^ super possibleLocations select: [ :z | z biomass = minBiomass ]
]
