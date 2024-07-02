process aggregate {
	publishDir "${params.outdir}", mode: 'copy'
	
	input:
	file(freyja_abundances)

	output:
	file("freyja_report.tsv")				

	shell:
	"""
	mkdir tmp

	mv !{freyja_abundances} tmp/.

	freyja aggregate tmp/ --output aggregated_results.tsv

	awk 'BEGIN{ FS = OFS = "\\t" } { print \$0, (NR==1? "freyja_version" : "1.5.1-20240625") }' aggregated_results.tsv > temp && mv temp freyja_report.tsv 


	"""
	
	
}
