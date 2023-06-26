Class {
	#name : #ReHabMaximizerStrategy,
	#superclass : #ReHabFamilyStrategy,
	#category : #'ReHab-Model'
}

{ #category : #accessing }
ReHabMaximizerStrategy >> possibleLocations [
| maxBiomass |

	maxBiomass := Cormas
		maxOf: #biomass
		amongObjects: super possibleLocations.

	^super possibleLocations select: [:z | z biomass = maxBiomass]
]
