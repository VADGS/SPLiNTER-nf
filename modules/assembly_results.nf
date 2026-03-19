process assembly_results {

  publishDir "${params.outdir}/report", mode: 'copy', pattern: "splinter_qc*.csv"



  echo true



  input:

  file(cg_pipeline_results)

  file(pangolin_lineages)

  output:

  path("splinter_qc*.csv"),      emit: splinter_summary





  script:

    """

    #!/usr/bin/env python3

    import os, sys

    import glob, csv

    import xml.etree.ElementTree as ET

    from datetime import datetime



    today = datetime.today()

    today = today.strftime("%m%d%y")



    class result_values:

        def __init__(self,id):

            self.id = id

            self.aligned_bases = "NA"

            self.percent_cvg = "NA"

            self.mean_depth = "NA"

            self.mean_base_q = "NA"

            self.mean_map_q = "NA"

            self.monroe_qc = "NA"

            self.pangolin_lineage = "NA"

            self.pangolin_conflict= "NA"

            self.pangolin_version = "NA"

            self.pangolin_notes = "NA"





    #get list of result files

    samtools_results = glob.glob("*_samtoolscoverage.tsv")

    pangolin_results = glob.glob("*_lineage_report.csv")

    results = {}



    # collect samtools results

    for file in samtools_results:

        id = file.split("_samtoolscoverage.tsv")[0]

        result = result_values(id)

        monroe_qc = []

        with open(file,'r') as tsv_file:

            tsv_reader = list(csv.DictReader(tsv_file, delimiter="\t"))

            for line in tsv_reader:

                result.aligned_bases = line["covbases"]

                result.percent_cvg = line["coverage"]

                if float(line["coverage"]) < 60:

                    monroe_qc.append("coverage <60%")

                result.mean_depth = line["meandepth"]

                result.mean_base_q = line["meanbaseq"]

                if float(line["meanbaseq"]) < 30:

                    monroe_qc.append("meanbaseq < 30")

                result.mean_map_q = line["meanmapq"]

                if float(line["meanmapq"]) < 30:

                    monroe_qc.append("meanmapq < 30")

            if len(monroe_qc) == 0:

                result.monroe_qc = "PASS"

            else:

                result.monroe_qc ="WARNING: " + '; '.join(monroe_qc)



        file = (id + "_lineage_report.csv")

        with open(file,'r') as csv_file:

            csv_reader = list(csv.DictReader(csv_file, delimiter=","))

            for line in csv_reader:

                if line["qc_status"] == "fail":

                    result.pangolin_lineage = "failed pangolin qc"

                else:

                    result.pangolin_lineage = line["lineage"]

                    result.pangolin_conflict = line["conflict"]

                    result.pangolin_notes = line["scorpio_notes"]

                    result.pangolin_version = line["pangolin_version"]



        results[id] = result





    #create output file

    with open(f"splinter_qc_{today}.csv",'w') as csvout:

        writer = csv.writer(csvout,delimiter=',')

        writer.writerow(["sample","aligned_bases","percent_cvg", "mean_depth", "mean_base_q", "mean_map_q", "monroe_qc", "pangolin_lineage", "pangolin_conflict", "pangolin_notes","pangolin_version"])

        for id in results:

            result = results[id]

            writer.writerow([result.id,result.aligned_bases,result.percent_cvg,result.mean_depth,result.mean_base_q,result.mean_map_q,result.monroe_qc,result.pangolin_lineage,result.pangolin_conflict,result.pangolin_notes,result.pangolin_version])

    """



}
