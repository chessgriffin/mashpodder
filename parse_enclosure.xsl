<?xml version="1.0"?>
<stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/XSL/Transform">
	<output method="text"/>
	<template match="/">
		<apply-templates select="/rss/channel/item/enclosure"/>
	</template>
	<template match="enclosure">
		<value-of select="@url"/><text>&#10;</text>
	</template>
</stylesheet>
