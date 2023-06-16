Class {
	#name : #ReHabMaximizer,
	#superclass : #ReHabStrategyFamily,
	#category : #'ReHab-Model'
}

{ #category : #accessing }
ReHabMaximizer >> possibleLocations [
| maxBiomass |

	maxBiomass := Cormas
		maxOf: #biomass
		amongObjects: super possibleLocations.

	^super possibleLocations select: [:z | z biomass = maxBiomass]
]
