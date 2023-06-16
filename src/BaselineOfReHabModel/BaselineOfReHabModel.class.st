Class {
	#name : #BaselineOfReHabModel,
	#superclass : #BaselineOf,
	#category : #BaselineOfReHabModel
}

{ #category : #baselines }
BaselineOfReHabModel >> baseline: spec [

	<baseline>
	spec for: #common do: [
		"Dependencies"
		self loadCormas: spec.

		"Packages"
		spec
			package: 'ReHab-Model' with: [ spec requires: #(Cormas) ];
			package: 'ReHab-Model-Tests' with: [ spec requires: #( 'ReHab-Model' ) ] ]
]

{ #category : #dependencies }
BaselineOfReHabModel >> loadCormas: spec [

	spec
		baseline: 'Cormas'
		with: [ spec loads: #(Core); repository: 'github://cormas/cormas' ]
]
