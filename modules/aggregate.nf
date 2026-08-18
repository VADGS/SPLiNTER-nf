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

	awk 'BEGIN{ FS = OFS = "\\t" } { print \$0, (NR==1? "freyja_version" : "2.0.3-SARS-CoV-2-08_03_2026-00-53-2026-08-03") }' aggregated_results.tsv > temp && mv temp freyja_report.tsv 


	"""
	
	
}
