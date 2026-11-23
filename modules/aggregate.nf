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

	awk 'BEGIN{ FS = OFS = "\\t" } { print \$0, (NR==1? "freyja_version" : "2.0.7-SARS-CoV-2-11_16_2026-05-18-2026-11-16") }' aggregated_results.tsv > temp && mv temp freyja_report.tsv 


	"""
	
	
}
